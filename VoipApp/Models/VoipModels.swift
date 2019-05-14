//
//  VoipModels.swift
//  VoipApp
//
//  Created by Luis  Costa on 08/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import Foundation

enum VoipModels {
    struct VoipContact {
        let name: String
        let number:  String
        let isVoipNumber: Bool
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
}
