//
//  RegisterViewController.swift
//  CoronaNews
//
//  Created by iosdev on 20.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self as UITextFieldDelegate
        usernameField.delegate = self as UITextFieldDelegate
        passwordField.delegate = self as UITextFieldDelegate
        registerButton.isEnabled = false
        registerButton.alpha = 0.5
        
        

        // Do any additional setup after loading the view.
    }
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    @IBAction func registerTapped(_ sender: Any) {
        guard let email = emailField.text,
            let username = usernameField.text,
            let password = passwordField.text else { return }
        
        if isValidEmail(email) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                debugPrint("Error creating user: \(error)")
            }
            
            let changeRequest = user?.user.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges(completion: { (error) in
                if let error = error {
                    debugPrint(error)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch")
        self.view.endEditing(true)
    }
    
    //MARK; UITextFieldDelegate
       func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == usernameField {
           print("started editing usernamefield")
            
        } else if textField == passwordField {
            print("started editing passwordfield")
        } else {
            print("started editing emailfield")
            print(isValidEmail(emailField.text!))
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == usernameField {
            let maxLength = 12
            let currentString: NSString = usernameField!.text as! NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
            if textField == usernameField {
            let fieldTextLength = usernameField.text!.count

            if  fieldTextLength < 4 && fieldTextLength > 0 {

                    registerButton.isEnabled = false
                    registerButton.alpha = 0.5
                usernameErrorLabel.isHidden = false

            } else if passwordField.text != "" && emailField.text != "" && usernameField.text != "" && isValidEmail(emailField.text!) {
                registerButton.isEnabled = true
                registerButton.alpha = 1
                resignFirstResponder()
            } else {
                usernameErrorLabel.isHidden = true
                }
            self.view.endEditing(true)

            } else if textField == passwordField {
                let fieldTextLength = passwordField.text!.count

                if  fieldTextLength < 6 && fieldTextLength > 0 {
                        registerButton.isEnabled = false
                    registerButton.alpha = 0.5
                    passwordErrorLabel.isHidden = false
                } else if passwordField.text != "" && emailField.text != "" && usernameField.text != "" && isValidEmail(emailField.text!) {
                    registerButton.isEnabled = true
                    registerButton.alpha = 1
                    passwordErrorLabel.isHidden = true
                    resignFirstResponder()
                } else {
                    passwordErrorLabel.isHidden = true
                }

            } else {
                if !isValidEmail(emailField.text!) && emailField.text!.count > 0 {
                    emailErrorLabel.isHidden = false
                    registerButton.isEnabled = false
                    registerButton.alpha = 0.5
                } else if passwordField.text != "" && emailField.text != "" && usernameField.text != "" && isValidEmail(emailField.text!) {
                        registerButton.isEnabled = true
                    registerButton.alpha = 1
                    emailErrorLabel.isHidden = true
                    resignFirstResponder()
                } else {
                    emailErrorLabel.isHidden = true
                }
            }
        }
    
    /*
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
        let fieldTextLength = usernameField.text!.count

        if  fieldTextLength < 6 {

                registerButton.isEnabled = false
            let alert = UIAlertController(title: "Username", message: "Username is too short, use minimum of 6 characters", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "back", style: .cancel, handler: nil))
            self.present(alert, animated: true)

        } else if passwordField.text != "" && emailField.text != "" && usernameField.text != "" && isValidEmail(emailField.text!) {
            registerButton.isEnabled = true
            resignFirstResponder()
        }
        self.view.endEditing(true)
        return true
        } else if textField == passwordField {
            let fieldTextLength = passwordField.text!.count

            if  fieldTextLength < 6 {
                    registerButton.isEnabled = false
                let alert = UIAlertController(title: "Wrong input", message: "Password is too short, use minimum of 6 characters", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "back", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            } else if passwordField.text != "" && emailField.text != "" && usernameField.text != "" && isValidEmail(emailField.text!) {
                registerButton.isEnabled = true
                resignFirstResponder()
            }
            return true
        } else {
            if !isValidEmail(emailField.text!) {
                let alert = UIAlertController(title: "Wrong input", message: "Email adress is not valid", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "back", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                registerButton.isEnabled = false
            } else if passwordField.text != "" && emailField.text != "" && usernameField.text != "" && isValidEmail(emailField.text!) {
                    registerButton.isEnabled = true
                resignFirstResponder()
                }
            return true
        }
    }
    */
    
    
}
