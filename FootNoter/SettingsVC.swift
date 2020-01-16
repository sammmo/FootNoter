//
//  SetupVC.swift
//  FootNoter
//
//  Controls user interaction with the Settings.
//  If a setting is changed, it is persisted to the database.
//

import Foundation
import UIKit

enum SettingsBool {
    case shoeVibe, externalVibe, earphoneTone, musicInterrupt, screenDisplay, pushNotify
}

enum Foot: String {
    case left = "left"
    case right = "right"
}

class SettingsVC: UIViewController {
    
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: - Outlet variables
    @IBOutlet weak var sgmFoot: UISegmentedControl!
    @IBOutlet weak var sgmNumberOfSteps: UISegmentedControl!
    @IBOutlet weak var swcShoeVibration: UISwitch!
    @IBOutlet weak var swcExternalVibration: UISwitch!
    @IBOutlet weak var swcEarphoneTone: UISwitch!
    @IBOutlet weak var swcMusicInterruption: UISwitch!
    @IBOutlet weak var swcScreenDisplay: UISwitch!
    @IBOutlet weak var swcPushNotifications: UISwitch!
    
    //MARK: - UI Overrides
    /**
     When the view loads, this sets up the various displays to match the actual saved settings
    */
    override func viewDidLoad() {
    
        if appDelegate.foot == .left {
            sgmFoot.selectedSegmentIndex = 0
        } else {
            sgmFoot.selectedSegmentIndex = 1
        }
            
            if appDelegate.numSteps == 1 {
                sgmNumberOfSteps.selectedSegmentIndex = 0
            } else if appDelegate.numSteps == 2 {
                sgmNumberOfSteps.selectedSegmentIndex = 1
            } else if appDelegate.numSteps == 3 {
                sgmNumberOfSteps.selectedSegmentIndex = 2
            } else if appDelegate.numSteps == 4 {
                sgmNumberOfSteps.selectedSegmentIndex = 3
            } else if appDelegate.numSteps == 5 {
                sgmNumberOfSteps.selectedSegmentIndex = 4
            } else if appDelegate.numSteps == 6 {
                sgmNumberOfSteps.selectedSegmentIndex = 5
            }
            
            if appDelegate.shoeVibe == true {
                swcShoeVibration.setOn(true, animated: true)
            } else {
                swcShoeVibration.setOn(false, animated: true)
            }
            
            if appDelegate.externalVibe == true {
                swcExternalVibration.setOn(true, animated: true)
            } else {
                swcExternalVibration.setOn(false, animated: true)
            }
            
            if appDelegate.earphoneTone == true {
                swcEarphoneTone.setOn(true, animated: true)
            } else {
                swcEarphoneTone.setOn(false, animated: true)
            }
            
            if appDelegate.musicInterrupt == true {
                swcMusicInterruption.setOn(true, animated: true)
            } else {
                swcMusicInterruption.setOn(false, animated: true)
            }
            
            if appDelegate.screenDisplay == true {
                swcScreenDisplay.setOn(true, animated: true)
            } else {
                swcScreenDisplay.setOn(false, animated: true)
            }
            
            if appDelegate.pushNotify == true {
                swcPushNotifications.setOn(true, animated: true)
            } else {
                swcPushNotifications.setOn(false, animated: true)
            }
        
    }
    
    //MARK: - Functions called directly by UI components
    /**
     When the segment controller that refers to left/right side is used, this is called
     */
    @IBAction func changeFootPressed(_ sender: Any) {
        if let segment = sender as? UISegmentedControl {
            switch segment.selectedSegmentIndex {
            case 0:
                appDelegate.foot = .left
                break
            case 1:
                appDelegate.foot = .right
                break
            default:
                break
            }
        }
    }
    
    /**
     When the segment controller that refers to the number of steps is used, this is called
     */
    @IBAction func changeNumStepsPressed(_ sender: Any) {
        if let segment = sender as? UISegmentedControl {
            switch segment.selectedSegmentIndex {
            case 0:
                appDelegate.numSteps = 1
                break
            case 1:
                appDelegate.numSteps = 2
                break
            case 2:
                appDelegate.numSteps = 3
                break
            case 3:
              appDelegate.numSteps = 4
                break
            case 4:
                appDelegate.numSteps = 5
                break
            case 5:
               appDelegate.numSteps = 6
                break
            default:
                break
            }
        }
    }
    
    /**
     When the switch that refers to the shoe vibration is used, this is called
     */
    @IBAction func changeShoeVibration(_ sender: Any) {
        if let segment = sender as? UISwitch {
            if segment.isOn {
                appDelegate.shoeVibe = true
            } else {
                appDelegate.shoeVibe = false
            }
        }
    }
    
    /**
     When the switch that refers to the external vibration is used, this is called
     */
    @IBAction func changeExternalVibration(_ sender: Any) {
        if let segment = sender as? UISwitch {
            if segment.isOn {
                appDelegate.externalVibe = true
            } else {
                appDelegate.externalVibe = false
            }
        }
    }
    
    /**
     When the switch that refers to the earphone tone is used, this is called
     */
    @IBAction func changeEarphoneTone(_ sender: Any) {
        if let segment = sender as? UISwitch {
            if segment.isOn {
                appDelegate.earphoneTone = true
            } else {
                appDelegate.earphoneTone = false
            }
        }
    }
    
    /**
     When the switch that refers to music interruption is used, this is called
     */
    @IBAction func changeMusicInterruption(_ sender: Any) {
        if let segment = sender as? UISwitch {
            if segment.isOn {
                appDelegate.musicInterrupt = true
            } else {
                appDelegate.musicInterrupt = false
            }
        }
    }
    
    /**
     When the switch that refers to the screen display, this is called
     */
    @IBAction func changeScreenDisplay(_ sender: Any) {
        if let segment = sender as? UISwitch {
            if segment.isOn {
                appDelegate.screenDisplay = true
            } else {
                appDelegate.screenDisplay = false
            }
        }
    }
    
    /**
     When the switch that refers to push notifications is used, this is called
     */
    @IBAction func changePushNotifications(_ sender: Any) {
        if let segment = sender as? UISwitch {
            if segment.isOn {
                appDelegate.pushNotify = true
            } else {
                appDelegate.pushNotify = false
            }
        }
    }
}
