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
    var ref = Database.database().reference()

    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var submitCode: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
  
  @IBAction func pressB(sender: UIButton){
    var p:NSDictionary?
    if let c = codeTextField.text {
      if c.count != 4 {
        print("Error code too long")
      }
      else {
        ref.child("rooms/\(c)").observeSingleEvent(of: .value, with: { (DataSnapshot) in
//          print("bruh",DataSnapshot.value)
          p = DataSnapshot.value as? NSDictionary
          if let a = p
          {
//            print()
            let temp = a["users"] as! NSArray
            var b:[String] = temp.compactMap({$0 as? String})
            let user  = Auth.auth().currentUser
            var uid = "brhu"
            if let user = user{
              uid = user.uid
            }
            b.append(uid)
            print(b)
            self.ref.child("rooms/\(c)/users").setValue(b)
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "MixViewController") as! MixViewController
                    self.present(newViewController, animated: true, completion: nil)
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
