//
//  DatabaseManager.swift
//  LetsChatApp
//
//  Created by MBA-0019 on 27/07/23.
//


import Foundation
import FirebaseDatabase

final class DatabaseManager{
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    public func isUserExist(with email: String,completion: @escaping ((Bool) -> Void)){
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value) { snapShot in
            guard snapShot.value is String else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    public func insertUser(with users: ChatAppUsers){
        database.child(users.safeEmail).setValue([
            "first_name": users.firstName,
            "last_name": users.lastName
        ])
        
    }
}

struct ChatAppUsers{
    var firstName: String
    var lastName: String
    var email: String
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }

}
