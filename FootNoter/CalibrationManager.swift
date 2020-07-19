//
//  CalibrationManager.swift
//  FootNoter
//
//  Created by StudentAcct on 2/8/20.
//  Copyright © 2020 Sammmo. All rights reserved.
//

import Foundation

/**
 Calibration Manager calibrates a connected sensor
 It creates a Calibration which is an averaging of the x,y,z readings on a still foot
 */

class CalibrationManager {
    func saveAngles(_ angles: [EulerAngleObject]) {
        //no
    }
    
    func saveStep(_ stepTime: Date) {
        //no
    }
    
    
    var mwSensorManager: MetaWearManager!
    private var xList = [Double]()
    private var yList = [Double]()
    private var zList = [Double]()
    
    init(manager: MetaWearManager) {
        self.mwSensorManager = manager
        //manager.readingDelegate = self
    }
    
    func run(_ completion: @escaping (Calibration) -> ()) {
        if mwSensorManager.checkSensor() == .ready {

            calibrate { (calibration) in
                completion(calibration)
            }
            
        } else {
            //not ready for some reason
            print(mwSensorManager.checkSensor())
        }
    }
    
    func calibrate(_ completion: @escaping (Calibration) -> ()){
        
        mwSensorManager.startSensor()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.mwSensorManager.stopSensor()
            
            let xVal = self.xList.reduce(0, { a,b in
                a + b
            })
            
            let yVal = self.yList.reduce(0, { a,b in
                a + b
            })
            
            let zVal = self.zList.reduce(0, { a,b in
                a + b
            })
            
            let calibration = Calibration(x: (xVal / Double(self.xList.count)), y: (yVal / Double(self.yList.count)), z: (zVal / Double(self.zList.count)))
            
            completion(calibration)
        })
    }
    
    //MARK: Protocol stubs
    
    func getReading(x: Double, y: Double, z: Double) {
        xList.append(x)
        yList.append(y)
        zList.append(z)
    }
}
