//
//  ContactDetailViewController.swift
//  ContactsCloudKit
//
//  Created by lijia xu on 8/13/21.
//

import UIKit

protocol ContactDetailVCDelegate {
    func perforReload()
}

class ContactDetailViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var contact: Contact?
    var delegate: ContactDetailVCDelegate?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    func updateViews() {
        guard let contact = contact else { return }
        nameTextField.text = contact.contactName
        phoneNumberTextField.text = contact.contactPhoneNumber
        emailTextField.text = contact.contactEmail
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let nameText = nameTextField.text,
              !nameText.isEmpty else { return }
        
        switch contact {
        case let contact?:
            contact.contactName = nameText
            contact.contactPhoneNumber = phoneNumberTextField.text
            contact.contactEmail = emailTextField.text
            ContactController.shared.updateContact(contact: contact) { [weak self] result in
                DispatchQueue.main.async {
                    
                    switch result {
                    case .success(_):
                        self?.delegate?.perforReload()
                        self?.navigationController?.popViewController(animated: true)
                        
                    case .failure(let err):
                        print(err)
                    }
                    
                }///End of  GCD
                
            }///End of  contactController
            
        case nil:
            ContactController
                .shared
                .createContactWith(
                    contactName: nameText,
                    contactPhone: phoneNumberTextField.text,
                    contactEmail: emailTextField.text
                ) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            self?.delegate?.perforReload()
                            self?.navigationController?.popViewController(animated: true)
                            
                        case .failure(let err):
                            print(err)
                        }
                        
                    }///End of  GCD
                    
                }///End of  completion
            
        }///End of  switch
        
    }///End of  saveButtonTapped
    
}///End of  ContactDetailVC

