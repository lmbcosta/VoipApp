//
//  ContactListViewController.swift
//  VoipApp
//
//  Created by Luis  Costa on 12/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit
import Contacts

class ContactListViewController: UIViewController {

    // UI
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    private var colors: [UIColor] = [.red, .blue, .green, .yellow, .lightGray]
    
    private var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupSegmentedControll()
        
        fetchContacts()
    }
}

// MARK: - UITableViewDelegate
extension ContactListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .white
        header.addSubview(segmentedControl)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Defaults.headerHeight
    }
}

// MARK: - UITableViewDataSource
extension ContactListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = colors[Int.random(in: 0..<colors.count)]
        return cell
    }
}

// MARK: - Private Functions
private extension ContactListViewController {
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = Strings.titleText
        
        let addButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addNewContactButtonTapped))
        navigationItem.setRightBarButton(addButtonItem, animated: false)
    }
    
    func setupSegmentedControll() {
        let segmentedControl = UISegmentedControl(frame: CGRect(x: Defaults.segmentedHorozontalInset, y: Defaults.segmentedVerticalInset, width: tableView.frame.width - Defaults.segmentedHorozontalInset * 2, height: Defaults.segmentedHeight))
        segmentedControl.insertSegment(withTitle: Strings.allContactsText, at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: Strings.voipContactsText, at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = Defaults.allIndex
        segmentedControl.addTarget(self, action: #selector(segmentedTapped(sender:)), for: .valueChanged)
        
        self.segmentedControl = segmentedControl
    }
    
    func fetchContacts() {
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, error) in
            guard error == nil else { return }
            guard granted else { return }
        }
    }
    
    @objc func segmentedTapped(sender: UISegmentedControl) {
        // TODO:
        print("Segmented Controll tapped")
    }
    
    @objc func addNewContactButtonTapped() {
        // TODO:
    }
    
    struct Strings {
        static let titleText = "Contacts"
        static let allContactsText = "All Contacts"
        static let voipContactsText = "Voip Contacts"
    }
    
    struct Defaults {
        static let segmentedHorozontalInset: CGFloat = 10
        static let segmentedVerticalInset: CGFloat = 15
        static let segmentedHeight: CGFloat = 30
        static let headerHeight: CGFloat = 60
        static let allIndex = 0
        static let voipIndex = 1
    }
}



