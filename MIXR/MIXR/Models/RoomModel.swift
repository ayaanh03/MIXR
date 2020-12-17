//
//  RoomModel.swift
//  MIXR
//
//  Created by Yin junwei on 11/6/20.
//

import Foundation

class RoomModel {
    var id: String
    var name: String
    private var partySize: Int = 0
    var isPrivate: Bool
    private var numSongsLimit: Int = Int.max
    private var timeLength: TimeInterval = -1
    var users: [UserModel] = []
    var songs: [SongModel] = []
    var limit: Int
    
    private let HOUR_TO_SECONDS: Double = 3600
    private let MINUTE_TO_SECONDS: Double = 60
    
    init(idIn: String, nameIn: String, isPrivateIn: Bool, usersIn: [UserModel], limit: Int = 4) {
        id = idIn
        name = nameIn
        isPrivate = isPrivateIn
        users = usersIn
        self.limit = limit
        
    }
    
    func getPartySize() -> Int {
        return partySize
    }
    
    func setPartySize(partySizeIn: Int) -> Bool {
        if (partySizeIn > 8 || partySizeIn <= 0) {
            return false
        }
        partySize = partySizeIn
        return true
    }
    
    func getTimeLength() -> TimeInterval {
        return timeLength
    }
    
    func setTimeLength(time: String) -> Bool {
        let tempLength = convertStringToTimeInterval(time: time)
        if (tempLength == -1) {
            return false
        }
        timeLength = tempLength
        return true
    }
    
    // input format: 09:41: 9 h and 41 min
    // Should be a private method, not to be called by controller
    func convertStringToTimeInterval(time: String) -> TimeInterval {
        if (time == "") {
            return -1
        }
        
        let components = time.components(separatedBy: ":")
        if (components.count != 2) {
            return -1
        }
        
        let interval: Double = (Double(components[0]) ?? -1) * HOUR_TO_SECONDS + (Double(components[1]) ?? -9999) * MINUTE_TO_SECONDS
        if (interval < 0) {
            return -1
        }
        return interval
    }
    
    func setNumSongsLimit(num: Int) -> Bool {
        if (num <= 0) {
            return false
        }
        numSongsLimit = num
        return true
    }
    
    func getNumSongsLimit() -> Int {
        return numSongsLimit
    }
    
    // Should be a private method, not to be called by controller
    func isUserInRoom(userId: String) -> Bool {
        for user in users {
            if (user.uid == userId) {
                return true
            }
        }
        return false
    }
    
    func addUser(user: UserModel) -> Dictionary<String, Any> {
        if (users.count == partySize) {
            return ["success": false, "message": "Room already full."]
        }
        
        if (isUserInRoom(userId: user.uid)) {
            return ["success": false, "message": "User already in room."]
        }
        
        users.append(user)
        return ["success": true, "message": "Join success."]
    }
    
    func removeUser(userID: String) -> Bool {
        if (!isUserInRoom(userId: userID)) {
            return false
        }
        users = users.filter( {$0.uid != userID} )
        return true
    }
    
    // Should be a private method, not to be called by controller
    func isInPlaylist(songId: String) -> Bool {
        for s in songs {
            if (s.spofityID == songId) {
                return true
            }
        }
        return false
    }
    
    func addSong(song: SongModel) -> Dictionary<String, Any> {
        if (songs.count == numSongsLimit) {
            return ["success": false, "message": "Already reach max songs limit."]
        }
        if (isInPlaylist(songId: song.spofityID)) {
            return ["success": false, "message": "This song is already in the playlist."]
        }
        
        songs.append(song)
        return ["success": true, "message": "Add success."]
    }
    
    func removeSong(songID: String) -> Bool {
        if (!isInPlaylist(songId: songID)) {
            return false
        }
        songs = songs.filter({$0.spofityID != songID} )
        return true
    }
    
}
