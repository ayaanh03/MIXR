//
//  JoinViewController.swift
//  MIXR
//
//  Created by Christopher Haas on 11/6/20.
//


import UIKit
import Firebase
import FirebaseAuth

class JoinViewController: UIViewController {
    

    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var submitCode: UIButton!
    
    override func viewDidLoad() {
        self.setupToHideKeyboardOnTapOnView()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
  
  @IBAction func pressB(sender: UIButton){
    let ref = Database.database().reference()
    var p:NSDictionary?
    if let c = codeTextField.text {
      if c.count != 4 {
        print("Error code too long")
      }
      else {
        ref.child("rooms/\(c)").observeSingleEvent(of: .value, with: { (DataSnapshot) in
          p = DataSnapshot.value as? NSDictionary
          if let a = p
          {

            //Check if there are already users
            if let usersArr = a["users"] as? NSArray{
                var b:[String] = usersArr.compactMap({$0 as? String})
                if let user  = Auth.auth().currentUser {
                
                  let uid = user.uid
                    if !b.contains(uid) {
                        b.append(uid)
                        
                        ref.child("rooms/\(c)/users").setValue(b)
                        
                        let dbService = DatabaseServiceHelper()
                        dbService.getUserFromDB(uid: uid) { (u) in
                            var rooms: Array<Dictionary<String, String>> = []
                            for r in u.rooms {
                                rooms.append(["id": r.id, "name": r.name])
                            }
                            rooms.append(["id": c, "name": a["name"] as! String])
                            // debugPrint(rooms)
                            ref.child("users/\(uid)/rooms").setValue(rooms)
                        }
                    }
                }
                
            }
            // add a users array
            else {
                if let user  = Auth.auth().currentUser {
                    let uid = user.uid
                    ref.child("rooms/\(c)/users").setValue([uid])
                }
                
            }
            
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "MixRoomViewController") as! MixRoomViewController
            newViewController.roomCode = c
            self.navigationController!.pushViewController(newViewController, animated: true)
          }
          else {
            // from https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
            let alert = UIAlertController(title: "Invalid Code", message: "No rooms exist with that code", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                  switch action.style{
                  case .default:
                        print("default")
                  case .cancel:
                        print("cancel")
                  case .destructive:
                        print("destructive")
                  @unknown default:
                    fatalError()
                  }}))
            self.present(alert, animated: true, completion: nil)
          }
        })
      }
    }
  }
  
}
