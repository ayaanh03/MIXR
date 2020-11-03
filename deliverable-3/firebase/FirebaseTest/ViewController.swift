//
//  ViewController.swift
//  FirebaseTest
//
//  Created by Yin junwei on 10/25/20.
//

import UIKit
import FirebaseAuth
import Firebase

class ViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var mixTextField: UITextField!
    

    var refUsers: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        refUsers = Database.database().reference().child("users")
    }
    
    
    @IBAction func loginButtonTapped() {
        debugPrint("loginButton tapped")
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if (email.isEmpty || password.isEmpty) {
//            let alert = UIAlertController(title: "Empty fields",
//                                          message: "Empty fields",
//                                          preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in}))
//            present(alert, animated: true)
            debugPrint("empty fields")
        }
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { result, error in
            guard error == nil else {
                if let errCode = AuthErrorCode(rawValue: error!._code) {

                    switch errCode {
                        case .invalidEmail:
                            debugPrint("invalid email")
                        case .wrongPassword:
                            debugPrint("Wrong password")
                        default:
                            debugPrint("Create User Error: \(error!)")
                    }
                }
                return
            }
            
            debugPrint("login success")
            return
        })
    }
    
    @IBAction func signupButtonTapped() {
        debugPrint("signupButton tapped")
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if (email.isEmpty || password.isEmpty) {
//            let alert = UIAlertController(title: "Empty fields",
//                                          message: "Empty fields",
//                                          preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in}))
//            present(alert, animated: true)
            debugPrint("empty fields")
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
            
            debugPrint("sign up success")
            self.addNewUser(email: email)
            return
        })
        
    }
    
    func addNewUser(email: String) {
//        let user = ["id": email, "rooms": [String]()] as [String : Any]
//        refUsers.child(email).setValue(user)
    }
    
    @IBAction func createButtonTapped() {

    }

    @IBAction func joinButtonTapped() {
        
    }


}

