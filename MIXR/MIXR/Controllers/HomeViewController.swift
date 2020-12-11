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
//        let dbService = DatabaseServiceHelper()
//        dbService.generateProcess(roomCode: "09JQ") { (flag) in
//            debugPrint(flag)
//
//        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkSpotifyAccess()
    }
  
    
    

    

}

