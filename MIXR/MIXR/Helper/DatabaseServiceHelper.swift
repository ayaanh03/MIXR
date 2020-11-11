//
//  DatabaseServiceHelper.swift
//  MIXR
//
//  Created by Yin junwei on 11/10/20.
//

import Foundation
import FirebaseDatabase

class DatabaseServiceHelper {
    let refUsers: DatabaseReference! = Database.database().reference().child("users")
    
    func getUserFromDB(uid: String, completionHandler: @escaping (UserModel) -> Void) {
        refUsers.child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            let user = UserModel()
            let value = snapshot.value as? NSDictionary
            user.uid = value!["id"]! as! String
            user.email = value!["email"]! as! String
            let roomsArray = value!["rooms"]! as! Array<Dictionary<String, String>>
            for r in roomsArray {
                if r["id"] != "_" {
                    let room = RoomModel(idIn: r["id"]!, nameIn: r["name"]!, isPrivateIn: true, usersIn: [])
                    user.rooms.append(room)
                }
            }
            completionHandler(user)
        }) {(error) in
            debugPrint(error.localizedDescription)
            return
        }
    }
    
}
