//
//  MainVC.swift
//  FootNoter
//
//  Controls the first screen that comes up on the app
//

import Foundation
import UIKit

class MainVC: UIViewController, MetaWearManagerDelegate {
    
    var settings: Settings?
    var metaWearManager: MetaWearManager?
    
    //MARK: - UI Outlet Variables
    @IBOutlet weak var lblSensorStatus: UILabel!
    @IBOutlet weak var lblMacAddress: UILabel!
    @IBOutlet weak var lblBattery: UILabel!
    
    //MARK: - UI Overrides
    
    override func viewDidLoad() {
        
        metaWearManager = MetaWearManager()
        metaWearManager.delegate = self
        
        //TODO: load settings from CoreData
    }
    
    //MARK: - Delegate protocol implementation
    /**
     Called by manager delegate to notify view controller that a sensor has been connected
    **/
    func connected() {
        lblSensorStatus.setText("You are connected!")
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
