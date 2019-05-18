//
//  DatabaseManager.swift
//  VoipApp
//
//  Created by Luis  Costa on 15/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit
import CoreData

final class DatabaseManager {
    static let shared = DatabaseManager()

    private init() {}
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VoipApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var generatedId: Int32 {
        if let entityId = UserDefaults.standard.value(forKey: "entityId") as? Int32 {
            UserDefaults.standard.set(entityId + 1, forKey: "entityId")
            return entityId + 1
        }
        else {
            UserDefaults.standard.set(0, forKey: "entityId")
            return 0
        }
    }
    
     func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// Public Functions
extension DatabaseManager {
    func createVoipDummyCall(then handler: (Bool) -> Void) {
        let request = NSFetchRequest<Call>.init(entityName: Call.identifier)
        
        do {
            let count = try persistentContainer.viewContext.fetch(request).count
            if count == 0 {
                let call = NSEntityDescription.insertNewObject(forEntityName: Call.identifier, into: persistentContainer.viewContext) as! Call
                call.id = UUID()
                call.date = NSDate()
                call.callType = .incoming
                
                let myContact = NSEntityDescription.insertNewObject(forEntityName: Contact.identifier, into: persistentContainer.viewContext) as! Contact
                myContact.id = generatedId
                myContact.image = UIImage(named: "milu")?.pngData() as NSData?
                myContact.name = "Voip Dummy Contact"
                myContact.number = "999999999"
                myContact.addToCalls(call)
                saveContext()
            }
            
            handler(true)
        }
        catch {
            handler(false)
        }
    }
    
    func createReceivingCall(fromNumber number: String, withName name: String, then handler: (Bool) -> Void) {
        let fetchRequest = NSFetchRequest<Contact>.init(entityName: Contact.identifier)
        let predicate = NSPredicate.init(format: "%K == %@ AND %K == %@", "number", number, "name", name)
        fetchRequest.predicate = predicate
        
        guard let contact = try? persistentContainer.viewContext.fetch(fetchRequest).first else {
            return handler(false)
        }
        
        let call = NSEntityDescription.insertNewObject(forEntityName: Call.identifier, into: persistentContainer.viewContext) as! Call
        call.id = UUID()
        call.date = NSDate()
        call.callType = .incoming
        call.cantactedBy = contact
        
        saveContext()
        
        handler(true)
    }
    
    func createCall(for contact: Contact, with type: VoipModels.CallType) {
        // Add new call to history calls
        let newRegisterCall = NSEntityDescription.insertNewObject(forEntityName: Call.identifier, into: persistentContainer.viewContext) as! Call
        newRegisterCall.callType = type
        newRegisterCall.date = NSDate()
        newRegisterCall.id = UUID()
        newRegisterCall.cantactedBy = contact
        saveContext()
    }
    
    func delete(call: Call) {
        persistentContainer.viewContext.delete(call)
        saveContext()
    }
    
    func deleteContact(withId id: Int32, then handler: (Bool) -> Void) {
        let fetchRequest = NSFetchRequest<Contact>.init(entityName: Contact.identifier)
        let predicate = NSPredicate(format: "id == %d", id)
        fetchRequest.predicate = predicate
        
        do {
            let contacts = try persistentContainer.viewContext.fetch(fetchRequest)
            
            guard let contact = contacts.first else { return handler(false) }
            
            persistentContainer.viewContext.delete(contact)
            saveContext()
            handler(true)
        }
        catch {
            handler(false)
        }
        
    }
    
    func updateContact(updatedContact: VoipModels.VoipContact, then handler: (Bool) -> Void) {
        guard let id = updatedContact.entityId else { return handler(false) }
        
        let fetchRequest = NSFetchRequest<Contact>.init(entityName: Contact.identifier)
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let contact = try persistentContainer.viewContext.fetch(fetchRequest).first
            contact?.number = updatedContact.number
            contact?.name = updatedContact.name
            if let image = updatedContact.avatar {
                contact?.image = image.pngData() as NSData?
            }
            saveContext()
            
            handler(true)
        }
        catch { handler(false) }
    }
    
    func createContact(newContact: VoipModels.VoipContact, then handler: @escaping (Bool) -> Void) {
        let fetchRequest = NSFetchRequest<Contact>.init(entityName: Contact.identifier)
        fetchRequest.predicate = NSPredicate(format: "number == %@ AND name == %@", newContact.number, newContact.name)
        
        do {
            guard try persistentContainer.viewContext.fetch(fetchRequest).first == nil else {
                return handler(false)
            }
            
            let contact =  NSEntityDescription.insertNewObject(forEntityName: Contact.identifier, into: persistentContainer.viewContext) as! Contact
            contact.id = generatedId
            contact.name = newContact.name
            contact.number = newContact.number
            if let image = newContact.avatar {
                contact.image = image.pngData() as NSData?
            }
            
            saveContext()
            
            handler(true)
        }
        catch { return handler(false) }
    }
    
    func fetchCalls(then handler: @escaping ([Call]?) -> Void) {
        let request = NSFetchRequest<Call>.init(entityName: Call.identifier)
        request.sortDescriptors = [NSSortDescriptor.init(key: Defaults.dateProperty, ascending: false)]
        request.fetchLimit = Defaults.maxNumberOfResults
        
        do {
            let calls = try persistentContainer.viewContext.fetch(request)
            handler(calls)
        }
        catch {
            handler(nil)
        }
    }
    
    func fetchContacts(then handler: @escaping ([Contact]?) -> Void){
        let request = NSFetchRequest<Contact>.init(entityName: Contact.identifier)
        request.fetchLimit = Defaults.maxNumberOfResults
        
        do {
            let contacts =  try persistentContainer.viewContext.fetch(request)
            handler(contacts)
        }
        catch {
            return handler(nil)
        }
    }
    
    func fetchDummyContact() -> Contact? {
        let request = NSFetchRequest<Contact>.init(entityName: Contact.identifier)
        request.predicate = NSPredicate(format: "id == %d", 1)
        
        return try? persistentContainer.viewContext.fetch(request).first
    }
}

private extension DatabaseManager {
    struct Defaults {
        static let dateProperty = "date"
        static let maxNumberOfResults = 50
    }
}
