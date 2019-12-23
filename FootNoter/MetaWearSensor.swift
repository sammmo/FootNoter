//
//  MetaWearSensor.swift
//  FootNoter
//
//  Controls a single instance of a MetaWear sensor
//

import Foundation
import MetaWear
import MetawearCpp

class MetaWearSensor {
    var sensor: MetaWear!
    var board: OpaquePointer!
    var mac: String!
    var batteryLife: String!
    var gyroSignal: OpaquePointer!
    var accelSignal: OpaquePointer!
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
                
                self.setUpGyroscope()
                self.setUpAccelerometer()
                self.checkBatteryLife()
                self.standby()
                
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
            })
        }
    }
    
    /**
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
            
            //TODO: ready to feed into algorithm
        }
        
        mbl_mw_acc_enable_acceleration_sampling(board)
    }
    
    /**
     Uses a C++ pointer to configure and subscribe to the gyroscope chip on the Metawear board
     Part of initial discovery of this app will be to determine if the gyroscope is needed for incorrect foot alignment
    **/
    func setUpGyroscope() {
        
        mbl_mw_gyro_bmi160_set_range(board, MBL_MW_GYRO_BMI160_RANGE_125dps)
        mbl_mw_gyro_bmi160_set_odr(board, MBL_MW_GYRO_BMI160_ODR_25Hz)
        mbl_mw_gyro_bmi160_write_config(board)
        
        gyroSignal = mbl_mw_gyro_bmi160_get_rotation_data_signal(board)
        //2
        mbl_mw_datasignal_subscribe(gyroSignal, bridge(obj: self)) { (context, dataPtr) in
            let _self: MetaWearSensor = bridge(ptr: context!)
            let data = dataPtr!.pointee.valueAs() as MblMwCartesianFloat
            
            //TODO: ready to feed into algorithm
        }
        
        mbl_mw_gyro_bmi160_enable_rotation_sampling(board)
    }
    
    /**
     Checking the battery life requires a signal subscription
     **/
    func setUpBattery() {
        
        let batterySignal = mbl_mw_settings_get_battery_state_data_signal(board)
        //3
        mbl_mw_datasignal_subscribe(batterySignal, bridge(obj: self)) { (context, dataPtr) in
            let _self: MetaWearSensor = bridge(ptr: context!)
            let data = dataPtr!.pointee.valueAs() as MblMwBatteryState
            
            _self.batteryLife = data.charge.description + "%"
            print(_self.batteryLife)
        }
    }
    
    /**
     After the configuration (above) completes, this can be used to access the ongoing accelerometer (//1) and gyroscope (//2) subscriptions as set up above
    **/
    func record() {
        if accelSignal != nil {
            mbl_mw_acc_start(board)
        }
        
        if gyroSignal != nil {
            mbl_mw_gyro_bmi160_start(board)
        }
    }
    
    /**
     After the configuration (above //3), we can access the battery life of the sensor
    **/
    func checkBatteryLife() {
        
        mbl_mw_datasignal_read(batterySignal)
    }
    
    //TODO: disconnection function
}

protocol MetaWearSensorDelegate {
    func update()
}
