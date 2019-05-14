//
//  ContactListViewController.swift
//  VoipApp
//
//  Created by Luis  Costa on 12/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit
import Contacts
import CoreData

class ContactListViewController: UIViewController {

    // UI
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    private lazy var managedContext: NSManagedObjectContext = self.appDelegate.managedContext
    private var colors: [UIColor] = [.red, .blue, .green, .yellow, .lightGray]
    private var segmentedControl: UISegmentedControl!
    private var allSections: [VoipModels.ContactSection] = []
    private var filteredSections: [VoipModels.ContactSection] = []
    
    var currectSections: [VoipModels.ContactSection] {
        return segmentedControl.selectedSegmentIndex == Defaults.allIndex ?
            allSections : filteredSections
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupSegmentedControll()
        
        fetchContacts()
    }
}

// MARK: - UITableViewDelegate
extension ContactListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = UIView()
            header.backgroundColor = .white
            header.addSubview(segmentedControl)
            return header
        }
        
        let view = UIView()
        view.backgroundColor = .lightGray
        let label = UILabel(frame: CGRect.init(x: 20, y: 0, width: tableView.frame.width - 20, height: Defaults.contactsHeaderHeight))
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.text = currectSections[section - 1].title
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? Defaults.segmentedHeaderHeight : Defaults.contactsHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 0 }
        return VoipContactCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = currectSections[indexPath.section - 1].contacts[indexPath.item]
        showContactAlert(to: contact)
    }
}

// MARK: - UITableViewDataSource
extension ContactListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return currectSections.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section > 0 else { return 0 }
        
        return currectSections[section - 1].contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = currectSections[indexPath.section - 1].contacts[indexPath.item]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: VoipContactCell.identifier, for: indexPath) as! VoipContactCell
        cell.configure(name: model.name, phoneNumber: model.number, isVoipNumber: model.isVoipNumber)
        return cell
    }
}

// MARK: - Private Functions
private extension ContactListViewController {
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = Strings.titleText
        
        let addButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addNewContactButtonTapped))
        navigationItem.setRightBarButton(addButtonItem, animated: false)
    }
    
    func setupSegmentedControll() {
        let segmentedControl = UISegmentedControl(frame: CGRect(x: Defaults.segmentedHorozontalInset, y: Defaults.segmentedVerticalInset, width: tableView.frame.width - Defaults.segmentedHorozontalInset * 2, height: Defaults.segmentedHeight))
        segmentedControl.insertSegment(withTitle: Strings.allContactsText, at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: Strings.voipContactsText, at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = Defaults.allIndex
        segmentedControl.addTarget(self, action: #selector(segmentedTapped(sender:)), for: .valueChanged)
        
        self.segmentedControl = segmentedControl
    }
    
    func fetchContacts() {
        var dictionary: [String: VoipModels.ContactSection] = [:]
        
        let store = CNContactStore()
        let filterNumbers = fetchVoipAppContactNumbers()
        
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
                let isVoipNumber = filterNumbers.first(where: { $0 == number }) != nil
                
                let voipContact = VoipModels.VoipContact.init(name: name, number: number, isVoipNumber: isVoipNumber)
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
        
        allSections = dictionary.sorted(by: { $1.key > $0.key } )
                             .map({ $0.value })
        
        allSections.forEach { section in
            let contacts = section.contacts.filter({ $0.isVoipNumber })
            if !contacts.isEmpty {
                filteredSections.append(VoipModels.ContactSection.init(title: section.title, contacts: contacts))
            }
        }
    }
    
    func fetchVoipAppContactNumbers() -> [String] {
        let request = NSFetchRequest<Contact>.init(entityName: Contact.identifier)
        
        guard let contacts = try? managedContext.fetch(request) else {
            return []
        }
        
        return contacts.compactMap({ $0.number })
    }
    
    func showContactAlert(to contact: VoipModels.VoipContact) {
        tableView.isUserInteractionEnabled = false
        let isValidContact = contact.isVoipNumber
        let title = Strings.alertTitleText
        let message = isValidContact ? Strings.alertValidContactMessageString : Strings.alertInvalidContactMessageString
        let alert = UIAlertController.init(title: title, message: String.init(format: message, contact.name), preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: Strings.alertButtonTitleText, style: .default, handler: { [weak self] _ in
            self?.tableView.isUserInteractionEnabled = true
            guard isValidContact else { return }
            
            self?.createCall(to: contact)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func createCall(to contact: VoipModels.VoipContact) {
        let fetchRequest = NSFetchRequest<Contact>.init(entityName: Contact.identifier)
        let predicate = NSPredicate.init(format: "%K == %@ AND %K == %@", "number", contact.number, "name", contact.name)
        fetchRequest.predicate = predicate
        
        if let voipContact = try? managedContext.fetch(fetchRequest).first {
            let call = NSEntityDescription.insertNewObject(forEntityName: Call.identifier, into: managedContext) as! Call
            call.id = UUID()
            call.date = NSDate()
            call.callType = .incoming
            call.cantactedBy = voipContact
            appDelegate.saveContext()
        }
    }
    
    @objc func segmentedTapped(sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    @objc func addNewContactButtonTapped() {
        // TODO:
    }
    
    struct Strings {
        static let titleText = "Contacts"
        static let allContactsText = "All Contacts"
        static let voipContactsText = "Voip Contacts"
        static let alertTitleText = "Voip App"
        static let alertValidContactMessageString = "You received a call from %@, please check your history"
        static let alertInvalidContactMessageString = "%@ is not a Voip Contact. Please select another"
        static let alertButtonTitleText = "OK"
        
    }
    
    struct Defaults {
        static let segmentedHorozontalInset: CGFloat = 10
        static let segmentedVerticalInset: CGFloat = 15
        static let segmentedHeight: CGFloat = 30
        static let segmentedHeaderHeight: CGFloat = 60
        static let contactsHeaderHeight: CGFloat = 20
        static let allIndex = 0
        static let voipIndex = 1
    }
}



