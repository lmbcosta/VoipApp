//
//  AvatarCell.swift
//  VoipApp
//
//  Created by Luis  Costa on 15/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit
import AVFoundation

protocol AvatarCellDelegate: class {
    func avatarCell(_ avatarCell: AvatarCell, didSelect image: UIImage)
    func avatarCell(_ avatarCell: AvatarCell, willPresent controller: UIViewController)
}

class AvatarCell: UICollectionViewCell {
    static let height = Defaults.cellHeight
    static let identifier = Strings.cellIIdentifier
    
    // UI
    @IBOutlet private weak var avatarImage: UIImageView! {
        didSet {
            avatarImage.contentMode = .scaleAspectFit
            avatarImage.clipsToBounds = true
            avatarImage.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = buildTapGestureRecognizer()
    private lazy var pickerController = buildPickerController()
    private weak var delegate: AvatarCellDelegate?
    private var isEditable = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImage.layer.cornerRadius = avatarImage.frame.height / 2
    }
    
    func configure(with image: UIImage, isEditable: Bool) {
        avatarImage.image = image
        self.isEditable = isEditable
    }
}

private extension AvatarCell {
    func buildTapGestureRecognizer() -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(avatarImageTapped))
        tap.numberOfTapsRequired = 1
        return tap
    }
    
    func buildPickerController() -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.modalPresentationStyle = .overFullScreen
        return picker
    }
    
    @objc func avatarImageTapped() {
        guard isEditable else { return }
        
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Camera Action
        let cameraAction = UIAlertAction.init(title: Strings.cameraTitleText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.requestCameraAccess(then: { granted in
                guard granted, UIImagePickerController.isSourceTypeAvailable(.camera) else {
                    self.showCameraUnavailable()
                    return
                }
                
                self.pickerController.sourceType = .camera
                self.delegate?.avatarCell(self, willPresent: self.pickerController)
            })
        }
        alert.addAction(cameraAction)
        
        // Gallery Action
        let galleryAction = UIAlertAction.init(title: Strings.galleryTitleText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                self.showCameraUnavailable()
                return
            }
            
            self.pickerController.sourceType = .photoLibrary
            self.delegate?.avatarCell(self, willPresent: self.pickerController)
        }
        alert.addAction(galleryAction)
        
        let cancelAction = UIAlertAction.init(title: Strings.cancelText, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        delegate?.avatarCell(self, willPresent: alert)
    }
    
    func requestCameraAccess(then handler: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized: handler(true)
        case .notDetermined: AVCaptureDevice.requestAccess(for: .video, completionHandler: handler)
        default: handler(false)
        }
    }
    
    func showCameraUnavailable() {
        let alert = UIAlertController.init(title: Strings.errorText, message: Strings.cameraErrorMessageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: Strings.okButtonText, style: .destructive, handler: nil))
        delegate?.avatarCell(self, willPresent: alert)
    }
    
    func showGalleryUnavailable() {
        let alert = UIAlertController.init(title: Strings.errorText, message: Strings.galleryMessageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: Strings.okButtonText, style: .destructive, handler: nil))
        delegate?.avatarCell(self, willPresent: alert)
    }
    
    struct Strings {
        static let cameraTitleText = "Camera"
        static let galleryTitleText = "Gallery"
        static let errorText = "Error"
        static let cameraErrorMessageText = "Camera is not available"
        static let okButtonText = "OK"
        static let galleryMessageText = "Gallery is not available"
        static let cancelText = "Cancel"
        static let cellIIdentifier = "AvatarCell"
    }
    
    struct Defaults {
        static let cellHeight = CGFloat(200)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension AvatarCell: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            avatarImage.image = image
            picker.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.delegate?.avatarCell(self, didSelect: image)
            }
        }
    }
}


