//
//  MetaWearSensor.swift
//  FootNoter
//
//  Controls a single instance of a MetaWear sensor
//

import Foundation
import MetaWear
import MetaWearCpp

enum SensorFacing {
    case faceUp, faceDown
}

enum SensorOrientation {
    case portraitUpright, portraitUpsideDown, landscapeLeft, landscapeRight
}

enum SensorStatus {
    case ready, error, disconnected
}

class MetaWearSensor {
    var sensor: MetaWear!
    var board: OpaquePointer!
    var mac: String!
    var batteryLife: String!
    var gyroSignal: OpaquePointer!
    var accelSignal: OpaquePointer!
    var batterySignal: OpaquePointer!
    var stepSignal: OpaquePointer!
    var orientationSignal: OpaquePointer!
    var quatSignal: OpaquePointer!
    var eulerSignal: OpaquePointer!
    var facing: SensorFacing?
    var orientation: SensorOrientation?
    var delegate: MetaWearSensorDelegate?
    
    /**
     Intialization ensures there is a sensor that this class contains and uses
    **/
    init (metaWear: MetaWear, completion: @escaping (Bool) -> Void) {
        sensor = metaWear
        batteryLife = "0%" //This is just initially, as soon as connection is completed, it can be changed to the actual battery reading
        
        connectToSensor { result in
            if result {//connection success, finish setting up
                
                self.board = self.sensor.board
                self.mac = self.sensor.mac
                
                //self.setUpGyroscope()
               // self.setUpAccelerometer()
                self.setUpStepDetection()
               // self.checkBatteryLife()
                self.setUpOrientation()
                self.setUpSensorFusion()
                
                completion(true)
                
            } else {//connection error
                //TODO: handle error
                completion(false)
            }
        }
    }
    
    /**
     Metawear connection protocol as per their docs
    **/
    func connectToSensor(completion: @escaping (Bool) -> Void) {
        
        sensor.connectAndSetup().continueWith { t in
            
            if t.cancelled {
                print("connection cancelled")
                completion(false)
            } else if t.faulted {
                print(t.error.debugDescription)
                completion(false)
            } else {
                completion(true)
                
                print("connected to sensor")
            }
            
            t.result?.continueWith(continuation: { t in
                print("lost connection")
                //TODO: handle disconnects
                if let del = self.delegate {
                    del.notifyDisconnect()
                }
            })
        }
    }
    
    /**
     Step 1 in the setup process
     Uses a C++ pointer to configure and subscribe to the accelerometer chip on the Metawear board
    **/
    func setUpAccelerometer() {
        
        mbl_mw_acc_set_range(board, 8.0)
        mbl_mw_acc_set_odr(board, 20.0)
        mbl_mw_acc_write_acceleration_config(board)
        
        accelSignal = mbl_mw_acc_get_acceleration_data_signal(board)
        //1
        mbl_mw_datasignal_subscribe(accelSignal, bridge(obj: self)) { (context, dataPtr) in
            let _self: MetaWearSensor = bridge(ptr: context!)
            let data = dataPtr!.pointee.valueAs() as MblMwCartesianFloat
            
            if let del = _self.delegate {
                //del.pushReading(x: Double(data.x), y: Double(data.y), z: Double(data.z))
            }
        }
        
        mbl_mw_acc_enable_acceleration_sampling(board)
    }
    
    /**
     Step 2 in the setup process
     Uses a C++ pointer to configure and subscribe to the gyroscope chip on the Metawear board
     Part of initial discovery of this app will be to determine if the gyroscope is needed for incorrect foot alignment
     Gyroscope functionality is very similar to the accelerometer so I might leave it in the code for future development (even if we don't use)
    **/
    func setUpGyroscope() {
        
        if let connectedBoard = board {
            mbl_mw_gyro_bmi160_set_range(connectedBoard, MBL_MW_GYRO_BMI160_RANGE_125dps)
            mbl_mw_gyro_bmi160_set_odr(connectedBoard, MBL_MW_GYRO_BMI160_ODR_25Hz)
            mbl_mw_gyro_bmi160_write_config(connectedBoard)
            
            gyroSignal = mbl_mw_gyro_bmi160_get_rotation_data_signal(connectedBoard)
            //2
            mbl_mw_datasignal_subscribe(gyroSignal, bridge(obj: self)) { (context, dataPtr) in
                let _self: MetaWearSensor = bridge(ptr: context!)
                let data = dataPtr!.pointee.valueAs() as MblMwCartesianFloat
                
                //TODO: ready to feed into algorithm
                
            }
            
            mbl_mw_gyro_bmi160_enable_rotation_sampling(connectedBoard)
        }
    }
    
    /**
     Checking the battery life requires a signal subscription
     */
    func setUpBattery() {
        
        batterySignal = mbl_mw_settings_get_battery_state_data_signal(board)
        //4
        mbl_mw_datasignal_subscribe(batterySignal, bridge(obj: self)) { (context, dataPtr) in
            let _self: MetaWearSensor = bridge(ptr: context!)
            let data = dataPtr!.pointee.valueAs() as MblMwBatteryState
            
            _self.batteryLife = data.charge.description + "%"
            print(_self.batteryLife)
        }
    }

    /**
     Step 3 in the set up process
     Uses a C++ pointer to configure and subscribe to the step detection signal (specific to the BMI160 accelerometers) on the Metawear board
     For more information: https://mbientlab.com/cppdocs/latest/accelerometer.html#step-counter
     */
    
    func setUpStepDetection() {
        if checkCompatibleAccelerometer() == true {
            if let connectedBoard = board {
                mbl_mw_acc_bmi160_set_step_counter_mode(connectedBoard, MBL_MW_ACC_BMI160_STEP_COUNTER_MODE_ROBUST)
                mbl_mw_acc_bmi160_write_step_counter_config(connectedBoard)
                
                stepSignal = mbl_mw_acc_bmi160_get_step_detector_data_signal(connectedBoard)
                //3
                mbl_mw_datasignal_subscribe(stepSignal, bridge(obj: self)) { (context, dataPtr) in
                    let _self: MetaWearSensor = bridge(ptr: context!)
                    let time = dataPtr!.pointee.timestamp as Date
                    
                    if let del = _self.delegate {
                        del.step(time)
                    }
                }
                
                mbl_mw_acc_bmi160_enable_step_detector(connectedBoard)
            }
        } else {
            //TODO: warn user
        }
    }
    
    /**
     Checks to see if the connected sensor has a compatible accelerometer for step counting
     It is possible Metawears may sometimes have incompatible accelerometers, or that each accelerometer might have to be individually configured
     We are checking to see if the sensor connected has a BMI160 board
     If it does, this function returns true. If it does not, it returns false
     */
    func checkCompatibleAccelerometer() -> Bool {
        if let connectedBoard = board {
            /*
             First find out if we have an accelerometer with step detection
             For more information: https://mbientlab.com/cppdocs/latest/accelerometer.html#accelerometer
             */
            let accelerometer_type = mbl_mw_metawearboard_lookup_module(connectedBoard, MBL_MW_MODULE_ACCELEROMETER)
            
            switch accelerometer_type {
            case MBL_MW_MODULE_TYPE_NA: //-1
                // should never reach this case statement
                print("No accelerometer found")
                return false
            case Int32(MBL_MW_MODULE_ACC_TYPE_BMI160): //1
                print("Accelerometer type is BMI160")
                return true
            case Int32(MBL_MW_MODULE_ACC_TYPE_MMA8452Q): //0
                print("Acc Type = MMA8452Q")
                return false
            case Int32(MBL_MW_MODULE_ACC_TYPE_BMA255): //3
                print("Acc Type = BMA255")
                return false
            default:
                print("Unknown type")
                return false
            }
        }
        return false
    }
    
    func setUpSensorFusion() {
        if let connectedBoard = board {
            mbl_mw_sensor_fusion_set_mode(connectedBoard, MBL_MW_SENSOR_FUSION_MODE_IMU_PLUS)
            mbl_mw_sensor_fusion_write_config(connectedBoard)
            
            eulerSignal = mbl_mw_sensor_fusion_get_data_signal(connectedBoard, MBL_MW_SENSOR_FUSION_DATA_EULER_ANGLE)
            quatSignal = mbl_mw_sensor_fusion_get_data_signal(connectedBoard, MBL_MW_SENSOR_FUSION_DATA_QUATERNION)
            
            mbl_mw_datasignal_subscribe(quatSignal, bridge(obj: self)) { (context, dataPtr) in
                let _self: MetaWearSensor = bridge(ptr: context!)
                let timestamp = dataPtr!.pointee.timestamp
                //let data = dataPtr!.pointee.valueAs() as MblMwEulerAngles
                let data = dataPtr!.pointee.valueAs() as MblMwQuaternion
                //print(data)
                if let del = _self.delegate {
                    //del.sensorFusion(angles: data, time: timestamp)
                    del.sensorFusionQuat(angles: data, time: timestamp)
                } else {
                    print("no delegate for sensor fusion")
                }
            }
            
            //mbl_mw_sensor_fusion_enable_data(connectedBoard, MBL_MW_SENSOR_FUSION_DATA_EULER_ANGLE)
            mbl_mw_sensor_fusion_enable_data(connectedBoard, MBL_MW_SENSOR_FUSION_DATA_QUATERNION)
            mbl_mw_sensor_fusion_start(connectedBoard)
            print("sensor fusion set up")
        }
    }
    
    /**
     After the configuration (above) completes, this can be used to access the ongoing accelerometer (//1), gyroscope (//2), and step detection (//3) subscriptions as set up above
    **/
    func start() {
        if let connectedBoard = board {
            if accelSignal != nil {
               // mbl_mw_acc_start(connectedBoard)
            }
            
            if gyroSignal != nil {
              //  mbl_mw_gyro_bmi160_start(connectedBoard)
            }
            
            if stepSignal != nil && orientationSignal != nil {
                mbl_mw_acc_bosch_start(connectedBoard)
            }
        }
    }
    
    /**
     Stops streaming data (accelerometer, gyroscope, and steps)
     */
    func stop() {
        if let connectedBoard = board {
            if accelSignal != nil {
                mbl_mw_acc_stop(connectedBoard)
            }
            
            if gyroSignal != nil {
                mbl_mw_gyro_bmi160_stop(connectedBoard)
            }
            
            if stepSignal != nil && orientationSignal != nil {
                mbl_mw_acc_bosch_stop(connectedBoard)
            }
        }
    }
   
    /**
     After the configuration (above //3), we can access the battery life of the sensor
    **/
    func checkBatteryLife() {
        //mbl_mw_datasignal_read(batterySignal)
    }
    
    /**
     Documentation for orientation detection can be found here:  https://mbientlab.com/cppdocs/latest/accelerometer.html#orientation-detection
     */
    func setUpOrientation() {
        
        if let connectedBoard = board {
            
            orientationSignal = mbl_mw_acc_bosch_get_orientation_detection_data_signal(connectedBoard)
            mbl_mw_datasignal_subscribe(orientationSignal, bridge(obj: self)) { (context, dataPtr) in
                let _self: MetaWearSensor = bridge(ptr: context!)
                let data = dataPtr!.pointee.valueAs() as MblMwSensorOrientation
                
                switch data {
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_PORTRAIT_UPRIGHT:
                    _self.facing = .faceUp
                    _self.orientation = .portraitUpright
                    break
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_PORTRAIT_UPSIDE_DOWN:
                    _self.facing = .faceUp
                    _self.orientation = .portraitUpsideDown
                    break
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_LANDSCAPE_LEFT:
                    _self.facing = .faceUp
                    _self.orientation = .landscapeLeft
                    break
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_LANDSCAPE_RIGHT:
                    _self.facing = .faceUp
                    _self.orientation = .landscapeRight
                    break
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_PORTRAIT_UPRIGHT:
                    _self.facing = .faceDown
                    _self.orientation = .portraitUpright
                    break
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_PORTRAIT_UPSIDE_DOWN:
                    _self.facing = .faceDown
                    _self.orientation = .portraitUpsideDown
                    break
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_LANDSCAPE_LEFT:
                    _self.facing = .faceDown
                    _self.orientation = .landscapeLeft
                    break
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_LANDSCAPE_RIGHT:
                    _self.facing = .faceDown
                    _self.orientation = .landscapeRight
                    break
                default:
                    break
                }
                
                if let del = _self.delegate {
                    del.orientationDetected()
                }
            }
            
            mbl_mw_acc_bosch_enable_orientation_detection(connectedBoard)
            
        }
    }
    
    func checkStatus() -> SensorStatus {
        if sensor.isConnectedAndSetup && quatSignal != nil && stepSignal != nil {
            return .ready
        } else if sensor.isConnectedAndSetup == false {
            return .disconnected
        } else {
            return .error
        }
    }
    
    //TODO: disconnection function
}

protocol MetaWearSensorDelegate {
    func notifyDisconnect()
    func step(_ time: Date)
    func orientationDetected()
    //func pushReading(x: Double, y: Double, z: Double)
    //func sensorFusionEuler(angles: MblMwEulerAngles, time: Date)
    func sensorFusionQuat(angles: MblMwQuaternion, time: Date)
}
