//
//  LoginViewController.swift
//  Firestore-iOS
//
//  Created by Abdullah Khan on 2019-09-14.
//  Copyright © 2019 Abdullah Khan. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 15;
        
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
        errorLabel.alpha = 0;
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height + 20)
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
        if FormUtilities.sanitizeInput(emailInput) == "" ||
            FormUtilities.sanitizeInput(passwordInput) == "" {
            return "Please fill in all the fields"
        }
        return nil
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        // validate text fields
        let error = validateFields()
        if error != nil {
            showError(error!)
        }
        else {
            
        
        let email = FormUtilities.sanitizeInput(emailInput)
        let password = FormUtilities.sanitizeInput(passwordInput)
        // sign in the user
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    self.errorLabel.text! = error!.localizedDescription
                    self.errorLabel.alpha = 1
                }
                else {
                    self.transitionToHome()
                }
            }
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
