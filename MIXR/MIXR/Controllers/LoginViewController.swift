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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupToHideKeyboardOnTapOnView()
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
            self.user.uid = userCurr.uid
            /**
                Just testing DatabaseServiceHelper's functionality
                Functionality works fine!
             */
//            let dbService = DatabaseServiceHelper()
//            dbService.getUserFromDB(uid: userCurr.uid) { (u) in
//                debugPrint(u.uid)
//                debugPrint(u.email)
//                debugPrint(u.rooms[0].id)
//                debugPrint(u.rooms[0].name)
//                debugPrint(u.rooms[1].id)
//                debugPrint(u.rooms[1].name)
//                debugPrint(u.rooms.count)
//            }
            debugPrint(self.user.uid)
            debugPrint("login success")
            
            // Change Root View Controller to TabBarController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
            (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = mainTabBarController
            
            return
        })
    }
    
    @IBAction func signupTapped(_ sender: Any) {
    }
    
    /**
            Pass user.uid to next viewController
     */
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "signUpClick" {
//            let vc = segue.destination as! SignUpViewController
//            vc.text = self.user.uid
//        }
//
//    }
        
    
}


