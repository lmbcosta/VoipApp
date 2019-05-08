//
//  CallHistoryViewController.swift
//  VoipApp
//
//  Created by Luis  Costa on 08/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit
import CoreData

class CallHistoryViewController: UIViewController {
    // MARK: UI
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(VoipContactCell.self, forCellReuseIdentifier: VoipContactCell.description())
        }
    }
    
    // MARK: Properties
    private lazy var managedContext: NSManagedObjectContext = self.appDelegate.managedContext
    private var calls: [Call] = []
    
    // MARK: View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchCalls()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
    }
}

// MARK: - UITableViewDelegate
extension CallHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard calls.count > 0 else { return 0 }
        
        return VoipContactCell.height
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
        let dateText = call.date?.formatToDefaultStyle()
        let callType = call.callType.rawValue.uppercased().capitalized
        
        let cell = tableView.dequeueReusableCell(withIdentifier: VoipContactCell.description()) as? VoipContactCell
        cell?.configure(name: name, dateText: dateText, image: nil, callType: callType)
        return cell ?? .init()
    }
}

private extension CallHistoryViewController {
    func fetchCalls() {
        let request = NSFetchRequest<Call>.init(entityName: Call.description())
        request.sortDescriptors = [NSSortDescriptor.init(key: Strings.dateProperty, ascending: false)]
        
        if let savedCalls = try? managedContext.fetch(request) {
            calls = savedCalls
        }
        
        tableView.reloadData()
    }
    
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = Strings.titleText
        
        let buttonItem = UIBarButtonItem.init(title: Strings.incomingCallText, style: .plain, target: self, action: #selector(incomingCallButtonTapped))
        navigationItem.setLeftBarButton(buttonItem, animated: false)
    }
    
    @objc func incomingCallButtonTapped() {
        // TODO: Simulate e receiving call
        print("Incomming Call")
    }
    
    struct Strings {
        static let titleText = "Call History"
        static let incomingCallText = "Incoming Call"
        static let dateProperty = "date"
        static let uknownText = "Uknown"
    }
}

