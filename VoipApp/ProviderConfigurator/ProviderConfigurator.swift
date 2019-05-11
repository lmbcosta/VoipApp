//
//  ProviderConfigurator.swift
//  VoipApp
//
//  Created by Luis  Costa on 09/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import CallKit
import AVFoundation

import AVFoundation
import CallKit

class ProviderConfigurator: NSObject {
    private let callManager: CallManager
    private let provider: CXProvider
    
    init(callManager: CallManager) {
        self.callManager = callManager
        provider = CXProvider(configuration: ProviderConfigurator.providerConfiguration)
        
        super.init()
        
        provider.setDelegate(self, queue: nil)
    }
    
    static var providerConfiguration: CXProviderConfiguration = {
        let providerConfiguration = CXProviderConfiguration(localizedName: "VoipApp")
        
        providerConfiguration.supportsVideo = true
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportedHandleTypes = [.phoneNumber]
        
        return providerConfiguration
    }()
    
    func reportIncomingCall(from contact: Contact, uuid: UUID, number: String?, completion: ((Error?) -> Void)?) {
        guard let number = number else {
            // Number unavailable
            return
        }
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: number)
        update.hasVideo = false
        
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if error == nil {
                let call = VoipCall(uuid: uuid, handle: number)
                self.callManager.add(call: call, from: contact, with: .incoming)
            }
            
            completion?(error)
        }
    }
}

// MARK: - CXProviderDelegate
extension ProviderConfigurator: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        for call in callManager.calls {
            call.end()
        }
        
        callManager.removeAllCalls()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        configureAudioSession()
        
        call.answer()
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        let uuid = action.callUUID
        guard let call = callManager.callWithUUID(uuid: uuid) else {
            action.fail()
            return
        }
        
        call.end()
        action.fulfill()
        
        // Perform any end completion before being removed
        if let (contact, callType) = callManager.getCallData(for: uuid) {
            callManager.callEndHandler?(contact, callType)
        }
        
        callManager.remove(call: call)
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.state = action.isOnHold ? .held : .active
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        let call = VoipCall(uuid: action.callUUID, outgoing: true,
                        handle: action.handle.value)
        
        configureAudioSession()
        
        call.connectedStateChanged = { [weak self, weak call] in
            guard
                let self = self,
                let call = call
                else {
                    return
            }
            
            if call.connectedState == .pending {
                self.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: nil)
            } else if call.connectedState == .complete {
                self.provider.reportOutgoingCall(with: call.uuid, connectedAt: nil)
            }
        }
        
        call.start { [weak self, weak call] success in
            guard let self = self, let call = call else {
                return
            }

            if success {
                action.fulfill()
                self.callManager.add(call: call)
            } else {
                action.fail()
            }
        }
    }
}
