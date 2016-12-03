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
        // #warning Incomplete implementation, return the number of sections
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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

        // Configure the cell...

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
