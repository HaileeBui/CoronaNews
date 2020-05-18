//
//  ModifyUserViewController.swift
//  CoronaNews
//
//  Created by iosdev on 28.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import UIKit
import Firebase

class ModifyUserViewController: UIViewController, UITextFieldDelegate {
    // IBOutlets
    @IBOutlet weak var newEmailField: UITextField!
    @IBOutlet weak var newPassWordField: UITextField!
    @IBOutlet weak var verifyPassWordField: UITextField!
    @IBOutlet weak var oldPassWordField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var matchingErrorLabel: UILabel!
    @IBOutlet weak var modifyButton: UIButton!
    @IBOutlet weak var wrongPasswordLabel: UILabel!
    @IBOutlet weak var successLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newEmailField.delegate = self as UITextFieldDelegate
        newPassWordField.delegate = self as UITextFieldDelegate
        verifyPassWordField.delegate = self as UITextFieldDelegate
        oldPassWordField.delegate = self as UITextFieldDelegate
        modifyButton.isEnabled = false
        modifyButton.alpha = 0.5
        
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch")
        self.view.endEditing(true)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //set current username and email to editable fields
    override func viewDidAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        newEmailField.text = user?.email
    }
    
    @IBAction func modifyButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        let user = Auth.auth().currentUser
        // If nothing is nil and newpassword and verifypassword are the same
        if newPassWordField.text == verifyPassWordField.text && newEmailField.text != "" && oldPassWordField.text != "" && newPassWordField.text != "" && verifyPassWordField.text != "" {
            //check if the password you entered matches with the one of your account to modify the user
            print("nothing is nil, change everything")
            let credential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: oldPassWordField.text!)
            user?.reauthenticate(with: credential)  { (user, error) in
                if let error = error {
                    self.successLabel.isHidden = true
                    self.wrongPasswordLabel.isHidden = false
                    
                    print(error)
                } else {
                    //change email
                    Auth.auth().currentUser?.updateEmail(to: self.newEmailField.text!, completion: { (error) in
                        if error != nil
                        {
                            print("Error reauthenticating user")
                        } else {
                            print("email swap successful")
                        }
                    })
                    //change password
                    Auth.auth().currentUser?.updatePassword(to: self.newPassWordField.text!, completion: { (error) in
                        if error != nil {
                            print("error updating password")
                        } else {
                            print("password updated")
                            self.wrongPasswordLabel.isHidden = true
                            self.successLabel.isHidden = false
                        }
                        
                    })
                    //update displayname                    }
                    
                }
                
                
            }
            
            
            //if newpassword and verify are nil, but everything else is not
        } else if (newPassWordField.text == "" && verifyPassWordField.text == "" && newEmailField.text != "" && oldPassWordField.text != "") {
            //check if the password you entered matches with the one of your account to modify the user
            print("no new password entered, this should change only email")
            let credential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: oldPassWordField.text!)
            user?.reauthenticate(with: credential) { (user, error) in
                if let error = error {
                    self.successLabel.isHidden = true
                    self.wrongPasswordLabel.isHidden = false
                    print(error)
                } else {
                    //change email and username
                    Auth.auth().currentUser?.updateEmail(to: self.newEmailField.text!, completion: { (error) in
                        if error != nil
                        {
                            print("Error reauthenticating user")
                        } else {
                            print("email swap successful")
                            self.wrongPasswordLabel.isHidden = true
                            self.successLabel.isHidden = false
                        }
                    })
                }
            }
            
        } else {
            print("something went wrong")
        }
        
        
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == newEmailField {
            if !isValidEmail(newEmailField.text!) && newEmailField.text!.count > 0 {
                successLabel.isHidden = true
                emailErrorLabel.isHidden = false
                modifyButton.isEnabled = false
                modifyButton.alpha = 0.5
            } else {
                successLabel.isHidden = true
                emailErrorLabel.isHidden = true
                if oldPassWordField.text != "" && matchingErrorLabel.isHidden == true && emailErrorLabel.isHidden == true && passwordErrorLabel.isHidden == true {
                    modifyButton.isEnabled = true
                    modifyButton.alpha = 1
                }
            }
        } else if textField == newPassWordField {
            let count = newPassWordField.text!.count
            if count < 6 && count != 0 {
                passwordErrorLabel.isHidden = false
                verifyPassWordField.isEnabled = false
                modifyButton.isEnabled = false
                modifyButton.alpha = 0.5
                matchingErrorLabel.isHidden = false
                successLabel.isHidden = true
            } else if count == 0 {
                passwordErrorLabel.isHidden = true
                matchingErrorLabel.isHidden = true
                verifyPassWordField.isEnabled = false
                verifyPassWordField.text = ""
                successLabel.isHidden = true
                if oldPassWordField.text != "" && matchingErrorLabel.isHidden == true && emailErrorLabel.isHidden == true && passwordErrorLabel.isHidden == true {
                    modifyButton.isEnabled = true
                    modifyButton.alpha = 1
                } else {
                    successLabel.isHidden = true
                    modifyButton.isEnabled = false
                    modifyButton.alpha = 0.5
                }
            } else {
                verifyPassWordField.isEnabled = true
                matchingErrorLabel.isHidden = false
                passwordErrorLabel.isHidden = true
                successLabel.isHidden = true
                if newPassWordField.text == verifyPassWordField.text {
                    matchingErrorLabel.isHidden = true
                }
                if oldPassWordField.text != "" && matchingErrorLabel.isHidden == true && emailErrorLabel.isHidden == true && passwordErrorLabel.isHidden == true {
                    modifyButton.isEnabled = true
                    modifyButton.alpha = 1
                } else {
                    successLabel.isHidden = true
                    modifyButton.isEnabled = false
                    modifyButton.alpha = 0.5
                }
            }
        } else if textField == verifyPassWordField {
            if newPassWordField.text != verifyPassWordField.text && newPassWordField.text != "" {
                matchingErrorLabel.isHidden = false
                modifyButton.isEnabled = false
                modifyButton.alpha = 0.5
                successLabel.isHidden = true
            } else {
                successLabel.isHidden = true
                matchingErrorLabel.isHidden = true
                if oldPassWordField.text != "" && matchingErrorLabel.isHidden == true && emailErrorLabel.isHidden == true && passwordErrorLabel.isHidden == true {
                    modifyButton.isEnabled = true
                    modifyButton.alpha = 1
                } else {
                    modifyButton.isEnabled = false
                    modifyButton.alpha = 0.5
                }
            }
        } else {
            successLabel.isHidden = true
            if oldPassWordField.text != "" && matchingErrorLabel.isHidden == true && emailErrorLabel.isHidden == true && passwordErrorLabel.isHidden == true {
                modifyButton.isEnabled = true
                modifyButton.alpha = 1
                wrongPasswordLabel.isHidden = true
            } else {
                successLabel.isHidden = true
                modifyButton.isEnabled = false
                modifyButton.alpha = 0.5
            }
        }
        
    }
    
}
