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

extension DatabaseManager{
    func createNewConversation(otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }

        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        let ref = database.child("\(safeEmail)")

        ref.observeSingleEvent(of: .value) { snapshot, _ in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }

            let senderDate = firstMessage.sentDate
            let formatterDate = ChatViewController.dateFormater.string(from: senderDate)
            let message = firstMessage.kind
            var textMessage = ""
            switch message {
            case .text(let text):
                textMessage = text
                // Handle other message types if needed
            default:
                break
            }

            let latestMessages: [String: Any] = [
                "date": formatterDate,
                "text": textMessage,
                "is_read": false
            ]

            let firstConvo = "conversation_\(firstMessage.messageId)"
            let newConversation: [String: Any] = [
                "id": firstConvo,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": latestMessages
            ]

            let recepit_newConversation: [String: Any] = [
                "id": firstConvo,
                "other_user_email": safeEmail,
                "name": "Self",
                "latest_message": latestMessages
            ]

            self.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
                if var value = snapshot.value as? [[String: Any]] {
                    value.append(recepit_newConversation)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(value)
                } else {
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recepit_newConversation])
                }
            }

            if var conversations = userNode["conversations"] as? [[String: Any]] {
                conversations.append(newConversation)
                userNode["conversations"] = conversations
            } else {
                userNode["conversations"] = [newConversation]
            }

            ref.setValue(userNode) { error, _ in
                if let error = error {
                    print("Error saving conversation: \(error)")
                    completion(false)
                } else {
                    // Assuming `finishCreatingConversation` is defined and handles completion
                    self.finishCreatingConversation(conversationID: firstConvo, name: name, firstMessage: firstMessage, completion: completion)
                }
            }
        }
    }

    func getAllConversation(email: String,completion: @escaping (Result<[Conversation],Error>) -> Void){
        database.child("\(email)/conversations").observe(.value) { snapshot,_  in
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversation: [Conversation] = value.compactMap { dict in
                guard let id = dict["id"] as? String,
                      let name = dict["name"] as? String,
                      let otherUserEmail = dict["other_user_email"] as? String,
                      let latestMessage = dict["latest_message"] as? [String:Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                    
                }
                
                      
                let lastestMessage = LatestMessage(date: date, text: message, isRead: isRead)
                let convos = Conversation(id: id, name: name, otherUserEmail: otherUserEmail, lastesMessage: lastestMessage)
                return convos
            }
            
            completion(.success(conversation))
            
        }
    }
    func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message],Error>) -> Void){
        
        database.child("\(id)/messages").observe(.value) { snapshot,_  in
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap { dict in
               
                 guard let name = dict["name"] as? String,
                       let isRead = dict["is_read"] as? Bool,
                       let messageID = dict["id"] as? String,
                       let content = dict["content"] as? String,
                       let senderEmail = dict["sender_email"] as? String,
                       let dateString = dict["date"] as? String,
                       let type = dict["type"] as? String,
                       let date = ChatViewController.dateFormater.date(from: dateString) else {
                     return nil
                 }
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                let message = Message(sender: sender, messageId: messageID, sentDate: date, kind: .text(content))
                return message
                      
              
            }
            completion(.success(messages))

            
        }
        
        
    }
    func sendMessage(to conversation: String,message: Message,completion: @escaping (Bool) -> Void){
        
    }
    
    func finishCreatingConversation(conversationID: String,name:String, firstMessage: Message, completion: @escaping (Bool) -> Void) {

        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let senderDate = firstMessage.sentDate
        let formatterDate = ChatViewController.dateFormater.string(from: senderDate)
        let message = firstMessage.kind
        var textMessage = ""
        switch message {
        case .text(let text):
            textMessage = text
        // Handle other message types if needed
        default:
            break
        }

        let messagesCollection: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString, // Convert enum to String
            "content": textMessage, // Use the textMessage variable instead of the enum directly
            "date": formatterDate,
            "sender_email": currentEmail,
            "is_read": false,
            "name":name
        ]

        let values: [String: Any] = [
            "messages": [messagesCollection]
        ]

        database.child("\(conversationID)").setValue(values) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
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
