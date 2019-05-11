//
//  CallModel.swift
//  VoipApp
//
//  Created by Luis  Costa on 09/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import Foundation

class VoipCall {
    let uuid: UUID
    let outgoing: Bool
    let handle: String
    
    var state: VoipModels.CallState = .ended {
        didSet {
            stateChanged?()
        }
    }
    
    var connectedState: VoipModels.ConnectedState = .pending {
        didSet {
            connectedStateChanged?()
        }
    }
    
    var stateChanged: (() -> Void)?
    var connectedStateChanged: (() -> Void)?
    var endHandler: (() -> Void)?
    
    init(uuid: UUID, outgoing: Bool = false, handle: String) {
        self.uuid = uuid
        self.outgoing = outgoing
        self.handle = handle
    }
    
    func start(completion: ((_ success: Bool) -> Void)?) {
        completion?(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.state = .connecting
            self.connectedState = .pending
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.state = .active
                self.connectedState = .complete
            }
        }
    }
    
    func answer() {
        state = .active
    }
    
    func end() {
        state = .ended
    }
}
