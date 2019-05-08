//
//  Contact+CoreDataProperties.swift
//  VoipApp
//
//  Created by Luis  Costa on 08/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//
//

import Foundation
import CoreData

extension Contact {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var image: NSDate?
    @NSManaged public var number: String?
    @NSManaged public var calls: NSOrderedSet
}

// MARK: Generated accessors for calls
extension Contact {

    @objc(insertObject:inCallsAtIndex:)
    @NSManaged public func insertIntoCalls(_ value: Call, at idx: Int)

    @objc(removeObjectFromCallsAtIndex:)
    @NSManaged public func removeFromCalls(at idx: Int)

    @objc(insertCalls:atIndexes:)
    @NSManaged public func insertIntoCalls(_ values: [Call], at indexes: NSIndexSet)

    @objc(removeCallsAtIndexes:)
    @NSManaged public func removeFromCalls(at indexes: NSIndexSet)

    @objc(replaceObjectInCallsAtIndex:withObject:)
    @NSManaged public func replaceCalls(at idx: Int, with value: Call)

    @objc(replaceCallsAtIndexes:withCalls:)
    @NSManaged public func replaceCalls(at indexes: NSIndexSet, with values: [Call])

    @objc(addCallsObject:)
    @NSManaged public func addToCalls(_ value: Call)

    @objc(removeCallsObject:)
    @NSManaged public func removeFromCalls(_ value: Call)

    @objc(addCalls:)
    @NSManaged public func addToCalls(_ values: NSOrderedSet)

    @objc(removeCalls:)
    @NSManaged public func removeFromCalls(_ values: NSOrderedSet)

}
