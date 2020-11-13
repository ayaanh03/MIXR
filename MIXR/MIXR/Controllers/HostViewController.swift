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
  
  var td:[String:String] = ["bruh":"testbruh"]
  
  

//
//  @IBOutlet weak var name: UITextField!
//  @IBOutlet weak var size: UILabel!
//
//  @IBOutlet weak var start: UIButton!
//  @IBOutlet weak var privacy: UISwitch!
//  @IBOutlet weak var sizestep: UIStepper!
//  @IBOutlet weak var length: UISlider!
//  @IBOutlet weak var lengthLabel: UILabel!
//
  

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
  
//  @IBAction func step(sender: UIStepper){
////    size.text = "bruh"
//    size.text = String(Int(sizestep.value))
//  }
//
//  @IBAction func lengths(sender: UISlider){
//    lengthLabel.text = String(Int(length.value))
//  }
//
//  Taken from https://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
  
  func randomString(length: Int) -> String {
    let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
  }
  
  @IBAction func makeR(sender: UIButton){
    var ref = Database.database().reference()
//    print("Creating Room as follows:")
//    print(name.text ?? "Your Mix")
//    print("Private: ", privacy.isOn)
//    print(size.text ?? "1 person")
//    print(lengthLabel.text ?? "0 minutes")
    
    var code = ""
    var p:NSDictionary?
    
    while true
    {
       
      code = randomString(length: 4)
      ref.child("rooms/\(code)").observe(DataEventType.value) { (DataSnapshot) in
        
        p = DataSnapshot.value as? NSDictionary ?? nil
      }
      if p==nil {break}
    }
    let user  = Auth.auth().currentUser
    var uid = ""
    if let user = user{
      uid = user.uid 
    }
    let newR = [ "id":code, "name": "Your Mix", "isPrivate": true,"size": "1", "length":"15","users":[uid,"2"]] as [String : Any]
    
    ref.child("rooms/\(code)").setValue(newR)
    
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let newViewController = storyBoard.instantiateViewController(withIdentifier: "MixHostViewController") as! MixHostViewController
    newViewController.roomCode = code
    self.navigationController!.pushViewController(newViewController, animated: true)
    
  }
  

}
