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
    let refRooms: DatabaseReference! = Database.database().reference().child("rooms")
    let refPlaylists: DatabaseReference! = Database.database().reference().child("playlists")
    
    func getUserFromDB(uid: String, completionHandler: @escaping (UserModel) -> Void) {
        refUsers.child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            let user = UserModel()
            let value = snapshot.value as? NSDictionary
            user.uid = value!["id"]! as! String
            user.email = value!["email"]! as! String
            let roomsArray = value!["rooms"]! as! Array<Dictionary<String, String>>
            let playlistArray = value!["playlists"]! as! Array<Dictionary<String, String>>
            for r in roomsArray {
                if r["id"] != "_" {
                    let room = RoomModel(idIn: r["id"]!, nameIn: r["name"]!, isPrivateIn: true, usersIn: [])
                    user.rooms.append(room)
                }
            }
            
            for p in playlistArray {
                if p["id"] != "_" {
                    let playlist = RoomModel(idIn: p["id"]!, nameIn: p["name"]!, isPrivateIn: true, usersIn: [])
                    user.playlists.append(playlist)
                }
            }
            completionHandler(user)
        }) {(error) in
            debugPrint(error.localizedDescription)
            return
        }
    }
    
    func generateProcess(roomCode: String, completionHandler: @escaping (Bool) -> Void) {
        refRooms.child(roomCode).observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            let name = value!["name"]! as! String
            let songs = value!["addedSongs"]! as! Array<String>
            let users = value!["users"]! as! Array<String>
//            var addedSongs: Array<String> = []
//            for s in songs {
//                addedSongs.append(s)
//            }
            
            // create a new playlist in db
            let id = self.refPlaylists.childByAutoId().key!
            self.refPlaylists.child(id).setValue(["name": name, "addedSongs": songs])
            
            for user in users {
                self.refUsers.child(user).observeSingleEvent(of: .value, with: {(snapshot) in
                    let value = snapshot.value as? NSDictionary
                    let uid = value!["id"]! as! String
                    let email = value!["email"]! as! String
                    var roomsArray = value!["rooms"]! as! Array<Dictionary<String, String>>
                    var playlistArray = value!["playlists"]! as! Array<Dictionary<String, String>>
                    
                    if let index = roomsArray.firstIndex(of: ["id": roomCode, "name": name]) {
                        roomsArray.remove(at: index)
                        if roomsArray.count == 0{
                            roomsArray.append(["id": "_", "name": "_"])
                        }
                    }
                    
                    playlistArray.append(["id": id, "name": name])
                    self.refUsers.child(uid).setValue(["id": uid, "email": email, "rooms": roomsArray, "playlists": playlistArray])
                    
                }) {(error) in
                    debugPrint(error.localizedDescription)
                    return
                }
            }
            
            // delete rooms
            let reference = self.refRooms.child(roomCode)
            reference.removeValue()
            
            completionHandler(true)
        }) {(error) in
            debugPrint(error.localizedDescription)
            return
        }
    }
    
}
