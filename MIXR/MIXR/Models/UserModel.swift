//
//  UserModel.swift
//  MIXR
//
//  Created by Yin junwei on 11/6/20.
//

import Foundation
import Firebase

class UserModel {
    private var email: String
    private var uid: String
    private var rooms: [String]
    
    var refUsers: DatabaseReference!
    
    init(userId: String, emailInput: String) {
        uid = userId
        email = emailInput
        rooms = ["temp"]
        refUsers = Database.database().reference().child("users")
    }
    
    func saveToDB() {
        let userToSave = ["uid": uid, "email": email, "rooms": rooms] as [String : Any]
        refUsers.child(uid).setValue(userToSave)
    }
    
//    func joinNewRoom(roomId: String) {
//
//    }
    
    
}
