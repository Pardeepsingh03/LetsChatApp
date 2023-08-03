//
//  ConversationTableViewCell.swift
//  LetsChatApp
//
//  Created by MBA-0019 on 02/08/23.
//

import UIKit
import SDWebImage
class ConversationTableViewCell: UITableViewCell {
    
    static var identifier = "ConversationTableViewCell"
    let userImageView: UIImageView = {
        let imageView = UIImageView()
       imageView.layer.cornerRadius = 50
       imageView.contentMode = .scaleAspectFill
       imageView.layer.masksToBounds = true
       return imageView
    }()
    
    let userNameLabel: UILabel = {
        let userNameLabel = UILabel()
        userNameLabel.font = .systemFont(ofSize: 21,weight: .semibold)
        return userNameLabel
    }()
    
    let userMessageLabel: UILabel = {
        let userMesaageLabel = UILabel()
        userMesaageLabel.font = .systemFont(ofSize: 19,weight: .regular)
        userMesaageLabel.numberOfLines = 0
        return userMesaageLabel
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        userNameLabel.frame = CGRect(x: userImageView.frame.maxX + 10, y: 10, width: contentView.frame.width - 20 - userImageView.frame.width, height: (contentView.frame.height - 20) / 2)
        userMessageLabel.frame = CGRect(x: userImageView.frame.maxX + 10, y: userNameLabel.frame.maxY + 10, width: contentView.frame.width - 20 - userImageView.frame.width, height: (contentView.frame.height - 20) / 2)
        
    }
    
    public func configure(with model: Conversation){
         userNameLabel.text = model.name
        userMessageLabel.text = model.lastesMessage.text
        let image = "images/\(model.otherUserEmail)_profile_picture.png"
        print(image)
        StorageManager.shared.downloadImage(for: image) {[weak self] results in
            switch results {
                
            case .success(let image):
                self?.userImageView.sd_setImage(with: image)
            case .failure(let error):
                print("Error in downloading image: \(error)")
            }
        }
       
    }
    
}
