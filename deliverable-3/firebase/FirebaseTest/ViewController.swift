//
//  ViewController.swift
//  FirebaseTest
//
//  Created by Yin junwei on 10/25/20.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
                debugPrint("login failed")
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
                debugPrint("sign up failed")
                return
            }
            
            debugPrint("sign up success")
            return
        })
        
    }


}

