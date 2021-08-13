//
//  ContactListTableViewController.swift
//  ContactsCloudKit
//
//  Created by lijia xu on 8/13/21.
//

import UIKit

class ContactListTableViewController: UITableViewController {
    
    private var contacts: [Contact] = []

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullFetchContacts()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let targetVC = segue.destination as? ContactDetailViewController {
            targetVC.delegate = self

            if segue.identifier == "toDetailVC" {
                guard let targetVC = segue.destination as? ContactDetailViewController,
                      let selectedIndex = tableView.indexPathForSelectedRow else { return }
                
                targetVC.contact = contacts[selectedIndex.row]
                targetVC.delegate = self
                
            }
            
        }///End of  if let targetVC
        
    }///End of prepare for segue
    
}///End of Class

// MARK: - TableView Related
extension ContactListTableViewController {
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        
        let contact = contacts[indexPath.row]
        
        cell.textLabel?.text = contact.contactName
        cell.detailTextLabel?.text = contact.contactPhoneNumber
        
        return cell
    }
    
    
    // MARK: - Delete Related
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contactToDelete = contacts[indexPath.row]
            
            ContactController.shared.delete(contactToDelete) {[weak self] result in
                DispatchQueue.main.async {
                    
                    switch result {
                    case .success(_):
                        self?.contacts = self?.generateSortedArray(ContactController.shared.contacts) ?? []
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    case .failure(let err) :
                        print(err)
                    }
                    
                }///End of  GCD
                
            }///End of  CallBack
        }
    }///End of  editingstyle
    
    
}///End of ContactListTableViewController

// MARK: - Fetch Data Related
extension ContactListTableViewController {
    
    func fullFetchContacts() {
        ContactController.shared.fetchContacts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let contacts):
                    guard let sortedContacts = self?.generateSortedArray(Set(contacts)) else { return }
                    self?.contacts = sortedContacts
                    self?.tableView.reloadData()
                    
                case .failure(let err):
                    print(err)
                }
                
            }///End Of dispatch
            
        }///End Of callback
        
    }///End Of fetchEntries
      
    func updateContactsFromLocalSOT() {
        contacts = generateSortedArray(ContactController.shared.contacts)
        tableView.reloadData()
    }
    
    //Helper
    func generateSortedArray(_ contactsSet: Set<Contact> ) -> [Contact] {
        return contactsSet.sorted{ $0.contactName.first ?? "a" < $1.contactName.first ?? "a" }
    }
    
}///End Of Extension

extension ContactListTableViewController: ContactDetailVCDelegate {
    
    func perforReload() {
        updateContactsFromLocalSOT()
    }
    
}///End of  extension

