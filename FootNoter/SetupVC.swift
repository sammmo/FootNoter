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

class SetupVC: UIViewController {
    
    var settings: Settings?
    
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
    **/
    override func viewDidLoad() {
        if let set = settings {
            if set.foot == "left" {
                sgmFoot.selectedSegmentIndex = 0
            } else {
                sgmFoot.selectedSegmentIndex = 1
            }
            
            if set.numSteps == 1 {
                sgmNumberOfSteps.selectedSegmentIndex = 0
            } else if set.numSteps == 2 {
                sgmNumberOfSteps.selectedSegmentIndex = 1
            } else if set.numSteps == 3 {
                sgmNumberOfSteps.selectedSegmentIndex = 2
            } else if set.numSteps == 4 {
                sgmNumberOfSteps.selectedSegmentIndex = 3
            } else if set.numSteps == 5 {
                sgmNumberOfSteps.selectedSegmentIndex = 4
            } else if set.numSteps == 6 {
                sgmNumberOfSteps.selectedSegmentIndex = 5
            }
            
            if set.shoeVibe == true {
                swcShoeVibration.setOn(true, animated: true)
            } else {
                swcShoeVibration.setOn(false, animated: true)
            }
            
            if set.externalVibe == true {
                swcExternalVibration.setOn(true, animated: true)
            } else {
                swcExternalVibration.setOn(false, animated: true)
            }
            
            if set.earphoneTone == true {
                swcEarphoneTone.setOn(true, animated: true)
            } else {
                swcEarphoneTone.setOn(false, animated: true)
            }
            
            if set.musicInterrupt == true {
                swcMusicInterruption.setOn(true, animated: true)
            } else {
                swcMusicInterruption.setOn(false, animated: true)
            }
            
            if set.screenDisplay == true {
                swcScreenDisplay.setOn(true, animated: true)
            } else {
                swcScreenDisplay.setOn(false, animated: true)
            }
            
            if set.pushNotify == true {
                swcPushNotifications.setOn(true, animated: true)
            } else {
                swcPushNotifications.setOn(false, animated: true)
            }
        }
    }
    
    //MARK: - Private functions to deal with changes made to settings
    /**
     Changes the foot side in settings
     **/
    private func changeFoot(side: String) {
        if let set = settings {
            set.foot = side as NSString
            print("changed foot side to \(side)")
        }
    }
    
    /**
     Changes the number of footsteps in settings
     **/
    private func changeNumSteps(steps: Int) {
        if let set = settings {
            set.numSteps = steps
            print("changed number of steps to \(steps)")
        }
    }
    
    /**
    Changes the many settings booleans
     **/
    private func flipBool(bool: Bool, type: SettingsBool) {
        switch type {
        case .shoeVibe:
            if let set = settings {
                set.shoeVibe = bool
                print("shoe vibrations were set to \(bool)")
            }
            break
        case .externalVibe:
            if let set = settings {
                set.externalVibe = bool
                print("external vibration was set to \(bool)")
            }
            break
        case .earphoneTone:
            if let set = settings {
                set.earphoneTone = bool
                print("earphone tone was set to \(bool)")
            }
            break
        case .musicInterrupt:
            if let set = settings {
                set.musicInterrupt = bool
                print("music interruption was set to \(bool)")
            }
            break
        case .screenDisplay:
            if let set = settings {
                set.screenDisplay = bool
                print("screen display was set to \(bool)")
            }
            break
        case .pushNotify:
            if let set = settings {
                set.pushNotify = bool
                print("push notification was set to \(bool)")
            }
            break
        }
    }
    
    //MARK: - Functions called directly by UI components
    /**
     When the segment controller that refers to left/right side is used, this is called
     **/
    @IBAction func changeFootPressed(_ sender: Any) {
        if let segment = sender as? UISegmentedControl {
            switch segment.selectedSegmentIndex {
            case 0:
                changeFoot(side: "left")
                break
            case 1:
                changeFoot(side: "right")
                break
            default:
                break
            }
        }
    }
    
    /**
     When the segment controller that refers to the number of steps is used, this is called
     **/
    @IBAction func changeNumStepsPressed(_ sender: Any) {
        if let segment = sender as? UISegmentedControl {
            switch segment.selectedSegmentIndex {
            case 0:
                changeNumSteps(steps: 1)
                break
            case 1:
                changeNumSteps(steps: 2)
                break
            case 2:
                changeNumSteps(steps: 3)
                break
            case 3:
                changeNumSteps(steps: 4)
                break
            case 4:
                changeNumSteps(steps: 5)
                break
            case 5:
                changeNumSteps(steps: 6)
                break
            default:
                break
            }
        }
    }
    
    /**
     When the switch that refers to the shoe vibration is used, this is called
     **/
    @IBAction func changeShoeVibration(_ sender: Any) {
        if let segment = sender as? UISwitch {
            if segment.isOn {
                flipBool(bool: true, type: .shoeVibe)
            } else {
                flipBool(bool: false, type: .shoeVibe)
            }
        }
    }
    
    /**
     When the switch that refers to the external vibration is used, this is called
     **/
    @IBAction func changeExternalVibration(_ sender: Any) {
        if let segment = sender as? UISwitch {
            if segment.isOn {
                flipBool(bool: true, type: .externalVibe)
            } else {
                flipBool(bool: false, type: .externalVibe)
            }
        }
    }
    
    /**
     When the switch that refers to the earphone tone is used, this is called
     **/
    @IBAction func changeEarphoneTone(_ sender: Any) {
        if let segment = sender as? UISwitch {
            if segment.isOn {
                flipBool(bool: true, type: .earphoneTone)
            } else {
                flipBool(bool: false, type: .earphoneTone)
            }
        }
    }
    
    /**
     When the switch that refers to music interruption is used, this is called
     **/
    @IBAction func changeMusicInterruption(_ sender: Any) {
        if let segment = sender as? UISwitch {
            if segment.isOn {
                flipBool(bool: true, type: .musicInterrupt)
            } else {
                flipBool(bool: false, type: .musicInterrupt)
            }
        }
    }
    
    /**
     When the switch that refers to the screen display, this is called
     **/
    @IBAction func changeScreenDisplay(_ sender: Any) {
        if let segment = sender as? UISwitch {
            if segment.isOn {
                flipBool(bool: true, type: .screenDisplay)
            } else {
                flipBool(bool: false, type: .screenDisplay)
            }
        }
    }
    
    /**
     When the switch that refers to push notifications is used, this is called
     **/
    @IBAction func changePushNotifications(_ sender: Any) {
        if let segment = sender as? UISwitch {
            if segment.isOn {
                flipBool(bool: true, type: .pushNotify)
            } else {
                flipBool(bool: false, type: .pushNotify)
            }
        }
    }
}
