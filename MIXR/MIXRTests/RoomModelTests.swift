//
//  RoomModelTests.swift
//  MIXRTests
//
//  Created by Yin junwei on 11/7/20.
//

import XCTest

class RoomModelTests: XCTestCase {
    
    var roomTest: RoomModel = RoomModel(idIn: "testid", nameIn: "justice League", isPrivateIn: true, usersIn: [])
    
    let ADD_USER_SUCCESS_MESSAGE: String = "Join success."
    let ROOM_ALREADY_FULL_MESSAGE: String = "Room already full."
    let USER_IN_ROOM_MESSAGE: String = "User already in room."
    
    let ADD_SONG_SUCCESS_MESSAGE: String = "Add success."
    let SONG_IN_PLAYLIST_MESSAGE: String = "This song is already in the playlist."
    let PLAYLIST_ALREADY_FULL_MESSAGE: String = "Already reach max songs limit."
    
    override func setUp() {
        super.setUp()
        roomTest = RoomModel(idIn: "testid", nameIn: "justice League", isPrivateIn: true, usersIn: [])
    }
    
    func testCanGetRoomId() {
        XCTAssertEqual(roomTest.id, "testid")
    }
    
    func testCanSetRoomId() {
        roomTest.id = "testid2"
        XCTAssertEqual(roomTest.id, "testid2")
        self.setUp()
    }

    func testCanGetName() {
        XCTAssertEqual(roomTest.name, "justice League")
    }
    
    func testCanSetName() {
        roomTest.name = "avengers"
        XCTAssertEqual(roomTest.name, "avengers")
        self.setUp()
    }
    
    func testCanGetPrivacy() {
        XCTAssertTrue(roomTest.isPrivate)
    }
    
    func testCanSetPrivacy() {
        roomTest.isPrivate = false
        XCTAssertFalse(roomTest.isPrivate)
        self.setUp()
    }
    
    func canGetPartySize() {
        XCTAssertEqual(roomTest.getPartySize(), 0)
    }
    
    func testSetValidPartySize() {
        XCTAssertTrue(roomTest.setPartySize(partySizeIn: 5))
        XCTAssertEqual(roomTest.getPartySize(), 5)
        
        XCTAssertTrue(roomTest.setPartySize(partySizeIn: 8))
        XCTAssertEqual(roomTest.getPartySize(), 8)
        
        XCTAssertTrue(roomTest.setPartySize(partySizeIn: 1))
        XCTAssertEqual(roomTest.getPartySize(), 1)
        self.setUp()
    }
    
    func testCannotSetPartySizeNegativeNumber() {
        XCTAssertFalse(roomTest.setPartySize(partySizeIn: -1))
        XCTAssertEqual(roomTest.getPartySize(), 0)
    }
    
    func testCannotSetPartySizeToZero() {
        XCTAssertTrue(roomTest.setPartySize(partySizeIn: 5))
        XCTAssertEqual(roomTest.getPartySize(), 5)
        
        XCTAssertFalse(roomTest.setPartySize(partySizeIn: 0))
        XCTAssertEqual(roomTest.getPartySize(), 5)
        self.setUp()
    }
    
    func testCannotSetPartySizeOverEight() {
        XCTAssertFalse(roomTest.setPartySize(partySizeIn: 10))
        XCTAssertEqual(roomTest.getPartySize(), 0)
    }
    
    func testCanGetTimeInterval() {
        XCTAssertEqual(roomTest.getTimeLength(), -1)
    }
    
    func testCanConvertStringToTimeInterval() {
        let timeIn1 = "05:00"
        let timeIn2 = "04:41"
        XCTAssertEqual(roomTest.convertStringToTimeInterval(time: timeIn1), 18000)
        XCTAssertEqual(roomTest.convertStringToTimeInterval(time: timeIn2), 16860)
    }
    
    func testCannotConvertUnformattedInputTimeInterval() {
        let timeIn1 = "05,00"
        let timeIn2 = "3.0"
        let timeIn3 = "05:01:04"
        
        XCTAssertEqual(roomTest.convertStringToTimeInterval(time: timeIn1), -1)
        XCTAssertEqual(roomTest.convertStringToTimeInterval(time: timeIn2), -1)
        XCTAssertEqual(roomTest.convertStringToTimeInterval(time: timeIn3), -1)
    }
    
    func testConnotConvertEmptyString() {
        let timeIn = ""
        XCTAssertEqual(roomTest.convertStringToTimeInterval(time: timeIn), -1)
    }
    
    func testConnotConvertInvalidInputTimeInterval() {
        let timeIn1 = "as:01"
        let timeIn2 = "04:asf"
        let timeIn3 = "af:er"
        
        XCTAssertEqual(roomTest.convertStringToTimeInterval(time: timeIn1), -1)
        XCTAssertEqual(roomTest.convertStringToTimeInterval(time: timeIn2), -1)
        XCTAssertEqual(roomTest.convertStringToTimeInterval(time: timeIn3), -1)
    }
    
    func testCanSetValidTimeLength() {
        let timeIn1 = "05:00"
        let timeIn2 = "04:41"
        
        XCTAssertTrue(roomTest.setTimeLength(time: timeIn1))
        XCTAssertEqual(roomTest.getTimeLength(), 18000)
        
        XCTAssertTrue(roomTest.setTimeLength(time: timeIn2))
        XCTAssertEqual(roomTest.getTimeLength(), 16860)
        self.setUp()
    }
    
    func testConnotSetEmptyTimeLength() {
        let timeIn = ""
        XCTAssertFalse(roomTest.setTimeLength(time: timeIn))
    }
    
    func testCannotSetUnformattedTimeLength() {
        let timeIn = "05:00"
        XCTAssertTrue(roomTest.setTimeLength(time: timeIn))
        XCTAssertEqual(roomTest.getTimeLength(), 18000)
        
        let timeIn1 = "05,00"
        let timeIn2 = "3.0"
        let timeIn3 = "05:01:04"
        
        
        XCTAssertFalse(roomTest.setTimeLength(time: timeIn1))
        XCTAssertEqual(roomTest.getTimeLength(), 18000)
        
        XCTAssertFalse(roomTest.setTimeLength(time: timeIn2))
        XCTAssertEqual(roomTest.getTimeLength(), 18000)
        
        XCTAssertFalse(roomTest.setTimeLength(time: timeIn3))
        XCTAssertEqual(roomTest.getTimeLength(), 18000)
        

        self.setUp()
    }
    
    func testCannotSetInvalidTimeLength() {
        let timeIn = "05:00"
        XCTAssertTrue(roomTest.setTimeLength(time: timeIn))
        XCTAssertEqual(roomTest.getTimeLength(), 18000)
        
        let timeIn1 = "as:01"
        let timeIn2 = "04:asf"
        let timeIn3 = "af:er"
        
        XCTAssertFalse(roomTest.setTimeLength(time: timeIn1))
        XCTAssertEqual(roomTest.getTimeLength(), 18000)
        
        XCTAssertFalse(roomTest.setTimeLength(time: timeIn2))
        XCTAssertEqual(roomTest.getTimeLength(), 18000)
        
        XCTAssertFalse(roomTest.setTimeLength(time: timeIn3))
        XCTAssertEqual(roomTest.getTimeLength(), 18000)
        self.setUp()
    }
    
    func testCanGetDefaultNumSongsLimit() {
        XCTAssertEqual(roomTest.getNumSongsLimit(), Int.max)
    }
    
    func testCanSetValidNumSongsLimit() {
        XCTAssertTrue(roomTest.setNumSongsLimit(num: 10))
        XCTAssertEqual(roomTest.getNumSongsLimit(), 10)
        self.setUp()
    }
    
    func testCannotSetNumSongsLimitedToNegative() {
        XCTAssertFalse(roomTest.setNumSongsLimit(num: -1))
        XCTAssertEqual(roomTest.getNumSongsLimit(), Int.max)
    }
    
    func testCannotSetNumSongsLimitedToZero() {
        XCTAssertFalse(roomTest.setNumSongsLimit(num: 0))
        XCTAssertEqual(roomTest.getNumSongsLimit(), Int.max)
    }
    
    func testUserNotInRoom() {
        let user = UserModel()
        user.uid = "uid1"
        
        XCTAssertFalse(roomTest.isUserInRoom(userId: "uid1"))
    }
    
    func testUserInRoom() {
        let user = UserModel()
        user.uid = "uid1"
        
        XCTAssertFalse(roomTest.isUserInRoom(userId: "uid1"))
        
        roomTest.users.append(user)
        XCTAssertTrue(roomTest.isUserInRoom(userId: "uid1"))
        self.setUp()
    }
    
    
    func testCanAddNewUser() {
        let user = UserModel()
        user.uid = "uid1"
        roomTest.setPartySize(partySizeIn: 5)
        
        XCTAssertFalse(roomTest.isUserInRoom(userId: "uid1"))
        XCTAssertEqual(roomTest.users.count, 0)
        
        let result = roomTest.addUser(user: user)
        XCTAssertTrue(result["success"] as! Bool)
        XCTAssertEqual(result["message"] as! String, ADD_USER_SUCCESS_MESSAGE)
        
        XCTAssertTrue(roomTest.isUserInRoom(userId: "uid1"))
        XCTAssertEqual(roomTest.users.count, 1)
        self.setUp()
    }
    
    func testConnotAddUserWhenRoomIsFull() {
        roomTest.setPartySize(partySizeIn: 3)
        let user1 = UserModel()
        user1.uid = "uid1"
        let user2 = UserModel()
        user2.uid = "uid2"
        let user3 = UserModel()
        user3.uid = "uid3"
        let user4 = UserModel()
        user4.uid = "uid4"
        
        var result = roomTest.addUser(user: user1)
        XCTAssertTrue(result["success"] as! Bool)
        XCTAssertEqual(result["message"] as! String, ADD_USER_SUCCESS_MESSAGE)
        
        result = roomTest.addUser(user: user2)
        XCTAssertTrue(result["success"] as! Bool)
        XCTAssertEqual(result["message"] as! String, ADD_USER_SUCCESS_MESSAGE)
        
        result = roomTest.addUser(user: user3)
        XCTAssertTrue(result["success"] as! Bool)
        XCTAssertEqual(result["message"] as! String, ADD_USER_SUCCESS_MESSAGE)
        
        result = roomTest.addUser(user: user4)
        XCTAssertFalse(result["success"] as! Bool)
        XCTAssertEqual(result["message"] as! String, ROOM_ALREADY_FULL_MESSAGE)
        XCTAssertEqual(roomTest.users.count, 3)
        XCTAssertFalse(roomTest.isUserInRoom(userId: user4.uid))
        self.setUp()
    }
    
    func testConnotAddExitingUser() {
        let user = UserModel()
        user.uid = "uid"
        roomTest.setPartySize(partySizeIn: 3)
        roomTest.addUser(user: user)
        XCTAssertEqual(roomTest.users.count, 1)
        
        let result = roomTest.addUser(user: user)
        XCTAssertFalse(result["success"] as! Bool)
        XCTAssertEqual(result["message"] as! String, USER_IN_ROOM_MESSAGE)
        XCTAssertEqual(roomTest.users.count, 1)
        self.setUp()
    }
    
    func testCannotRemoveUserNotInRoom() {
        let user = UserModel()
        user.uid = "uid"
        XCTAssertFalse(roomTest.removeUser(userID: user.uid))
        XCTAssertEqual(roomTest.users.count, 0)
    }
    
    func testCanRemoveUser() {
        let user = UserModel()
        user.uid = "uid"
        roomTest.setPartySize(partySizeIn: 3)
        roomTest.addUser(user: user)
        XCTAssertEqual(roomTest.users.count, 1)
        
        XCTAssertTrue(roomTest.removeUser(userID: user.uid))
        XCTAssertEqual(roomTest.users.count, 0)
        self.setUp()
    }
    
    func testSongNotInPlaylist() {
        let song = SongModel(nameIn: "Galway Girl", artistIn: "Ed Sheeran", spotifyIDIn: "spotifyid")
        XCTAssertFalse(roomTest.isInPlaylist(songId: song.spofityID))
    }
    
    func testSongInPlayList() {
        let song = SongModel(nameIn: "Galway Girl", artistIn: "Ed Sheeran", spotifyIDIn: "spotifyid")
        roomTest.songs.append(song)
        XCTAssertTrue(roomTest.isInPlaylist(songId: song.spofityID))
        self.setUp()
    }
    
    func testCanAddNewSong() {
        let song = SongModel(nameIn: "Galway Girl", artistIn: "Ed Sheeran", spotifyIDIn: "spotifyid")
        
        let result = roomTest.addSong(song: song)
        XCTAssertTrue(result["success"] as! Bool)
        XCTAssertEqual(result["message"] as! String, ADD_SONG_SUCCESS_MESSAGE)
        self.setUp()
    }
    
    func testCannotAddSongAlreadyInPlayList() {
        let song = SongModel(nameIn: "Galway Girl", artistIn: "Ed Sheeran", spotifyIDIn: "spotifyid")
        roomTest.addSong(song: song)
        
        XCTAssertEqual(roomTest.songs.count, 1)
        
        let result = roomTest.addSong(song: song)
        XCTAssertFalse(result["success"] as! Bool)
        XCTAssertEqual(result["message"] as! String, SONG_IN_PLAYLIST_MESSAGE)
        XCTAssertEqual(roomTest.songs.count, 1)
        self.setUp()
    }
    
    func testCannotAddSongToFullPlayList() {
        roomTest.setNumSongsLimit(num: 2)
        let song1 = SongModel(nameIn: "Galway Girl", artistIn: "Ed Sheeran", spotifyIDIn: "spotifyid1")
        let song2 = SongModel(nameIn: "Paradise", artistIn: "Coldplay", spotifyIDIn: "spotifyid2")
        let song3 = SongModel(nameIn: "Fix You", artistIn: "ColdPlay", spotifyIDIn: "spotifyid3")
        
        roomTest.addSong(song: song1)
        XCTAssertEqual(roomTest.songs.count, 1)
        
        roomTest.addSong(song: song2)
        XCTAssertEqual(roomTest.songs.count, 2)
        
        let result = roomTest.addSong(song: song3)
        XCTAssertFalse(result["success"] as! Bool)
        XCTAssertEqual(result["message"] as! String, PLAYLIST_ALREADY_FULL_MESSAGE)
        XCTAssertEqual(roomTest.songs.count, 2)
        self.setUp()
    }
    
    func testCanRemoveSong() {
        let song = SongModel(nameIn: "Galway Girl", artistIn: "Ed Sheeran", spotifyIDIn: "spotifyid")
        roomTest.addSong(song: song)
        XCTAssertEqual(roomTest.songs.count, 1)
        
        XCTAssertTrue(roomTest.removeSong(songID: song.spofityID))
        XCTAssertEqual(roomTest.songs.count, 0)
        self.setUp()
    }
    
    func testCannotRemoveSongNotInPlaylist() {
        let song1 = SongModel(nameIn: "Galway Girl", artistIn: "Ed Sheeran", spotifyIDIn: "spotifyid1")
        let song2 = SongModel(nameIn: "Paradise", artistIn: "Coldplay", spotifyIDIn: "spotifyid2")
        
        roomTest.addSong(song: song1)
        XCTAssertEqual(roomTest.songs.count, 1)
        
        XCTAssertFalse(roomTest.removeSong(songID: song2.spofityID))
        XCTAssertEqual(roomTest.songs.count, 1)
    }

}
