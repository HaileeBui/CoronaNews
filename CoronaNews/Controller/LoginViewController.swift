//
//  LoginViewController.swift
//  CoronaNews
//
//  Created by iosdev on 20.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButtton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self as UITextFieldDelegate
        passwordField.delegate = self as UITextFieldDelegate

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch")
        self.view.endEditing(true)
    }
    
     func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        guard let email = emailField.text,
            let password = passwordField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                debugPrint("Error signing in: \(error)")
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tab = storyboard.instantiateViewController(identifier: "tabBar") as! UITabBarController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                tab.modalPresentationStyle = .fullScreen
                self.present(tab, animated: true, completion: nil)
            }
        }
    }

}
