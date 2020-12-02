//
//  AccountViewController.swift
//  MIXR
//
//  Created by Christopher Haas on 12/2/20.
//

import UIKit
import FirebaseAuth
import Firebase

class AccountViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
  
    
    @IBAction func signOutTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            
            let loginController = storyboard.instantiateViewController(identifier: "LoginViewController")
            (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = loginController
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
      
    }
    

    

}
