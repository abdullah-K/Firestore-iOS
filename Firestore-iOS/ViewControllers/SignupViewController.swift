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
    
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.layer.cornerRadius = 15
        registerForKeyboardNotifications()
        firstNameInput.addTarget(lastNameInput, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        lastNameInput.addTarget(emailInput, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        emailInput.addTarget(passwordInput, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        hideErrorLabel()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // dimiss keyboard when keyboard return key is pressed (currently connected to the password field)
    @IBAction func done(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    func hideErrorLabel() {
        errorLabel.alpha = 0
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func onKeyboardAppear(_ notification: NSNotification) {
        let info = notification.userInfo!
        let rect: CGRect = info[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardSize = rect.size
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        // If active text field is hidden by keyboard, scroll to it so it's visible
        var aRect = self.view.frame;
        aRect.size.height -= keyboardSize.height;
        
        let activeField: UITextField? = [firstNameInput, lastNameInput, emailInput, passwordInput].first { $0.isFirstResponder }
        if let activeField = activeField {
            if !aRect.contains(activeField.frame.origin) {
                let scrollPoint = CGPoint(x: 0, y: activeField.frame.origin.y-(keyboardSize.height + 10))
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
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
                    
                    // save user id to UserDefaults to keep them signed in
                    UserDefaults.standard.set(result!.user.uid, forKey: "uid")
//                    UserDefaults.standard.set(firstName, forKey: "userFirstName")
                    UserDefaults.standard.synchronize()
                    
                    // save first and lastname to users db
                    db.collection("users").document(result!.user.uid as String).setData(["firstName": firstName, "lastName": lastName, "uid": result!.user.uid], completion: { (error) in
                        // something went wrong when saving first and last name
                        if error != nil {
                            self.showError("User data couldn't be saved properly")
                        }
                    })
                    
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
