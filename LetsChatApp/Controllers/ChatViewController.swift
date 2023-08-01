//
//  ChatViewController.swift
//  LetsChatApp
//
//  Created by MBA-0019 on 31/07/23.
//

import UIKit
import MessageKit

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

class ChatViewController: MessagesViewController {
    private let otherEmail: String
    private var isNewConversation = false
    private var messages = [Message]()
    private var sender = Sender(photoURL: "", senderId: "1", displayName: "Joe")
    
     init(other email: String) {
        self.otherEmail = email
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
       
        messages.append(Message(sender: sender, messageId: "1", sentDate: Date(), kind: .text("Hello world.")))
        messages.append(Message(sender: sender, messageId: "1", sentDate: Date(), kind: .text("Hello world.All are good humans its just preception .")))
    }
}

extension ChatViewController: MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate{
    func currentSender() -> MessageKit.SenderType {
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
