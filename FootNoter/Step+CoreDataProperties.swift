//
//  Step+CoreDataProperties.swift
//  FootNoter
//
//  Created by StudentAcct on 2/8/20.
//  Copyright © 2020 Sammmo. All rights reserved.
//
//

import Foundation
import CoreData


extension Step {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Step> {
        return NSFetchRequest<Step>(entityName: "Step")
    }

    @NSManaged public var timestamp: Date?

}
