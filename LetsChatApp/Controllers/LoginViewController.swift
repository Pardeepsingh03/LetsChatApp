//
//  LoginViewController.swift
//  LetsChatApp
//
//  Created by MBA-0019 on 27/07/23.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
      
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
    
}
