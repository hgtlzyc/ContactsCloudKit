//
//  ContactController.swift
//  ContactsCloudKit
//
//  Created by lijia xu on 8/13/21.
//

import Foundation
import CloudKit

enum ContactError: LocalizedError {
    case notAbleToSaveContact(Error)
    case unableToConvertToContact
    case unableToFetchContacts(Error)
    case nilRecordsreceived
    case unableToDelete(Error?)
}

class ContactController {
    
    static let shared = ContactController()
    
    private let privateDB = CKContainer.default().privateCloudDatabase
    
    // MARK: - SOT
    private(set) var contacts = Set<Contact>()
    
    // MARK: - CRUD Functions
    
    //create
    func createContactWith(contactName: String, contactPhone: String?, contactEmail: String?, completion: @escaping (Result<Contact, ContactError>) -> Void ) {
        
        let newContact = Contact(contactName: contactName, contactPhoneNumber: contactPhone, contactEmail: contactEmail)
        
        contacts.insert(newContact)
        
        let newContactCKRecord = CKRecord(contact: newContact)
        
        privateDB.save(newContactCKRecord) { record, error in
            
            if let error = error {
                return completion(.failure(.notAbleToSaveContact(error)))
            }
            
            guard let record = record,
                  let newContact = Contact(ckRecord: record) else {
                print("Unable to convert")
                return completion(.failure(.unableToConvertToContact))
            }
            
            completion(.success(newContact))
            
        }///End of  privateDB.save
        
    }///End of  createContact
    
    //read
    func fetchContacts(completion: @escaping (Result<[Contact], ContactError>) -> Void ) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ContactConstants.recordType, predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil) { records, error in
            
            if let error = error {
                return completion(.failure(.unableToFetchContacts(error)))
            }
            
            guard let records = records else {
                print("UnableToConvert in \(#function)")
                completion(.failure(.unableToConvertToContact))
                return
            }
            
            let validContacts = records.compactMap{ Contact(ckRecord: $0) }
            
            self.contacts.formUnion( Set(validContacts) )
            
            completion(.success(validContacts))
            
            if validContacts.count != records.count {
                print("nil Contact in \(#function) in line \(#line)")
            }
            
        }///End of  privateDB.perform
        
    }///End of  fetchContacts
    
    //update
    func updateContact(contact: Contact, completion: @escaping (Result<[CKRecord], ContactError>) -> Void ) {
        let ckRecord = CKRecord(contact: contact)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [ckRecord], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.queuePriority = .high
        operation.qualityOfService = .userInitiated
        
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                return completion( .failure(.notAbleToSaveContact(error)) )
            }
            guard let records = records else { return completion(.failure(.nilRecordsreceived)) }
            return completion(.success(records))
            
        }
        
        privateDB.add(operation)
        
    }///End Of UpdateEntry
    
    //delete
    func delete(_ contact: Contact, completion: @escaping (Result<Bool, ContactError>) -> Void ) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [contact.ckRecordID])
        operation.savePolicy = .changedKeys
        operation.queuePriority = .high
        operation.qualityOfService = .userInitiated
        operation.modifyRecordsCompletionBlock = { (records, _ ,error ) in
            if let error = error {
                return completion(.failure(.unableToDelete(error)))
            }
            
            if records?.count == 0 {
                self.contacts.remove(contact)
                completion(.success(true))
            } else {
                completion(.failure(.unableToDelete(nil)))
            }
            
        }///End of  block
        
        privateDB.add(operation)
        
    }///End of  Delete
    
    // MARK: - Private init
    private init(){}
    
}///End of  ContactController
