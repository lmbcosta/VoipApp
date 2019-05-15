//
//  DatabaseManager.swift
//  VoipApp
//
//  Created by Luis  Costa on 15/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//


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
    func createVoipDummyCall() {
        let request = NSFetchRequest<Call>.init(entityName: Call.identifier)
        if let count = try? persistentContainer.viewContext.fetch(request).count, count == 0 {
            let call = NSEntityDescription.insertNewObject(forEntityName: Call.identifier, into: persistentContainer.viewContext) as! Call
            call.id = UUID()
            call.date = NSDate()
            call.callType = .incoming
            
            let myContact = NSEntityDescription.insertNewObject(forEntityName: Contact.identifier, into: persistentContainer.viewContext) as! Contact
            myContact.id = 1
            myContact.image = nil
            myContact.name = "Voip Dummy Contact"
            myContact.number = "999999999"
            myContact.addToCalls(call)
            
            saveContext()
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
    
    func deleteContact(withPhoneNumber number: String) {
        let fetchRequest = NSFetchRequest<Contact>.init(entityName: Contact.identifier)
        let predicate = NSPredicate(format: "number == %@", number)
        fetchRequest.predicate = predicate
        
        if let contact = try? persistentContainer.viewContext.fetch(fetchRequest).first {
            persistentContainer.viewContext.delete(contact)
            saveContext()
        }
    }
    
//    func updateContact(phoneNumber: String, name: String, image: UIImage?) {
//
//    }
    
    func fetchCalls() -> [Call]? {
        let request = NSFetchRequest<Call>.init(entityName: Call.identifier)
        request.sortDescriptors = [NSSortDescriptor.init(key: Defaults.dateProperty, ascending: false)]
        request.fetchLimit = Defaults.maxNumberOfResults
        
        return try? persistentContainer.viewContext.fetch(request)
    }
    
    func fetchContacts() -> [Contact]? {
        let request = NSFetchRequest<Contact>.init(entityName: Contact.identifier)
        request.fetchLimit = Defaults.maxNumberOfResults
        
        return try? persistentContainer.viewContext.fetch(request)
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
