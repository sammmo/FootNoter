//
//  MetaWearManager.swift
//  FootNoter
//
//  Handles connection of accessible (nearby) MetaWear sensors
//  Notifies view controllers of connection status
//

import Foundation
import MetaWear
import MetaWearCpp

enum ConnectionStatus {
    case connected, disconnected
}

enum ScanningStatus {
    case scanning, standby
}

class MetaWearManager: MetaWearSensorDelegate {
    
    var mwSensor: MetaWearSensor?
    var delegate: MetaWearManagerDelegate?
    var readingDelegate: ReadingDelegate?
    var stepCount: Int = 0
    private var connectionStatus: ConnectionStatus!
    private var scanningStatus: ScanningStatus!
    
    init() {
        
        //TODO: upon loading, we will want to check if there are any MetaWear sensors already connected
        self.connectionStatus = .disconnected
        self.scanningStatus = .standby
    }
    
    /**
     Starts the scanning protocol for sensors
     If it finds one that it can connect to, it stops scanning and notifies delegate
    **/
    func locateNearbySensors() {
        if scanningStatus != .scanning && connectionStatus != .connected {
            scanningStatus = .scanning
            print(self.scanningStatus)
            
            mwScannerStart(completion: {
                self.scanningStatus = .standby
                print(self.scanningStatus)
            })
        } else {
            print("already scanning or else is already connected to a sensor")
        }
    }
    
    func mwScannerStart(completion: @escaping () -> Void) {
        
        /**
         MetaWearScanner is a dependency class (cocopods).
         It is an adoption of CoreBlueTooth for use with MetaWear sensors.
         For more information: https://mbientlab.com/iosdocs/latest/metawearscanner.html
         */
        
        //TODO: might want to put this on a timer (limit to 30 seconds?) so we stop scanning if no accessible sensors are found
        
        MetaWearScanner.shared.startScan(allowDuplicates: false) { sensor in
            print(sensor.rssi)
            if sensor.rssi > -60 {
                
                self.mwScannerStop()
                
                self.mwSensor = MetaWearSensor(metaWear: sensor, completion: { completed in
                    
                    if completed == true {//MetaWearSensor notifies us that the sensor was connected
                        print("successfully connected")
                        
                        self.mwSensor?.delegate = self
                        self.connectionStatus = .connected
                        //TODO: how to notify battery change??
                        
                    if let del = self.delegate {
                        //Notify delegate (View Controller of what is on the screen) that we are connected
                        del.update(mac: self.mwSensor?.mac ?? "No mac", battery: self.mwSensor?.batteryLife ?? "0%", connection: .connected)
                        }
                        
                        completion()
                    } else {//MetaWearSensor notifies us that there was an error (sensor was not successfully connected)
                        //TODO: alert user of error
                        if let del = self.delegate {
                            del.update(mac: "", battery: "", connection: .disconnected)
                        }
                        completion()
                    }
                })
            }
        }
    }
    
    func mwScannerStop() {
        MetaWearScanner.shared.stopScan()
    }
    
    func checkSensor() -> SensorStatus {
        if let sensor = mwSensor {
            return sensor.checkStatus()
        } else {
            return .disconnected
        }
    }
    
    //MARK: Stop / Start functions
    
    func startSensor() {
        if let sensor = mwSensor {
            if sensor.checkStatus() == .ready {
                sensor.start()
            }
        }
    }
    
    func stopSensor() {
        if let sensor = mwSensor {
            if sensor.checkStatus() == .ready {
                sensor.stop()
            }
        }
    }
    
    //MARK: - Delegate Protocol Functions
    
    func notifyDisconnect() {
        connectionStatus = .disconnected
        mwSensor = nil
        
        if let del = delegate {
            del.update(mac: "", battery: "", connection: .disconnected)
        }
    }
    
    func step() {
        stepCount += 1
        if let del = delegate {
            del.updateSteps(count: stepCount)
        }
    }
    
    func orientationDetected() {
        if let sensor = mwSensor {
            if let orient = sensor.orientation {
                if let facing = sensor.facing {
                    if let del = delegate {
                        del.updateOrientation(facing: facing, orientation: orient)
                    }
                }
            }
        }
    }
    
    /**
     Since the idea of this "Manager" is to abstract the sensor from the rest of the code, when the sensor takes an accelerometer reading, manager passes it along to whatever has declared itself the readings reciever (delegate)
     */
    
    func pushReading(x: Double, y: Double, z: Double) {
        if let del = readingDelegate {
            del.getReading(x: x, y: y, z: z)
        }
    }
    
}

protocol MetaWearManagerDelegate {
    func update(mac: String, battery: String, connection: ConnectionStatus)
    func updateSteps(count: Int)
    func updateOrientation(facing: SensorFacing, orientation: SensorOrientation)
}

protocol ReadingDelegate {
    func getReading(x: Double, y: Double, z: Double)
}
