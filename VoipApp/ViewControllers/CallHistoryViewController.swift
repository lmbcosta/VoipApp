//
//  CallHistoryViewController.swift
//  VoipApp
//
//  Created by Luis  Costa on 08/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit

class CallHistoryViewController: UIViewController {
    // MARK: UI
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    // MARK: Properties
    private var calls: [Call] = []
    private lazy var callManager = CallManager()
    private lazy var databaseManager = DatabaseManager.shared
    
    private var provider: ProviderConfigurator!
    private var callView: UIAlertController?
    
    // MARK: View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchCalls()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        callManager.callEndHandler = { [weak self] (contact, callType) in
            self?.handleEndCall(for: contact, with: callType)
        }
        
        provider = ProviderConfigurator.init(callManager: callManager)
    }
}

// MARK: - UITableViewDelegate
extension CallHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard calls.count > 0 else { return 0 }
        
        return VoipCallCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        // Perform Outging call
        let contact = calls[indexPath.item].cantactedBy
        let uuid = UUID()
        callManager.startCall(with: contact, uuid: uuid)
        showCallScreen(forContact: contact, uuid: uuid, callType: .outgoing)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return Strings.removeText
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let call = calls[indexPath.item]
            databaseManager.delete(call: call)
        
            calls.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - UITableViewDataSource
extension CallHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let call = calls[indexPath.item]
        let name = call.cantactedBy.name ?? Strings.uknownText
        let dateText = call.date?.formatWithAppStyle()
        let callType = call.callType.rawValue.uppercased().capitalized
        
        let cell = tableView.dequeueReusableCell(withIdentifier: VoipCallCell.identifier) as! VoipCallCell
        cell.configure(name: name, dateText: dateText, image: nil, callType: callType)
        
        return cell
    }
}

private extension CallHistoryViewController {
    func fetchCalls() {
        if let savedCalls = databaseManager.fetchCalls() { calls = savedCalls }
        
        tableView.reloadData()
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = Strings.titleText
        
        let buttonItem = UIBarButtonItem.init(title: Strings.incomingCallText, style: .plain, target: self, action: #selector(incomingCallButtonTapped))
        navigationItem.setLeftBarButton(buttonItem, animated: false)
    }
    
    // Show alert as call view
    func showCallScreen(forContact contact: Contact, uuid: UUID, callType: VoipModels.CallType) {
        tableView.isUserInteractionEnabled = false
        let callView = UIAlertController.init(title: contact.name ?? contact.number ?? "", message: Strings.callingMessage, preferredStyle: .alert)
        let action = UIAlertAction.init(title: Strings.endCallText, style: .destructive) { [unowned self] _ in
            self.tableView.isUserInteractionEnabled = true
            
            // Get current call
            if let voipCall = self.callManager.callWithUUID(uuid: uuid) {
                self.callManager.end(call: voipCall)
            }
            
            self.callView = nil
        }
        callView.addAction(action)
        
        self.callView = callView
        
        self.present(callView, animated: true, completion: nil)
    }
    
    @objc func incomingCallButtonTapped() {
        // Get Dummy Contact
        guard let contact = databaseManager.fetchDummyContact() else { return }
        
        // UUID for receiving Call
        let uuid = UUID()
        
        // Simulate an incoming call
        let backgroundTaskId = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.provider.reportIncomingCall(from: contact, uuid: uuid, number: contact.number) { [weak self] _ in
                UIApplication.shared.endBackgroundTask(backgroundTaskId)
                self?.showCallScreen(forContact: contact, uuid: uuid, callType: .incoming)
            }
        }
    }
    
    func handleEndCall(for contact: Contact, with type: VoipModels.CallType) {
        if let callView = callView {
            callView.dismiss(animated: true) { [weak self] in
                self?.callView = nil
                self?.tableView.isUserInteractionEnabled = true
                self?.databaseManager.createCall(for: contact, with: type)
                self?.fetchCalls()
                return
            }
        }
        else {
            databaseManager.createCall(for: contact, with: type)
            fetchCalls()
        }
    }
    
    struct Strings {
        static let titleText = "Call History"
        static let incomingCallText = "Incoming Call"
        static let uknownText = "Uknown"
        static let callingMessage = "Calling..."
        static let endCallText = "End Call"
        static let removeText = "Remove"
    }
}

