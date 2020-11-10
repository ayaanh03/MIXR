//
//  FirebaseHelper.swift
//  MIXR
//
//  Created by Yin junwei on 11/6/20.
//

import Foundation
import FirebaseAuth
import Firebase

class FirebaseHelper {
    
    func userSignUp(user: UserModel) -> Dictionary<String, Any> {
        var success: Bool = true
        var message: String = ""
        FirebaseAuth.Auth.auth().createUser(withEmail: user.getEmail(), password: user.getPassword(), completion: { result, error in
            guard error == nil else {
                if let errCode = AuthErrorCode(rawValue: error!._code) {

                    switch errCode {
                        case .invalidEmail:
                            debugPrint("invalid email")
                            message = "invalid email"
                            break
                        case .emailAlreadyInUse:
                            debugPrint("in use")
                            message = "email already in use"
                            break
                        case .weakPassword:
                            debugPrint("The password must be 6 characters long or more")
                            message = "The password must be 6 characters long or more"
                            break
                        default:
                            debugPrint("Create User Error: \(error!)")
                            message = "Create user error"
                            
                    }
                }
                success = false
                return
            }
            let userCurr = Auth.auth().currentUser;
            
            
        })
        if (success) {
            return ["success": true, "user": "User sign up success"]
        }
    }
}
