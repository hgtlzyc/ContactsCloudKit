//
//  Contact.swift
//  ContactsCloudKit
//
//  Created by lijia xu on 8/13/21.
//

import Foundation
import CloudKit

struct ContactConstants {
    
    static let recordType = "Contact"
    static let contactNameKey = "contactName"
    static let contactPhoneNumberKey = "contactPhoneNumber"
    static let contactEmailKey = "contactEmail"
    
}///End of  ContactConstants


class Contact {
    
    var contactName: String
    var contactPhoneNumber: String?
    var contactEmail: String?
    let ckRecordID: CKRecord.ID
    
    internal init(contactName: String,
                  contactPhoneNumber: String? = nil,
                  contactEmail: String? = nil,
                  ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString) ) {
        self.contactName = contactName
        self.contactPhoneNumber = contactPhoneNumber
        self.contactEmail = contactEmail
        self.ckRecordID = ckRecordID
        
    }///End of  init
    
}///End of  Contact

extension Contact: Hashable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.ckRecordID == rhs.ckRecordID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ckRecordID)
    }

}


extension Contact {
    
    convenience init? (ckRecord: CKRecord) {
        guard let contactName = ckRecord[ContactConstants.contactNameKey] as? String else { return nil }
        
        let contactPhoneNumber = ckRecord[ContactConstants.contactPhoneNumberKey] as? String
        let contactEmail = ckRecord[ContactConstants.contactEmailKey] as? String
        let id = ckRecord.recordID
        
        self.init(contactName: contactName,
                  contactPhoneNumber: contactPhoneNumber,
                  contactEmail: contactEmail,
                  ckRecordID: id )
        
    }///End of  init

}///End of  Contact

extension CKRecord {
    
    convenience init(contact: Contact) {
        self.init(recordType: ContactConstants.recordType, recordID: contact.ckRecordID)
        
        self.setValuesForKeys([
            ContactConstants.contactNameKey: contact.contactName
        ])
        
        if let phoneNumer = contact.contactPhoneNumber {
            self.setValue(phoneNumer, forKey: ContactConstants.contactPhoneNumberKey)
        }
        
        if let emailAddress = contact.contactEmail {
            self.setValue(emailAddress, forKey: ContactConstants.contactEmailKey)
        }
        
    
    }///End of  init
    
}///End of  CKRecord
