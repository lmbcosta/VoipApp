//
//  ContactListViewController.swift
//  VoipApp
//
//  Created by Luis  Costa on 12/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit
import CoreData


class ContactListViewController: UIViewController {

    // UI
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    private lazy var systemContactManager = SystemContactsManager.shared
    private lazy var databaseManager = DatabaseManager.shared
    private var segmentedControl: UISegmentedControl!
    private var allSections: [VoipModels.ContactSection] = []
    private var filteredSections: [VoipModels.ContactSection] = []
    
    private var currectSections: [VoipModels.ContactSection] {
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
        let label = UILabel(frame: CGRect.init(x: 20, y: 0, width: self.view.frame.width - 20 * 2, height: Defaults.contactsHeaderHeight))
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return currectSections[indexPath.section - 1].contacts[indexPath.item].isVoipNumber
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction.init(style: .default, title: "Edit") { [weak self] (action, indexPath) in
            guard let self = self else { return }
            
            let contact = self.currectSections[indexPath.section - 1].contacts[indexPath.item]
            self.presentDetail(for: contact)
        }
        editAction.backgroundColor = .system
        
        let deleteAction = UITableViewRowAction.init(style: .default, title: "Delete") { [weak self] (action, indexPath) in
            guard let self = self else { return }
            
            let contact = self.currectSections[indexPath.section - 1].contacts[indexPath.item]
            
            guard let identifier = contact.identifier else { return }
            guard let entityId = contact.entityId else { return }
            
            SystemContactsManager.shared.execute(operation: .delete(identifier: identifier), then: { [weak self] success in
                guard success else {
                    self?.showAlert(forDelete: .delete(success))
                    return
                }
                
                self?.databaseManager.deleteContact(withId: entityId, then: { success in
                    self?.showAlert(forDelete: .delete(success))
                })
            })
        }
        deleteAction.backgroundColor = .red
        
        return [deleteAction, editAction]
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

// MARK: - ContactDetailDelegate
extension ContactListViewController: ContactDetailsDelegate {
    func contactDetail(didUpdateContact contact: VoipModels.VoipContact, with operation: VoipModels.OperationResult) {
        fetchContacts()
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
        let segmentedControl = UISegmentedControl(frame: CGRect(x: Defaults.segmentedHorozontalInset, y: Defaults.segmentedVerticalInset, width: view.bounds.width - Defaults.segmentedHorozontalInset * 2, height: Defaults.segmentedHeight))
        segmentedControl.insertSegment(withTitle: Strings.allContactsText, at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: Strings.voipContactsText, at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = Defaults.allIndex
        segmentedControl.addTarget(self, action: #selector(segmentedTapped(sender:)), for: .valueChanged)
        
        self.segmentedControl = segmentedControl
    }
    
    func fetchContacts() {
        
        // Fetch DB Contacts
        databaseManager.fetchContacts { [weak self] contacts in
            guard let contacts = contacts else { return }
            
            var tuples = [(Int32, String)]()
            contacts.forEach({ tuples.append(($0.id, $0.number!)) })
            
            // Fetch System Contacts
            self?.systemContactManager.fetchSectionedContacts(matchingIdsAndNumbers: tuples, then: { [weak self] sections in
                guard let sections = sections else { return }
                
                self?.allSections = sections
                
                // Reset Filters Sections
                //self?.filteredSections.removeAll()
                self?.filteredSections = []
                
                self?.allSections.forEach { section in
                    let contacts = section.contacts.filter({ $0.isVoipNumber })
                    if !contacts.isEmpty {
                        self?.filteredSections.append(VoipModels.ContactSection.init(title: section.title, contacts: contacts))
                    }
                }
                
                self?.tableView.reloadData()
            })
        }
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
            
            self?.databaseManager.createReceivingCall(fromNumber: contact.number, withName: contact.name, then: { [weak self] _ in
                self?.navigateToCallHistory()
            })
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func navigateToCallHistory() {
        guard let tabBar = self.appDelegate.window?.rootViewController as? TabBarViewController else { return }
        tabBar.routeToCallHistory()
    }
    
    @objc func segmentedTapped(sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    @objc func addNewContactButtonTapped() { presentDetail() }
    
    func presentDetail(for contact: VoipModels.VoipContact? = nil) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "contact-detail-view-controller") as? ContactDetailViewController else { return  }
        detailVC.setContact(contact: contact, delegate: self)
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func showAlert(forDelete result: VoipModels.OperationResult) {
        guard case let .delete(success) = result else { return }
        
        let message = success ? Strings.successDeleteText : Strings.errorDeleteText
        
        let alert = UIAlertController.init(title: Strings.titleText, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: Strings.titleText, style: .default, handler: { [weak self] _ in
            self?.fetchContacts()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    struct Strings {
        static let titleText = "Contacts"
        static let allContactsText = "All Contacts"
        static let voipContactsText = "Voip Contacts"
        static let alertTitleText = "Voip App"
        static let alertValidContactMessageString = "You received a call from %@!"
        static let alertInvalidContactMessageString = "%@ is not a Voip Contact. Please select another"
        static let alertButtonTitleText = "OK"
        static let firstNameText = "First Name:"
        static let familyNameText = "Family Name:"
        static let phoneNumberText = "Phone Number Text:"
        static let errorDeleteText = "Unable to delete contact"
        static let successDeleteText = "Contact successfully deleted"
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



