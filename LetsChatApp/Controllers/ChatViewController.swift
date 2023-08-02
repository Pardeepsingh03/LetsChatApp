//
//  ChatViewController.swift
//  LetsChatApp
//
//  Created by MBA-0019 on 31/07/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType{
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}
struct Sender: SenderType{
    var photoURL: String
    var senderId: String
    var displayName: String
}

extension MessageKind{
    var messageKindString: String{
        switch self{
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

class ChatViewController: MessagesViewController {
    
   static public var dateFormater: DateFormatter = {
        let formattre = DateFormatter()
        formattre.dateStyle = .medium
        formattre.timeStyle = .long
        formattre.locale = .current
        return formattre
    }()
    private let otherEmail: String
     var isNewConversation = false
    private var messages = [Message]()
 //   guard let email = UserDefaults.standard.value(forKey: "email") as? String else {return}
    private var sender: Sender?
    
     init(other email: String) {
        self.otherEmail = email
         guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                   fatalError("User email not found in UserDefaults")
               }
               self.sender = Sender(photoURL: "", senderId: email, displayName: "Joe")
               super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,let sender = self.sender,let messageID = createMessageID() else {return}
        print("Sending: \(text)")
        if isNewConversation {
//            create a new conversation database
            let messages = Message(sender: sender, messageId: messageID, sentDate: Date(), kind: .text(text))
            DatabaseManager.shared.createNewConversation(otherUserEmail: otherEmail, name: self.title ?? "User", firstMessage: messages) { result in
                if result{
                    print("Message sucessfully send....")
                } else {
                    print("Send message failed....")
                }
            }
        } else {
           
        }
    }
    
    private func createMessageID() -> String?{
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") else {return nil}
        let safeCurrentEmail = DatabaseManager.safeEmail(email: currentEmail as! String)
        let dateFormatter = ChatViewController.dateFormater.string(from: Date())
        let newIdentifier = "\(otherEmail)_\(safeCurrentEmail)_\(dateFormatter)"
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate{
    func currentSender() -> MessageKit.SenderType {
        if let sender = sender {
            return sender
        }
        return Sender(photoURL: "", senderId: "12", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
