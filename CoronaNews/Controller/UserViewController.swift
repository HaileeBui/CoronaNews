//
//  UserViewController.swift
//  CoronaNews
//
//  Created by iosdev on 26.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import UIKit
import Firebase

class UserViewController: UIViewController {
    
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        EmailLabel.text = user?.email
        UserNameLabel.text = user?.displayName
    }

    @IBAction func logoutTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signoutError as NSError {
            debugPrint("Error signing out: \(signoutError)")
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(identifier: "LoginViewController")
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true, completion: nil)
    }
}
