//
//  EulerAngle+CoreDataProperties.swift
//  FootNoter
//
//  Created by StudentAcct on 2/8/20.
//  Copyright © 2020 Sammmo. All rights reserved.
//
//

import Foundation
import CoreData


extension EulerAngle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EulerAngle> {
        return NSFetchRequest<EulerAngle>(entityName: "EulerAngle")
    }

    @NSManaged public var yaw: Float
    @NSManaged public var pitch: Float
    @NSManaged public var heading: Float
    @NSManaged public var roll: Float
    @NSManaged public var timestamp: Date?

}
