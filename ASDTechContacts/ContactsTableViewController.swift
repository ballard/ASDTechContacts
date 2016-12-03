//
//  ContactsTableViewController.swift
//  ASDTechContacts
//
//  Created by Ivan on 02.12.16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import UIKit
import Contacts
import Foundation

struct Contact {
    var fullName: String
    var emailAddresses = [String] ()
    var phonesNumber =  [String] ()
    var addresses =  [String] ()
    
    init?(cnContract :CNContact){
        self.fullName = CNContactFormatter.string(from: cnContract, style: .fullName) ?? ""
        _ = cnContract.emailAddresses.map({ self.emailAddresses.append($0.value as String)})
        _ = cnContract.phoneNumbers.map({ self.phonesNumber.append($0.value.stringValue.replacingOccurrences(of: " ", with: ""))})
        _ = cnContract.postalAddresses.map({ self.addresses.append(
            CNPostalAddressFormatter.string(from: $0.value, style: .mailingAddress)
                .replacingOccurrences(of: "  ", with: " "))})
    }
    
    func countSymbols (_ countSymbols:Int, _ string:String) -> Int {
        return countSymbols + string.characters.count
    }
    
    func compareTo(contact: Contact) -> Bool {
        
        guard self.fullName == contact.fullName ,
            self.emailAddresses.count == contact.emailAddresses.count,
            self.phonesNumber.count == contact.phonesNumber.count,
            self.addresses.count == contact.addresses.count,
            self.emailAddresses.reduce(0,countSymbols) == contact.emailAddresses.reduce(0,countSymbols),
            self.phonesNumber.reduce(0,countSymbols) == contact.phonesNumber.reduce(0,countSymbols),
            self.addresses.reduce(0,countSymbols) == contact.addresses.reduce(0,countSymbols)
            else {return false}
        
        if Set(self.emailAddresses) == Set (contact.emailAddresses ) &&
            Set (self.phonesNumber) == Set (contact.phonesNumber) &&
            Set (self.addresses ) == Set (contact.addresses) {
            return true
        } else {
            return false
        }
    }
    
    init?(json : [String : AnyObject]) {
        
        guard let name = json["name"] as? String,
            let email = json["email"] as? String,
            let phone = json["phone"] as? String,
            let address = json["address"] as? [String:AnyObject],
            let street = address["street"] as? String,
            let suite = address["suite"] as? String,
            let city = address["city"] as? String,
            let zip = address["zipcode"] as? String
            else { return nil }
        
        self.fullName = name
        self.emailAddresses = [email]
        self.phonesNumber = [phone]
        let addr = street + " Street " + suite + " "
        self.addresses = [addr + city + " " + zip + " USA\n \nUnited States"]
    }
    
}

class ContactsTableViewController: UITableViewController {
    
    var contacts = [Contact](){
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performFetchDeviceContact()
        fetchContactsFromJsonPlaceholder()
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Contact", for: indexPath)
        let contact = contacts[indexPath.row]
        cell.textLabel?.text? = contact.fullName
        if contact.addresses.first != nil {
            cell.detailTextLabel?.text? = contact.addresses.first!
        }
        
        return cell
    }
    
    // MARK: Custom functions
    
    func performFetchDeviceContact() {
        AppDelegate.getAppDelegate().requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                let keys = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName), CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactPostalAddressesKey] as [Any]
                
                do {
                    let contactStore = AppDelegate.getAppDelegate().contactStore
                    try contactStore.enumerateContacts(with: CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])) { (contact, pointer) -> Void in
                        let contractST = Contact (cnContract: contact)
                        if let contactNew = contractST {
                            if self.contacts.index(where: {($0 as Contact).compareTo(contact: contactNew)}) == nil {
                                DispatchQueue.main.async(execute: { () -> Void in
                                    self.contacts.append(contactNew)
                                })
                            }
                        }
                    }
                }
                catch let error as NSError {
                    print(error.description, separator: "", terminator: "\n")
                }
            }
        }
    }
    
    func fetchContactsFromJsonPlaceholder () {
        let url = URL(string:"https://jsonplaceholder.typicode.com/users" )
        let request = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            guard error == nil,
                let d = data,
                let json = try? JSONSerialization.jsonObject(with: d, options: .allowFragments),
                let results = json  as? [[String : AnyObject]]
                else { return}
            
            let contactsContact = results.flatMap({ (json) -> Contact? in return Contact.init(json: json) })
            
            _ = contactsContact.map({ (contactNew) in
                if self.contacts.index(where: {($0 as Contact).compareTo(contact: contactNew)}) == nil {
                    print("contact added")
                    DispatchQueue.main.async{
                        self.contacts.append(contactNew)
                    }}})
        })
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "Detail",
                let mtvc = segue.destination as? DetailTableViewController,
                let contactCell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: contactCell) {
                let contactDetail = contacts[indexPath.row]
                print(contactDetail)
                mtvc.contact = contactDetail
            }
        }
    }

}
