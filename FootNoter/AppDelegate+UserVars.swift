//
//  AppDelegate+UserVars.swift
//  FootNoter
//
//  Created by StudentAcct on 1/16/20.
//  Copyright © 2020 Sammmo. All rights reserved.
//
//  Extension for getting/setting UserDefault settings in AppDelegate
//  These are changed only from SettingsVC but can be accessed all over the app
//  If no default has been set in UserDefaults, each getter is told an else value to provide instead of nil
//

import Foundation

extension AppDelegate {
    
    var earphoneTone: Bool {
        get {
            if let earphoneTone = UserDefaults.standard.object(forKey: "earphoneTone") as? Bool {
                return earphoneTone
            } else {
                return true
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "earphoneTone")
        }
    }
    var externalVibe: Bool {
        get {
            if let externalVibe = UserDefaults.standard.object(forKey: "externalVibe") as? Bool {
                return externalVibe
            } else {
                return false
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "externalVibe")
        }
    }
    var foot: Foot {
         get {
             if let foot = UserDefaults.standard.object(forKey: "foot") as? String {
                 if foot == "left" {
                     return .left
                 } else {
                     return .right
                 }
             } else {
                 return .right
             }
         }
         
         set {
             if newValue == .left {
                 UserDefaults.standard.set("left", forKey: "foot")
             } else {
                 UserDefaults.standard.set("right", forKey: "foot")
             }
             
         }
    }
    
    var musicInterrupt: Bool {
        get {
            if let musicInterrupt = UserDefaults.standard.object(forKey: "musicInterrupt") as? Bool {
                return musicInterrupt
            } else {
                return true
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "musicInterrupt")
        }
    }
    
    var numSteps: Int {
        get {
            if let numSteps = UserDefaults.standard.object(forKey: "numSteps") as? Int {
                return numSteps
            } else {
                return 3
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "numSteps")
        }
    }
    
    var pushNotify: Bool {
        get {
            if let pushNotify = UserDefaults.standard.object(forKey: "pushNotify") as? Bool {
                return pushNotify
            } else {
                return true
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "pushNotify")
        }
    }
    
    var screenDisplay: Bool {
        get {
            if let screenDisplay = UserDefaults.standard.object(forKey: "screenDisplay") as? Bool {
                return screenDisplay
            } else {
                return true
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "screenDisplay")
        }
    }
    
    var shoeVibe: Bool {
        get {
            if let shoeVibe = UserDefaults.standard.object(forKey: "shoeVibe") as? Bool {
                return shoeVibe
            } else {
                return true
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "shoeVibe")
        }
    }
    
}

