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
    
    var refUsers: DatabaseReference!
    var user = UserModel()
    // var uid = "eKgDWI1jyYPblTzzms88qym5KOI3"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        refUsers = Database.database().reference().child("users")
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
            
            let userCurr = Auth.auth().currentUser!;
            self.getUserFromDB(uid: userCurr.uid)
            debugPrint(self.user.uid)
            debugPrint("login success")
            
            return
        })
    }
    
    func getUserFromDB(uid: String) {
        refUsers.child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            self.user.uid = value!["id"]! as! String
            self.user.email = value!["email"]! as! String
            // self.user.rooms = value!["rooms"]! as! [RoomModel]
        }) {(error) in
            debugPrint(error.localizedDescription)
            return
        }
    }
    
    @IBAction func signupTapped(_ sender: Any) {
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
