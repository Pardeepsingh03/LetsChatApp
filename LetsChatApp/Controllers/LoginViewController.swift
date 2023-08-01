//
//  LoginViewController.swift
//  LetsChatApp
//
//  Created by MBA-0019 on 27/07/23.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import Firebase

class LoginViewController: UIViewController {
   
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = FBLoginButton()

        // Calculate the desired Y-coordinate for the button's center
        let desiredY = view.center.y + 200 // You can change '100' to any value you prefer to adjust the position.

        // Set the updated center for the loginButton
        loginButton.center = CGPoint(x: view.center.x, y: desiredY)
        loginButton.bounds.size = CGSize(width: 350, height: 50)
        // Add the loginButton as a subview to the view
        view.addSubview(loginButton)
        loginButton.permissions = ["public_profile","email"]
        loginButton.delegate = self
    
    
      
    }
    @IBAction func googleSignIn(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
            // ...
              return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
            // ...
              return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)

          // ...
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Firebase Authentication Error: \(error.localizedDescription)")
                    return
                }
                guard let result = authResult else {return}
                self.saveData(results: result)
            }
        }
    }
    
    func saveData(results: AuthDataResult){
        guard let email = results.user.email else {return}
        guard let name = results.user.displayName else {return}
        print(name)
        UserDefaults.standard.set(email, forKey: "email")
        let components = name.components(separatedBy: " ")
        guard components.count == 2 else {return}
        let firstName = components[0]
        let lastName = components[1]
        DatabaseManager.shared.isUserExist(with: email) { [weak self] exist in
            guard let strongSelf = self else {return}
            if !exist {
                let chatUser = ChatAppUsers(firstName: firstName, lastName: lastName, email: email)
                DatabaseManager.shared.insertUser(with: chatUser, completion: {sucess in
                    if sucess {
//                        uplaod image
                        guard let imageURL = results.user.photoURL else{return}
                        URLSession.shared.dataTask(with: imageURL) { imageData, _, error in
                            guard let data = imageData else {return}
                            let fileName = chatUser.profilePictureFileName
                            StorageManager.shared.uplaodImage(with: data, fileName: fileName) { results in
                                switch results{
                                case .success(let downloadImage):
                                    UserDefaults.standard.set(downloadImage, forKey: "profile_picture")
                                    print(downloadImage)
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }.resume()
                    }
                })
                strongSelf.navigationController?.dismiss(animated: true)
            }
        }

    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let email = email.text, let pass = password.text,!email.isEmpty,!pass.isEmpty else {
            showAlert()
            return
        }
        Auth.auth().signIn(withEmail: email, password: pass) { [weak self] authResult, error in
            guard let strongSelf = self else {return}
            guard let result = authResult,error == nil else {
                print("Failed in log in")
                return
            }
            let user = result.user
            UserDefaults.standard.set(email, forKey: "email")
            print("Log in With user \(user)")
            
            strongSelf.navigationController?.dismiss(animated: true)
        }
    
        
    }
    
    private func showAlert(){
        
        let alert = UIAlertController(title: "Error", message: "Please fill in both email and password fields.", preferredStyle: .alert)
         let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
         alert.addAction(okAction)

         // Present the alert
         present(alert, animated: true, completion: nil)
    }
    
    // MARK: - GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
       
     }
  
    
}

extension LoginViewController: LoginButtonDelegate{
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in using facebook")
            return
        }
        
        let facbookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields":"email,first_name,last_name,picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        facbookRequest.start { _, result, error in
            guard let result = result as? [String:Any],error == nil else {return}
            print(result)
          
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,let email = result["email"] as? String,let picture = result["picture"] as? [String:Any],let datas = picture["data"] as? [String: Any],let imageURL = datas["url"] as? String else {return}
            UserDefaults.standard.set(email, forKey: "email")
            DatabaseManager.shared.isUserExist(with: email) { exists in
                if !exists{
                    let chatUser =  ChatAppUsers(firstName: firstName, lastName: lastName, email: email)
                    DatabaseManager.shared.insertUser(with:chatUser, completion: { sucess in
                        if sucess {
//                            uplaod image
                            guard let url = URL(string: imageURL) else {return}
                            URLSession.shared.dataTask(with: url) { imageData, _, error in
                                guard let data = imageData else {return}
                                let fileName = chatUser.profilePictureFileName
                                StorageManager.shared.uplaodImage(with: data, fileName: fileName) { results in
                                    switch results{
                                    case .success(let downloadImage):
                                        UserDefaults.standard.set(downloadImage, forKey: "profile_picture")
                                        print(downloadImage)
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            }.resume()
                        }
                    })
                }
            }
            let creditials = FacebookAuthProvider.credential(withAccessToken: token)
            Auth.auth().signIn(with: creditials) { [weak self] authResults, error in
                guard let strongSelf = self else {return}
                guard authResults != nil,error == nil else {
                    print("User failed")
                    return
                }
                strongSelf.navigationController?.dismiss(animated: true)
            }
        }
       
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
//        do this later
    }
    
    
}
