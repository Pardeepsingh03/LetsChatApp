//
//  RegisterViewController.swift
//  LetsChatApp
//
//  Created by MBA-0019 on 27/07/23.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
         super.viewDidLoad()
         title = "Register"
        setUpUI()
         // Add a tap gesture recognizer to the image view
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
         imageView.isUserInteractionEnabled = true
         imageView.addGestureRecognizer(tapGesture)
     }
     
     @objc func imageViewTapped() {
         // Handle the tap on the image view
         openImagePicker()
     }
    
    private func setUpUI(){
        imageView.layer.cornerRadius = imageView.frame.height / 2
        
    }
    
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        guard let email = emailTextField.text,let pass = passwordTextField.text,let firstName = firstNameTextField.text,let lastName = lastNameTextField.text, !email.isEmpty,!lastName.isEmpty,!pass.isEmpty,!firstName.isEmpty else {
            showAlert(messages: "Please fill in both email and password fields.")
            return
        }
        
        DatabaseManager.shared.isUserExist(with: email) { [weak self] exits in
            guard let strongSelf = self else {return}
            guard !exits else{
                strongSelf.showAlert(messages: "Looks like there is a already usee exists on this email.")
                return
            }
            Auth.auth().createUser(withEmail: email, password: pass) {authResult, error in
                guard authResult != nil,error == nil else {return}
                DatabaseManager.shared.insertUser(with: ChatAppUsers(firstName: firstName, lastName: lastName, email: email))
                strongSelf.navigationController?.dismiss(animated: true)
            }
        }
    }
    
    private func showAlert(messages: String){
        let alert = UIAlertController(title: "Error", message: messages, preferredStyle: .alert)
         let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
         alert.addAction(okAction)

         // Present the alert
         present(alert, animated: true, completion: nil)
    }
    
}

extension RegisterViewController {
    func openImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        // Add action to choose from the gallery
        actionSheet.addAction(UIAlertAction(title: "Choose from Gallery", style: .default) { [weak self] _ in
            imagePicker.sourceType = .photoLibrary
            self?.present(imagePicker, animated: true, completion: nil)
        })
        
        // Check if the device has a camera before adding the action to take a picture
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // Add action to take a picture
            actionSheet.addAction(UIAlertAction(title: "Take a Picture", style: .default) { [weak self] _ in
                imagePicker.sourceType = .camera
                self?.present(imagePicker, animated: true, completion: nil)
            })
        }
        
        // Add cancel action
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the action sheet
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

