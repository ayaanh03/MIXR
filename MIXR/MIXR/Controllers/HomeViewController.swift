//
//  ViewController.swift
//  MIXR
//
//  Created by Christopher Haas on 11/6/20.
//

import UIKit
import FirebaseAuth
import Firebase

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
  
    
    @IBAction func signOutTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            
            let loginController = storyboard.instantiateViewController(identifier: "LoginViewController")
            (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = loginController
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
      
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        print("buttonTapped")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let appRemote = appDelegate.appRemote
        appRemote.authorizeAndPlayURI("", asRadio: false, additionalScopes: ["playlist-modify-public", "playlist-modify-private", "user-modify-playback-state", "user-library-modify"])
        //print(appRemote.authorizationParametersFromURL())
        print("accessToken is ", appDelegate.accessToken)
        
       
        
//         Want to play a new track?
//         appRemote.playerAPI?.play("spotify:track:13WO20hoD72L0J13WTQWlT", callback: { (result, error) in
//             if let error = error {
//                 print(error.localizedDescription)
//             }
//         })
        

            
        
    }
    

}

