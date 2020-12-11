//
//  HostViewController.swift
//  MIXR
//
//  Created by Christopher Haas on 11/6/20.
//


import UIKit
import Firebase
import FirebaseAuth

class HostViewController: UIViewController {
  


    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var size: UITextField!
    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var length: UITextField!

  

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupToHideKeyboardOnTapOnView()

        // Do any additional setup after loading the view.
    }
  

//  Taken from https://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
  
  func randomString(length: Int) -> String {
    let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
  }
  
  @IBAction func makeR(sender: UIButton){
    let ref = Database.database().reference()

    var code = ""
    var p:NSDictionary?
    
    while true
    {
       
      code = randomString(length: 4)
      ref.child("rooms/\(code)").observe(DataEventType.value) { (DataSnapshot) in
        
        p = DataSnapshot.value as? NSDictionary ?? nil
      }
      if p == nil {break}
    }
    let user  = Auth.auth().currentUser
    
    
    //If signed in, allow creation of room
    if let user = user{
        
      let uid = user.uid
        let newR = [
            "id": code,
            "name": name.text ?? "Playlist",
            "isPrivate": privacySwitch.isOn,
            "size": size.text ?? "1",
            "length": length.text ?? "15",
            "host": uid,
            "active" : true,
            "users": [uid]
        ] as [String : Any]
        
        ref.child("rooms/\(code)").setValue(newR)
        let dbService = DatabaseServiceHelper()
        dbService.getUserFromDB(uid: uid) { (u) in
            var rooms: Array<Dictionary<String, String>> = []
            for r in u.rooms {
                rooms.append(["id": r.id, "name": r.name])
            }
            rooms.append(["id": code, "name": self.name.text ?? "Playlist"])
            debugPrint(rooms)
            ref.child("users/\(uid)/rooms").setValue(rooms)
        }
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "MixRoomViewController") as! MixRoomViewController
        newViewController.roomCode = code
        self.navigationController!.pushViewController(newViewController, animated: true)
        
    }
    
  }
  

}
