//
//  Settings.swift
//  FootNoter
//
// Manged object class for saving settings
//

import Foundation
import CoreData

class Settings: NSManagedObject {

}

extension Settings {
    @NSManaged var foot: NSString
    @NSManaged var numSteps: NSInteger
    @NSManaged var shoeVibe: Bool
    @NSManaged var externalVibe: Bool
    @NSManaged var earphoneTone: Bool
    @NSManaged var musicInterrupt: Bool
    @NSManaged var screenDisplay: Bool
    @NSManaged var pushNotify: Bool
}

