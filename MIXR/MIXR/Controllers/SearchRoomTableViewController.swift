//
//  SearchRoomTableViewController.swift
//  MIXR
//
//  Created by Christopher Haas on 12/2/20.
//

import UIKit
import SwiftUI
import Firebase
import FirebaseAuth

class SearchRoomTableViewController: UITableViewController {
    
    
    @ObservedObject var roomsViewModel = OpenRoomsViewModel() 

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupToHideKeyboardOnTapOnView()
        
        
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkSpotifyAccess()
        
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        let ref = Database.database().reference()
        
        ref.child("rooms").queryOrdered(byChild: "isPrivate").queryEqual(toValue: false).queryLimited(toFirst: 15).observeSingleEvent(of: .value, with:  {
            DataSnapshot in
            if let r = DataSnapshot.value as? NSDictionary{
                if let keys = r.allKeys as? [String] {
                    var oRooms = [RoomModel]()
                    keys.forEach{ key in
                        
                        if let room = r[key] as? Dictionary<String, Any>{
                            print(room)
                            let id = room["id"] as! String
                            if id != "_" {
                                let size : String = room["size"] as? String ?? "4"
                                
                                
                                let r = RoomModel(idIn: room["id"] as! String, nameIn: room["name"] as! String, isPrivateIn: false, usersIn: [], limit: Int(size) ?? 4 )
                                oRooms.append(r)

                            }
                        }
                    }
                    self.roomsViewModel.rooms = oRooms
                    self.tableView.reloadData()
                }
                
                
                
               
                    
            }
        })
        
   
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return roomsViewModel.rooms.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = roomsViewModel.rooms[indexPath.row].name
        cell.textLabel?.textColor = UIColor.white
        cell.accessoryType = .none
        let accessView = UIView(frame: CGRect(x: cell.bounds.size.width - 50 , y: 0, width: 50 , height: cell.bounds.size.height))
        let roomLimit = UILabel(frame: CGRect(x:0 , y: 0, width: 50 , height: cell.bounds.size.height))
        roomLimit.backgroundColor = UIColor.clear
        roomLimit.textColor = UIColor.systemGreen
        roomLimit.text = "\(roomsViewModel.rooms[indexPath.row].users.count+1) / \(roomsViewModel.rooms[indexPath.row].limit)"
        roomLimit.font = UIFont.boldSystemFont(ofSize: 16)
        roomLimit.textAlignment = .center
        accessView.addSubview(roomLimit)
        cell.accessoryView = accessView
        
        
        cell.separatorInset = UIEdgeInsets.zero

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let c = roomsViewModel.rooms[indexPath.row].id
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell", for: indexPath)
        cell.accessoryView?.backgroundColor

        
        let ref = Database.database().reference()
        var p:NSDictionary?
        
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
          })
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
