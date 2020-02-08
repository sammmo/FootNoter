//
//  MainVC.swift
//  FootNoter
//
//  Controls the first screen that comes up on the app
//

import Foundation
import UIKit

class MainVC: UIViewController, MetaWearManagerDelegate {

    var metaWearManager: MetaWearManager!
    
    //MARK: - UI Outlet Variables
    @IBOutlet weak var lblSensorStatus: UILabel!
    @IBOutlet weak var lblMacAddress: UILabel!
    @IBOutlet weak var lblBattery: UILabel!
    @IBOutlet weak var lblStepCount: UILabel!
    @IBOutlet weak var lblOrientation: UILabel!
    
    //MARK: - UI Overrides
    
    override func viewDidLoad() {
        
        metaWearManager = MetaWearManager()
        metaWearManager.delegate = self
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
    
    func updateOrientation(facing: SensorFacing, orientation: SensorOrientation) {
        //var face: String
        //var orient: String
        DispatchQueue.main.async {
            self.lblOrientation.text = "\(facing) \(orientation)"
        }
        
      }
      
    
    //MARK: - Functions called directly by UI components
    /**
     Begins the MetaWear Manager scanning protocol (user intiated)
    **/
    @IBAction func scanPressed(_ sender: Any) {
        if let manager = metaWearManager {
            manager.locateNearbySensors()
        }
    }
    
    @IBAction func calibratePressed(_ sender: Any) {
        //TODO: implement calibration
    }
}
