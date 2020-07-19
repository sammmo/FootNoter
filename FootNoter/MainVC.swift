//
//  MainVC.swift
//  FootNoter
//
//  Controls the first screen that comes up on the app
//

import Foundation
import UIKit

class MainVC: UIViewController, MetaWearManagerDelegate {
    func updateAngle(angle: Double) {
        updateAngleLabel(angle: angle)
    }
    
    
    var metaWearManager: MetaWearManager!
    var calibration: Calibration? //TODO: this is only temporary until persisted into CoreDB
    
    //MARK: - UI Outlet Variables
    @IBOutlet weak var lblSensorStatus: UILabel!
    @IBOutlet weak var lblMacAddress: UILabel!
    @IBOutlet weak var lblBattery: UILabel!
    @IBOutlet weak var lblStepCount: UILabel!
    @IBOutlet weak var lblOrientation: UILabel!
    @IBOutlet weak var lblAngle: UILabel!
    
    //MARK: - UI Overrides
    
    override func viewDidLoad() {
      if #available(iOS 13.0, *) {
          // Always adopt a light interface style.
          overrideUserInterfaceStyle = .light
      }
    }
    
    func startSensing() {
        if metaWearManager.checkSensor() == .ready {
            metaWearManager.startSensor()
        } else {
            print("can't start sensing bc \(metaWearManager.checkSensor())")
        }
    }
    
    //MARK: - Delegate protocol implementation
    /**
     Called by manager delegate to notify view controller that a sensor has been connected
    **/
    func update(mac: String, battery: String, connection: ConnectionStatus) {
        
        DispatchQueue.main.async {
            self.lblMacAddress.text = mac
            
            switch connection {
            case .connected:
                self.lblSensorStatus.text = "You are connected!"
                break
            case .disconnected:
                self.lblSensorStatus.text = "You are disconnected!"
                break
            }
        }
       }
    
    func updateSteps(count: Int) {
        DispatchQueue.main.async {
            self.lblStepCount.text = "\(count)"
        }
    }
    
    func updateAngleLabel(angle: Double) {
        DispatchQueue.main.async {
            self.lblAngle.text = String(format: "%.1f", angle)
        }
    }
    
    func updateOrientation(facing: SensorFacing, orientation: SensorOrientation) {
        //var face: String
        //var orient: String
        DispatchQueue.main.async {
            self.lblOrientation.text = "\(facing) \(orientation)"
        }
      }
    
    func saveStep(_ stepTime: Date) {
         print("trying to save")
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.saveStep(stepTime)
        }
    }
      
    
    //MARK: - Functions called directly by UI components
    /**
     Begins the MetaWear Manager scanning protocol (user intiated)
    **/
    @IBAction func scanPressed(_ sender: Any) {
        if let manager = metaWearManager {
            manager.locateNearbySensors()
        } else {
            metaWearManager = MetaWearManager()
            metaWearManager.delegate = self
            metaWearManager.locateNearbySensors()
        }
    }
    
    @IBAction func startStepPressed(_ sender: Any) {
        startSensing()
    }
    
    @IBAction func calibratePressed(_ sender: Any) {
        let manager = CalibrationManager(manager: metaWearManager)
        manager.run { (calibration) in
            //TODO: save calibration to coredata
            self.calibration = calibration
            print(calibration)
        }
    }
}
