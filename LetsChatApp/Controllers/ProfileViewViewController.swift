//
//  ProfileViewViewController.swift
//  LetsChatApp
//
//  Created by MBA-0019 on 27/07/23.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class ProfileViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    @IBOutlet weak var profileTable: UITableView!
    var data = ["Logout"]
    override func viewDidLoad() {
        super.viewDidLoad()
        profileTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        profileTable.delegate = self
        profileTable.dataSource = self
        profileTable.tableHeaderView = createTableView()
    }
    
    func createTableView() -> UIView? {
      
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{return nil}
        let safeEmail = DatabaseManager.safeEmail(email: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        print(path)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
        headerView.backgroundColor = .link
        let imageView = UIImageView(frame: CGRect(x: (view.frame.width-150)/2, y: 75, width: 150, height: 150))
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.layer.masksToBounds = true
        headerView.addSubview(imageView)
        StorageManager.shared.downloadImage(for: path) { results in
            switch results {
            case .success(let url):
                print(url)
                URLSession.shared.dataTask(with: url) { imageData, _, error in
                    guard let data = imageData else {return}
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        imageView.image = image
                    }
                }.resume()
            case .failure(let error):
                print("Error in downloading the image \(error)")
            }
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive,handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            FBSDKLoginKit.LoginManager().logOut()
            do{
                try Auth.auth().signOut()
                let vc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: false)
            }
            catch{
                print("Failed to log out")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
        
        present(actionSheet, animated: true)
        
    }
    

    

}
