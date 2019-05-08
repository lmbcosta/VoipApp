//
//  Call+CoreDataProperties.swift
//  VoipApp
//
//  Created by Luis  Costa on 08/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//
//

import Foundation
import CoreData


extension Call {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Call> {
        return NSFetchRequest<Call>(entityName: "Call")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var type: String
    @NSManaged public var date: NSDate?
    @NSManaged public var cantactedBy: Contact
    
    var callType: VoipModels.CallType {
        get { return VoipModels.CallType(rawValue: type)! }
        set { type = newValue.rawValue }
    }
}
