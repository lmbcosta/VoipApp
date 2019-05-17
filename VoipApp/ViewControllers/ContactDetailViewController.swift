//
//  ContactDetailViewController.swift
//  VoipApp
//
//  Created by Luis  Costa on 12/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit

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
    
    private var items: [VoipModels.ContactField] = [
        .avatar(image: UIImage(named: "milu") ?? UIImage()),
        .text(title: Strings.firstNameText, input: .name(text: "")),
        .text(title: Strings.familyNameText, input: .name(text: "")),
        .text(title: Strings.phoneNumberText, input: .phoneNumber(text: ""))
    ]
    
    private var isEditable: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildRightButtonItem()
    }
}

private extension ContactDetailViewController {
    func buildRightButtonItem() {
        let title = isEditable ? Strings.saveText : Strings.editText
        let rightButtonItem = UIBarButtonItem.init(title: title, style: .plain, target: self, action: #selector(didTapRightButtonItem))
        navigationItem.setRightBarButton(rightButtonItem, animated: true)
    }
    
    @objc func didTapRightButtonItem() {
        isEditable = !isEditable
        navigationItem.rightBarButtonItem?.title = isEditable ? Strings.saveText : Strings.editText
        collectionView.reloadData()
        // TODO:
    }
    
    func showError() {
        let alert = UIAlertController.init(title: Strings.errorTitle, message: Strings.mandatoryFieldText, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: Strings.alertButtonText, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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

// MARK: - UICollectionViewDelegate
extension ContactDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension ContactDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO:
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch items[indexPath.item] {
        case .avatar(let image):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarCell.identifier, for: indexPath) as! AvatarCell
            cell.configure(with: image, isEditable: true, delegate: self)
            cell.isUserInteractionEnabled = isEditable
            return cell
            
        case .text(let title, let input):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextFieldCell.identifier, for: indexPath) as! TextFieldCell
            cell.configure(title: title, input: input, index: indexPath.item, delegate: self)
            cell.isUserInteractionEnabled = isEditable
            return cell
        }
    }
}

extension ContactDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        var height: CGFloat = 0
        
        switch items[indexPath.item] {
        case .avatar: height = AvatarCell.height
        case .text: height = TextFieldCell.height
        }
        
        return .init(width: width, height: height)
    }
}

// MARK: - AvatarCellDelegate
extension ContactDetailViewController: AvatarCellDelegate {
    func avatarCell(_ avatarCell: AvatarCell, didSelect image: UIImage) {
        items[FieldIndex.avatar] = VoipModels.ContactField.avatar(image: image)
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
        
        guard case .text(let title, _) = items[index] else { return }
        
        let input: VoipModels.Input = index == FieldIndex.phoneNumber ?
            .phoneNumber(text: text) :
            .name(text: text)
        
        items[index] = .text(title: title, input: input)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return view.endEditing(true)
    }
}
