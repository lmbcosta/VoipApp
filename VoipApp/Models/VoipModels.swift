//
//  VoipModels.swift
//  VoipApp
//
//  Created by Luis  Costa on 08/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit

enum VoipModels {
    struct VoipContact {
        let entityId: Int32?
        let firstName: String
        let familyName: String
        let number:  String
        let isVoipNumber: Bool
        let identifier: String?
        let avatar: UIImage?
        
        // Convinience
        var name: String { return firstName + " " + familyName }
    }
    
    struct ContactSection {
        let title: String
        var contacts: [VoipContact]
    }
    
    enum CallType: String {
        case incoming = "INCOMING"
        case outgoing = "OUTGOING"
    }
    
    enum CallState {
        case connecting
        case active
        case held
        case ended
    }
    
    enum ConnectedState {
        case pending
        case complete
    }
    
    enum ContactField {
        case avatar(image: UIImage?)
        case text(title: String, input: VoipModels.Input)
        
        func getText() -> String? {
            switch  self {
            case .avatar: return nil
            case .text(_, input: .name(let text)): return text == nil || text?.isEmpty == true ? nil : text
            case .text(_, input: .phoneNumber(let text)): return text == nil || text?.isEmpty == true ? nil : text
            }
        }
    }
    
    enum Input {
        case name(text: String?)
        case phoneNumber(text: String?)
    }
    
    enum OperationResult {
        case update(Bool)
        case create(Bool)
        case delete(Bool)
    }
}
