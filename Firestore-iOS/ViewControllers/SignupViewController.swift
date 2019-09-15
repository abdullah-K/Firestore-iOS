//
//  SignupViewController.swift
//  Firestore-iOS
//
//  Created by Abdullah Khan on 2019-09-14.
//  Copyright © 2019 Abdullah Khan. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignupViewController: UIViewController {
    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.layer.cornerRadius = 15
        
        hideErrorLabel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func dismissKeyboard() {
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func hideErrorLabel() {
        errorLabel.alpha = 0
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func validateFields() -> String? {
        if FormUtilities.sanitizeInput(firstNameInput) == "" ||
            FormUtilities.sanitizeInput(lastNameInput) == "" ||
            FormUtilities.sanitizeInput(emailInput) == "" ||
            FormUtilities.sanitizeInput(passwordInput) == "" {
            return "Please fill in all the fields"
        }
        
        let cleanPassword = FormUtilities.sanitizeInput(passwordInput)
        if !FormUtilities.isValidPassword(cleanPassword) {
            return "Password must have 8+ characters, at least one letter and one number"
        }
        return nil
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        // validate fields
        let error = validateFields()
        if error != nil {
            showError(error!)
        }
        // create user
        else {
            let firstName = FormUtilities.sanitizeInput(firstNameInput)
            let lastName = FormUtilities.sanitizeInput(lastNameInput)
            
            let email = FormUtilities.sanitizeInput(emailInput)
            let password = FormUtilities.sanitizeInput(passwordInput)
            
            Auth.auth().createUser(withEmail: email, password: password ) { (result, err) in
                // something went wrong while creating user
                if err != nil {
                    self.showError("Error creating user. Please try again later!")
                }
                // user was created successfully
                else {
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["firstName": firstName, "lastName": lastName, "uid": result!.user.uid], completion: { (error) in
                        // something went wrong when saving first and last name
                        if error != nil {
                            self.showError("User data couldn't be saved properly")
                        }
                    })
                }
            }
            self.transitionToHome()
        }
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
}
