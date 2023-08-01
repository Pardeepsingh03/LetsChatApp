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
            guard snapShot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    public func insertUser(with users: ChatAppUsers, completion: @escaping (Bool) -> Void){
        database.child(users.safeEmail).setValue([
            "first_name": users.firstName,
            "last_name": users.lastName
        ]) { errors, _ in
            guard errors == nil else {
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) { snapshot,_  in
                if var collections = snapshot.value as? [[String: String]] {
                    let newElement =
                        ["name": users.firstName + " " + users.lastName,
                         "email": users.safeEmail
                    ]
                    collections.append(newElement)
                    self.database.child("users").setValue(collections) { errors, _ in
                        guard errors == nil else {
                            completion(false)
                            return}
                        completion(true)
                    }
                }
                else{
                    let newCollection: [[String:String]] = [
                        ["name": users.firstName + " " + users.lastName,
                         "email": users.safeEmail
                    ]
                        ]
                    self.database.child("users").setValue(newCollection) { errors, _ in
                        guard errors == nil else {
                            completion(false)
                            return}
                        completion(true)
                    }
                }
                
            }
            completion(true)
        }
        
    }
    
    static func safeEmail(email: String)-> String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    func fetchAllData(compeltion: @escaping (Result<[[String:String]],Error>)-> Void){
        database.child("users").observeSingleEvent(of: .value) { snapshot,_  in
            guard let value = snapshot.value as? [[String:String]] else {
                compeltion(.failure(DatabaseError.failedToFetch))
                return
            }
            compeltion(.success(value))
            
        }
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
    var profilePictureFileName: String{
        return "\(safeEmail)_profile_picture.png"
    }

}

public enum DatabaseError:Error{
    case failedToFetch
}
