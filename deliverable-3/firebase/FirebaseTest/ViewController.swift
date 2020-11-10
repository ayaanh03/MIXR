//
//  ViewController.swift
//  FirebaseTest
//
//  Created by Yin junwei on 10/25/20.
//

import UIKit
import FirebaseAuth
import Firebase
// import CryptoSwift

class ViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var mixTextField: UITextField!
    

    var refUsers: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        refUsers = Database.database().reference().child("users")
//        do {
//            let aes = try AES(key: "keykeykeykeykeyk", iv: "drowssapdrowssap") // aes128
//            debugPrint(aes)
//            let ciphertext = try aes.encrypt(Array("Nullam quis risus eget urna mollis ornare vel eu leo.".utf8))
//            debugPrint(ciphertext)
//        } catch { }
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
            var user = Auth.auth().currentUser;
            debugPrint(user!.uid)
            debugPrint(user!.email)
            debugPrint("sign up success")
            self.addNewUser(uid: user!.uid, email: user!.email!)
            return
        })
        
    }
    
    func addNewUser(uid: String, email: String) {
        
        // let key = refUsers.childByAutoId().key
        
        let user = ["id": uid, "email": email, "rooms": ["temp"]] as [String : Any]
        refUsers.child(uid).setValue(user)
        
        // read data from firebase
        refUsers.child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            debugPrint(value!)
            debugPrint(value!["id"]!)
            debugPrint(value!["rooms"]!)
            
            // update entry
            var newRoom: [String] = value!["rooms"]! as? Array<String> ?? []
            newRoom.append("a")
            debugPrint(newRoom)

            let updatedUser = ["id": value!["id"]!, "email": value!["email"]!, "rooms": newRoom]
            self.refUsers.child(uid).updateChildValues(updatedUser)
            
        }) {(error) in
            debugPrint(error.localizedDescription)
        }
        

    }
    
    @IBAction func createButtonTapped() {

    }

    @IBAction func joinButtonTapped() {
        
    }


}

