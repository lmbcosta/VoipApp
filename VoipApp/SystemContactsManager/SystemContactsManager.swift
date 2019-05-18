//
//  SystemContactsManager.swift
//  VoipApp
//
//  Created by Luis  Costa on 15/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit
import Contacts

final class SystemContactsManager {
    
    static let shared = SystemContactsManager()
    
    private lazy var store = CNContactStore.init()
    
    private var granted = false
    
    enum Operation {
        case create(contact: VoipModels.VoipContact)
        case edit(contact: VoipModels.VoipContact)
        case delete(identifier: String)
    }
    
    private init() {}
    
    func askRequestAccess(then handler: @escaping (Bool) -> Void ) {
        store.requestAccess(for: .contacts) { [weak self] (granted, error) in
            guard error == nil else { return handler(false) }
            guard granted else { return handler(false) }
            
            self?.granted = true
            
            handler(true)
        }
    }
    
    func createDummyContact(then handler: @escaping (Bool) -> Void) {
        guard granted else { return handler(false) }
        
        let contact = VoipModels.VoipContact.init(entityId: nil, firstName: "Voip", familyName: "Dummy Contact", number: "999999999", isVoipNumber: true, identifier: nil, avatar: UIImage.init(named: "milu"))
        createContact(contact: contact, then: handler)
        
    }
    
    func execute(operation: SystemContactsManager.Operation, then handler: (Bool) -> Void) {
        guard granted else { return handler(false) }
        
        switch operation {
        case .create(let contact):
            createContact(contact: contact, then: handler)
        case .delete(let identifier):
            deleteContact(identifier: identifier, then: handler)
        case .edit(let contact):
            updateContact(contact: contact, then: handler)
        }
    }
    
    func fetchSectionedContacts(matchingIdsAndNumbers tuples: [(Int32, String)], then handler: @escaping ([VoipModels.ContactSection]?) -> Void) {
        guard granted else { return handler(nil) }
        
        var dictionary: [String: VoipModels.ContactSection] = [:]
        
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey]
        let fetchRequest = CNContactFetchRequest.init(keysToFetch: keysToFetch as [CNKeyDescriptor])
        
        do {
            try store.enumerateContacts(with: fetchRequest) { (contact, _) in
                
                let name = contact.givenName + " " + contact.familyName
                
                print("Name: \(name)")
                
                guard let number = contact.phoneNumbers.first?.value.stringValue.formatAsPhoneNumber() else { return handler(nil) }
                
                var entityId: Int32?
                let isVoipNumber = tuples.first(where: { (voipId, phoneNumber) -> Bool in
                    guard phoneNumber == number else { return false }
                    entityId = voipId
                    return true
                })
                
                var avatar: UIImage? {
                    guard let data = contact.imageData else { return nil }
                    return UIImage.init(data: data)
                }
                
                let voipContact = VoipModels.VoipContact.init(entityId: entityId, firstName: contact.givenName, familyName: contact.familyName, number: number, isVoipNumber: (isVoipNumber != nil), identifier: contact.identifier, avatar: avatar)
                
                let key = name.prefix(1).capitalized
                
                if let value = dictionary[key] {
                    let contacts = value.contacts
                    dictionary[key]?.contacts = contacts + [voipContact]
                }
                else {
                    dictionary[key] = VoipModels.ContactSection(title: key, contacts: [voipContact])
                }
                
                let sections = dictionary.sorted(by: { $1.key > $0.key })
                                         .map({ $0.value })
                
                handler(sections)
            }
        }
        catch { handler(nil) }
    }
}

private extension SystemContactsManager {
    func createContact(contact: VoipModels.VoipContact, then handler: (Bool) -> Void) {
        let giveNamePredicate = CNContact.predicateForContacts(matchingName: contact.name)
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactPhoneNumbersKey as CNKeyDescriptor])
        
        fetchRequest.predicate = giveNamePredicate
        
        var result = 0
        
        do {
            try? store.enumerateContacts(with: fetchRequest) { (contact, _) in
                result += 1
            }
            
            guard  result == 0 else {
                return handler(false)
            }
            
            let newContact = CNMutableContact()
            newContact.givenName = contact.firstName
            newContact.familyName = contact.familyName
            
            if let image = contact.avatar {
                newContact.imageData = image.pngData()
            }
            
            newContact.phoneNumbers = [
                CNLabeledValue(
                label: CNLabelPhoneNumberMain,
                value: CNPhoneNumber(stringValue: contact.number))
            ]
            
            let saveRequest = CNSaveRequest()
            saveRequest.add(newContact, toContainerWithIdentifier: nil)
            
            try store.execute(saveRequest)
            
            handler(true)
            
        } catch {
            handler(false)
        }
    }
    
    func updateContact(contact: VoipModels.VoipContact, then handler: (Bool) -> Void) {
        guard let identifier = contact.identifier else {
            return handler(false)
        }
        
        
        do {
            let keys = [
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactPhoneNumbersKey,
                CNContactImageDataKey
            ]
            
            let cn = try store.unifiedContact(withIdentifier: identifier, keysToFetch: keys as [CNKeyDescriptor])
            let contactToUpdate = cn.mutableCopy() as! CNMutableContact
            contactToUpdate.givenName = contact.firstName
            contactToUpdate.familyName = contact.familyName
            contactToUpdate.phoneNumbers = [
                CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: contact.number))
            ]
            
            if let image = contact.avatar {
                contactToUpdate.imageData = image.pngData()
            }
            
            let saveRequest = CNSaveRequest()
            saveRequest.update(contactToUpdate)
            try store.execute(saveRequest)
            
            handler(true)
        }
        catch {
            handler(false)
        }
    }
    
    func deleteContact(identifier: String, then handler: (Bool) -> Void) {
        do {
            let contact = try store.unifiedContact(withIdentifier: identifier, keysToFetch: [])
            let contactToDelete = contact.mutableCopy() as! CNMutableContact
            let saveRequest = CNSaveRequest()
            saveRequest.delete(contactToDelete)
            try store.execute(saveRequest)
            handler(true)
        }
        catch {
            return handler(false)
        }
    }
}
