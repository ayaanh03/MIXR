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
    
    
    let DEFAULT_ROOMS: [String] = ["temp"]
    var refUsers: DatabaseReference!
    var user = UserModel()
    var text: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        refUsers = Database.database().reference().child("users")
        debugPrint("Test for push " + text)
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
            
            self.saveToDB(uid: userCurr!.uid, email: userCurr!.email!)
            debugPrint("sign up success")
            
            self.user.uid = userCurr!.uid
            self.user.email = userCurr!.email!
            self.user.password = password            
            // debugPrint(self.user.uid)
            return
        })
    }
    
    func saveToDB(uid: String, email: String) {
        let user = ["id": uid, "email": email, "rooms": self.DEFAULT_ROOMS] as [String : Any]
        refUsers.child(uid).setValue(user)
    }
    /**
        Pass user to next ViewController
     */
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "signUpClick" {
    //            let vc = segue.destination as! SignUpViewController
    //            vc.text = self.user.email
    //        }
    //
    //    }
    

}
