//
//  CallManager.swift
//  VoipApp
//
//  Created by Luis  Costa on 09/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import Foundation
import CallKit

class CallManager {
    private typealias CallData = (Contact, VoipModels.CallType)
    
    var callsChangedHandler: (() -> Void)?
    var callEndHandler: ((Contact, VoipModels.CallType) -> Void)?
    
    private lazy var contactsDictionary: [UUID: CallData] = [:]
    
    private let callController = CXCallController()
    private(set) var calls: [VoipCall] = []
    
    func callWithUUID(uuid: UUID) -> VoipCall? {
        guard let index = calls.firstIndex(where: { $0.uuid == uuid }) else {
            return nil
        }
        return calls[index]
    }
    
    func add(call: VoipCall, from contact: Contact? = nil, with type: VoipModels.CallType? = nil) {
        if let contact = contact, let callType = type { contactsDictionary[call.uuid] = (contact, callType) }
        
        calls.append(call)
        call.stateChanged = { [weak self] in
            self?.callsChangedHandler?()
        }
        callsChangedHandler?()
    }
    
    func remove(call: VoipCall) {
        guard let index = calls.firstIndex(where: { $0 === call }) else { return }
        
        let call = calls.remove(at: index)
        
        // Remove uuid entry from dictionary
        contactsDictionary.removeValue(forKey: call.uuid)
        
        callsChangedHandler?()
    }
    
    func removeAllCalls() {
        calls.removeAll()
        callsChangedHandler?()
    }
    
    func end(call: VoipCall) {
        let endCallAction = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction(action: endCallAction)
        
        requestTransaction(transaction)
    }
    
    func setHeld(call: VoipCall, onHold: Bool) {
        let setHeldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
        
        let transaction = CXTransaction()
        transaction.addAction(setHeldCallAction)
        
        requestTransaction(transaction)
    }
    
    func startCall(with contact: Contact, uuid: UUID) {
        guard let number = contact.number else {
            // Number unavailable
            return
        }
        
        contactsDictionary[uuid] = (contact, .outgoing)
        
        let handle = CXHandle(type: .phoneNumber, value: number)
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        startCallAction.isVideo = false
        
        let transaction = CXTransaction(action: startCallAction)
        requestTransaction(transaction)
    }
    
    func getCallData(for uuid: UUID) -> (Contact, VoipModels.CallType)? {
        return contactsDictionary[uuid]
    }
}

// MARK: - Private Functions
private extension CallManager {
    private func requestTransaction(_ transaction: CXTransaction) {
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction successfully")
            }
        }
    }
}
