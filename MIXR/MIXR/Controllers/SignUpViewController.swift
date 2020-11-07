//
//  SignUpViewController.swift
//  MIXR
//
//  Created by Christopher Haas on 11/6/20.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var passConfirmTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /**
            Only printing out results now
            TODO:  Show alert messages to notify user sign up error.
     */
    @IBAction func createTapped(_ sender: Any) {
        debugPrint("signupButton tapped")
        
        
        let email = emailTextField.text!
        let password = passTextField.text!
        let confirmPassword = passConfirmTextField.text!
        
        if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
            debugPrint("empty fields")
            return
        }
        
        if (confirmPassword != password) {
            debugPrint("Passwords not match")
            return
        }
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { result, error in
            guard error == nil else {
                if let errCode = AuthErrorCode(rawValue: error!._code) {

                    switch errCode {
                        case .invalidEmail:
                            debugPrint("invalid email")
                        case .emailAlreadyInUse:
                            debugPrint("in use")
                        case .weakPassword:
                            debugPrint("The password must be 6 characters long or more")
                        default:
                            debugPrint("Create User Error: \(error!)")
                    }
                }
                return
            }
            let userCurr = Auth.auth().currentUser;
            
            let newUser = UserModel(userId: userCurr!.uid, emailInput: userCurr!.email!)
            newUser.saveToDB()
            debugPrint("sign up success")
            return
        })
    }
    

}
