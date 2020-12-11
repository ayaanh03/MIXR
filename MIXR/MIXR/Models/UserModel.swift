//
//  UserModel.swift
//  MIXR
//
//  Created by Yin junwei on 11/6/20.
//

import Foundation

class UserModel {
    var email: String
    var uid: String
    var password: String
    var rooms: [RoomModel]
    var playlists: [RoomModel]
    
    
    init() {
        uid = ""
        email = ""
        password = ""
        rooms = []
        playlists = []
    }
    
    // Should be a private method, not to be called by controller
    func isInRoom(roomID: String) -> Bool {
        for r in rooms {
            if (r.id == roomID) {
                return true
            }
        }
        return false
    }
    
    func joinNewRoom(newRoom: RoomModel) -> Bool {
        if (isInRoom(roomID: newRoom.id)) {
            return false
        }
        rooms.append(newRoom)
        return true
    }
    
    func quitRoom(roomId: String) -> Bool {
        if (!isInRoom(roomID: roomId)) {
            return false
        }
        rooms = rooms.filter( {$0.id != roomId} )
        return true
    }
}
