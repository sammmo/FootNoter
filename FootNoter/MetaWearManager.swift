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

class MetaWearManager: MetaWearSensorDelegate {
    var sensor: MetaWearSensor?
    var delegate: MetaWearManagerDelegate?
    
    func update() {}
    
    /**
     Starts the scanning protocol for sensors
     If it finds one that it can connect to, it stops scanning and notifies delegate
    **/
    func locateNearbySensors() {

        MetaWearScanner.shared.startScan(allowDupicates: false) { sensor in
            if sensor.rssi > -60.0 {
                sensor = MetaWearSensor(sensor: sensor, completion: {
                    print("successfully connected")
                    if let del = delegate {
                        delegate.connect()
                    }
                    
                    //TODO: completion with error
                })
                
            MetaWearScanner.shared.stopScan()
                
            }
        }
    }
}

protocol MetaWearManagerDelegate {
    func connected()
}
