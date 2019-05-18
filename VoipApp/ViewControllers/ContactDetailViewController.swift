//
//  ContactDetailViewController.swift
//  VoipApp
//
//  Created by Luis  Costa on 12/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit

protocol ContactDetailsDelegate: class {
    func contactDetail(didUpdateContact contact: VoipModels.VoipContact, with operation: VoipModels.OperationResult)
}

class ContactDetailViewController: UIViewController {

    // UI
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            
            collectionView.register(UINib(nibName: AvatarCell.identifier, bundle: nil),
                                    forCellWithReuseIdentifier: AvatarCell.identifier)
            collectionView.register(UINib(nibName: TextFieldCell.identifier, bundle: nil),
                                    forCellWithReuseIdentifier: TextFieldCell.identifier)
        }
    }
    
    private var fields: [VoipModels.ContactField] = [
        .avatar(image: nil),
        .text(title: Strings.firstNameText, input: .name(text: "")),
        .text(title: Strings.familyNameText, input: .name(text: "")),
        .text(title: Strings.phoneNumberText, input: .phoneNumber(text: ""))
    ]
    
    private var contactEntity: Int32?
    private var contactIdentifier: String?
    private var isNewContact: Bool = false
    
    weak var delegate: ContactDetailsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildRightButtonItem()
    }
    
    func setContact(contact: VoipModels.VoipContact?, delegate: ContactDetailsDelegate?) {
        self.delegate = delegate
        
        guard let contact = contact else {
            isNewContact = true
            return
        }
        
        self.contactEntity = contact.entityId
        self.contactIdentifier = contact.identifier
        
        let fields: [VoipModels.ContactField] = [
            .avatar(image: contact.avatar),
            .text(title: Strings.firstNameText, input: .name(text: contact.firstName)),
            .text(title: Strings.familyNameText, input: .name(text: contact.familyName)),
            .text(title: Strings.phoneNumberText, input: .phoneNumber(text: contact.number))
        ]
        
        self.fields = fields
    }
}

private extension ContactDetailViewController {
    func buildRightButtonItem() {
        let title = Strings.saveText
        let rightButtonItem = UIBarButtonItem.init(title: title, style: .plain, target: self, action: #selector(didTapRightButtonItem))
        navigationItem.setRightBarButton(rightButtonItem, animated: true)
    }
    
    @objc func didTapRightButtonItem() {
        validateInputs()
    }
    
    func validateInputs() {
        let inputs = fields.compactMap({ $0.getText() })
        guard inputs.count == fields.count - 1 else {
            showError(then: { [weak self] in
                self?.navigationItem.rightBarButtonItem?.title = Strings.saveText
            })
            return
        }
        
        guard let contact = buildContact() else { return }
        saveContact(contact: contact) { [weak self] success in
            guard let self = self else { return }
            
            let name = contact.name
            var message = ""
            
            var opResult: VoipModels.OperationResult
            
            if self.isNewContact {
                opResult = .create(success)
                message = success ?
                    String(format: "%@ contact was created with success", name) :
                    String(format: "Unable to create contact with name %@", name)
            }
            else {
                opResult = .update(success)
                message = success ?
                    String(format: "%@ contact was edited with success", name) :
                    String(format: "Unable to edit contact with name %@", name)
            }
            
            let alertController = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(.init(title: "OK", style: .default, handler: { [weak self] _ in
                self?.delegate?.contactDetail(didUpdateContact: contact, with: opResult)
                self?.navigationController?.popViewController(animated: true)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showError(then handler: @escaping () -> Void) {
        let alert = UIAlertController.init(title: Strings.errorTitle, message: Strings.mandatoryFieldText, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: Strings.alertButtonText, style: .default, handler: nil))
        present(alert, animated: true, completion: handler)
    }
    
    func buildContact() -> VoipModels.VoipContact? {
        guard case let .avatar(image) = fields[FieldIndex.avatar] else { return nil }
        guard case let .text(_, .name(firstName)) = fields[FieldIndex.firstName] else { return nil }
        guard case let .text(_, .name(familyName)) = fields[FieldIndex.familyName] else { return nil }
        guard case let .text(_, .phoneNumber(phoneNumber)) = fields[FieldIndex.phoneNumber] else { return nil }
        
        return VoipModels.VoipContact(entityId: contactEntity, firstName: firstName!, familyName: familyName!, number: phoneNumber!, isVoipNumber: true, identifier: contactIdentifier, avatar: image)
    }
    
    func saveContact(contact: VoipModels.VoipContact, then handler: @escaping (Bool) -> Void) {
        // CREATE
        if isNewContact {
            SystemContactsManager.shared.execute(operation: .create(contact: contact)) { success in
                guard success else { return handler(false) }
                DatabaseManager.shared.createContact(newContact: contact, then: { success in
                    handler(success)
                })
            }
        }
        else {
            // UPDATE
            SystemContactsManager.shared.execute(operation: .edit(contact: contact)) { success in
                guard success else { return handler(false) }
                DatabaseManager.shared.updateContact(updatedContact: contact, then: { success in
                    handler(success)
                })
            }
        }
    }
    
    struct Strings {
        static let firstNameText = "First Name:"
        static let familyNameText = "Family Name:"
        static let phoneNumberText = "Phone Number Text:"
        static let errorTitle = "Error"
        static let mandatoryFieldText = "Mandatory Field Text"
        static let alertButtonText = "OK"
        static let editText = "Edit"
        static let saveText = "Save"
    }
    
    struct FieldIndex {
        static let avatar = 0
        static let firstName = 1
        static let familyName = 2
        static let phoneNumber = 3
    }
}

// MARK: - UICollectionViewDataSource
extension ContactDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fields.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch fields[indexPath.item] {
        case .avatar(let image):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarCell.identifier, for: indexPath) as! AvatarCell
            cell.configure(with: image, isEditable: true, delegate: self)
            return cell
            
        case .text(let title, let input):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextFieldCell.identifier, for: indexPath) as! TextFieldCell
            cell.configure(title: title, input: input, index: indexPath.item, delegate: self)
            return cell
        }
    }
}

extension ContactDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        var height: CGFloat = 0
        
        switch fields[indexPath.item] {
        case .avatar: height = AvatarCell.height
        case .text: height = TextFieldCell.height
        }
        
        return .init(width: width, height: height)
    }
}

// MARK: - AvatarCellDelegate
extension ContactDetailViewController: AvatarCellDelegate {
    func avatarCell(_ avatarCell: AvatarCell, didSelect image: UIImage) {
        fields[FieldIndex.avatar] = VoipModels.ContactField.avatar(image: image)
    }
    
    func avatarCell(_ avatarCell: AvatarCell, willPresent controller: UIViewController) {
        present(controller, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension ContactDetailViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let index = textField.tag
        let text = textField.text
        
        guard case .text(let title, _) = fields[index] else { return }
        
        let input: VoipModels.Input = index == FieldIndex.phoneNumber ?
            .phoneNumber(text: text) :
            .name(text: text)
        
        fields[index] = .text(title: title, input: input)
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return view.endEditing(true)
    }
}
