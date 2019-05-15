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
    private lazy var store = CNContactStore.init()
    
    enum Operation {
        case create(contact: VoipModels.VoipContact)
        case edit(contact: VoipModels.VoipContact)
        case delete(identifier: String)
    }
    
    func execute(operation: SystemContactsManager.Operation, then handler: (Bool) -> Void) {
        switch operation {
        case .create(let contact):
            createContact(contact: contact, then: handler)
        case .delete(let identifier):
            deleteContact(identifier: identifier, then: handler)
        case .edit(let contact):
            updateContact(contact: contact, then: handler)
        }
    }
    
    func fetchSectionedContacts(matchingIdsAndNumbers tuples: [(Int32, String)]) -> [VoipModels.ContactSection] {
        var dictionary: [String: VoipModels.ContactSection] = [:]
        
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, error) in
            guard error == nil else { return }
            guard granted else { return }
        }
        
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let fetchRequest = CNContactFetchRequest.init(keysToFetch: keysToFetch as [CNKeyDescriptor])
        
        do {
            try store.enumerateContacts(with: fetchRequest) { (contact, _) in
                
                let name = contact.givenName + " " + contact.familyName
                guard let number = contact.phoneNumbers.first?.value.stringValue.formatAsPhoneNumber() else { return }
                
                var entityId: Int32?
                let isVoipNumber = tuples.first(where: { (voipId, phoneNumber) -> Bool in
                    guard phoneNumber == number else { return false }
                    entityId = voipId
                    return true
                })
                
                let voipContact = VoipModels.VoipContact.init(entityId: entityId, firstName: contact.givenName, familyName: contact.familyName, number: number, isVoipNumber: (isVoipNumber != nil), identifier: contact.identifier)
                
                let key = name.prefix(1).capitalized
                
                if var value = dictionary[key] {
                    let contacts = value.contacts
                    value.contacts = contacts + [voipContact]
                }
                else {
                    dictionary[key] = VoipModels.ContactSection(title: key, contacts: [voipContact])
                }
            }
        }
        catch {
            print("Error")
        }
        
        return dictionary.sorted(by: { $1.key > $0.key } )
                         .map({ $0.value })
        
    }
}

private extension SystemContactsManager {
    func createContact(contact: VoipModels.VoipContact, then handler: (Bool) -> Void) {
        let giveNamePredicate = CNContact.predicateForContacts(matchingName: contact.firstName)
        let familyNamePredicate = CNContact.predicateForContacts(matchingName: contact.familyName)
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactPhoneNumbersKey as CNKeyDescriptor])
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            giveNamePredicate,
            familyNamePredicate
        ])
        
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
        do {
            let cn = try store.unifiedContact(withIdentifier: contact.identifier, keysToFetch: [])
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
