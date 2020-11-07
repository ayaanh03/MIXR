//
//  File.swift
//  MIXR
//
//  Created by Christopher Haas on 11/6/20.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /**
            Only printing out results now
            TODO:  Show alert messages to notify user log in error.
     */
    @IBAction func loginTapped(_ sender: Any) {
        debugPrint("loginButton tapped")
        let email = emailTextField.text!
        let password = passTextField.text!
        
        if (email.isEmpty || password.isEmpty) {
            debugPrint("empty fields")
            return
        }
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { result, error in
            guard error == nil else {
                if let errCode = AuthErrorCode(rawValue: error!._code) {

                    switch errCode {
                        case .invalidEmail:
                            debugPrint("invalid email")
                        case .wrongPassword:
                            debugPrint("Wrong password")
                        case .userNotFound:
                            debugPrint("You don't have an account yet, please sign up")
                        default:
                            debugPrint("Login User Error: \(error!)")
                    }
                }
                return
            }
            
            debugPrint("login success")
            return
        })
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        
    }
    
        
        
    
}
