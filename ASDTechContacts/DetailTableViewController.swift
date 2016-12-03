//
//  DetailTableViewController.swift
//  ASDTechContacts
//
//  Created by Ivan on 03.12.16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
    
    struct SectionTitles {
        static let Name = "Name"
        static let Email = "Email"
        static let Phone = "Phone"
        static let Address = "Address"
    }
    
    var sections = [Section]() {
        didSet {
            tableView?.reloadData()
        }
    }
    
    struct Section {
        var type: String
        var values: [String]
    }
    
    var contact: Contact? {
        didSet {
            sections.append(Section(type: SectionTitles.Name, values: [contact!.fullName]))
            if let emails = contact?.emailAddresses.map({ $0 }) {
                sections.append(Section(type: SectionTitles.Email, values: emails))
            }
            
            if let phones = contact?.phonesNumber.map({ $0 }) {
                sections.append(Section(type: SectionTitles.Phone, values: phones))
            }
            
            if let addresses = contact?.addresses.map({ $0 }) {
                sections.append(Section(type: SectionTitles.Address, values: addresses))
            }
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].type
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].values.count
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if tableView.numberOfRows(inSection: section) == 0 {
            view.isHidden = true
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Value", for: indexPath)
        cell.textLabel?.text = sections[indexPath.section].values[indexPath.row]

        return cell
    }

}
