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
    
    
    let DEFAULT_ROOMS: Dictionary<String, String> = ["id": "_", "name": "_"]
    var refUsers: DatabaseReference!
    var user = UserModel()
    var text: String = ""
    
    
    override func viewDidLoad() {
        self.setupToHideKeyboardOnTapOnView()
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
            let alert = UIAlertController(title: "Sign up failed", message: "You have empty fields.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            return
        }
        
        if (confirmPassword != password) {
            debugPrint("Passwords not match")
            let alert = UIAlertController(title: "Sign up failed", message: "Two passwords you entered don't match.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            return
        }
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { result, error in
            guard error == nil else {
                if let errCode = AuthErrorCode(rawValue: error!._code) {

                    switch errCode {
                        case .invalidEmail:
                            debugPrint("invalid email")
                            let alert = UIAlertController(title: "Sign up failed", message: "The email address is invalid.", preferredStyle: .alert)

                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

                            self.present(alert, animated: true)
                        case .emailAlreadyInUse:
                            debugPrint("in use")
                            let alert = UIAlertController(title: "Sign up failed", message: "You already have an account with this email, please login.", preferredStyle: .alert)

                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

                            self.present(alert, animated: true)
                        case .weakPassword:
                            debugPrint("The password must be 6 characters long or more")
                            let alert = UIAlertController(title: "Sign up failed", message: "Your password is too weak, must be at least 6 characters long or more.", preferredStyle: .alert)

                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

                            self.present(alert, animated: true)
                        default:
                            debugPrint("Create User Error: \(error!)")
                            let alert = UIAlertController(title: "Sign up failed", message: "Sign up failed.", preferredStyle: .alert)

                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

                            self.present(alert, animated: true)
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
            
            // Change Root View Controller to TabBarController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
            (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = mainTabBarController
            // debugPrint(self.user.uid)
            return
        })
    }
    
    func saveToDB(uid: String, email: String) {
        let user = ["id": uid, "email": email, "rooms": [DEFAULT_ROOMS]] as [String : Any]
        refUsers.child(uid).setValue(user)
    }
    /**
        Pass user.uid to next ViewController
     */
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "signUpClick" {
    //            let vc = segue.destination as! SignUpViewController
    //            vc.text = self.user.uid
    //        }
    //
    //    }
    

}
