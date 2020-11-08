//
//  UserModelTests.swift
//  MIXRTests
//
//  Created by Yin junwei on 11/7/20.
//

import XCTest

class UserModelTests: XCTestCase {

    var userTest: UserModel = UserModel()
    
    override func setUp() {
        super.setUp()
        userTest.uid = "testuid"
        userTest.email = "test@gmail.com"
        userTest.password = "password"
    }
    
    func testCanGetUserId() {
        XCTAssertEqual(userTest.uid, "testuid")
    }
    
    func testCanSetUserId() {
        userTest.uid = "testuid2"
        XCTAssertEqual(userTest.uid, "testuid2")
        self.setUp()
    }
    
    func testCanGetUserEmail() {
        XCTAssertEqual(userTest.email, "test@gmail.com")
    }
    
    func testCanSetUserEmail() {
        userTest.email = "test2@gmail.com"
        XCTAssertEqual(userTest.email, "test2@gmail.com")
        self.setUp()
    }
    
    func testCanGetUserPassword() {
        XCTAssertEqual(userTest.password, "password")
    }
    
    func testCanSetUserPassword() {
        userTest.password = "password2"
        XCTAssertEqual(userTest.password, "password2")
        self.setUp()
    }
    
    func testIsNotInRoom() {
        let anotherUser = UserModel()
        let room = RoomModel(idIn: "roomid", nameIn: "test room", isPrivateIn: false, usersIn: [anotherUser])
        
        XCTAssertFalse(userTest.isInRoom(roomID: room.id))
        self.setUp()
    }
    
    func testIsInRoom() {
        let anotherUser = UserModel()
        let room = RoomModel(idIn: "roomid", nameIn: "test room", isPrivateIn: false, usersIn: [anotherUser])
        
        userTest.rooms.append(room)
        
        XCTAssertTrue(userTest.isInRoom(roomID: room.id))
        self.setUp()
    }
    
    func testCanJoinNewRoom() {
        let anotherUser = UserModel()
        let room = RoomModel(idIn: "roomid", nameIn: "test room", isPrivateIn: false, usersIn: [anotherUser])
        
        XCTAssertTrue(userTest.joinNewRoom(newRoom: room))
        XCTAssertEqual(userTest.rooms.count, 1)
        XCTAssertTrue(userTest.isInRoom(roomID: room.id))
        
        let room2 = RoomModel(idIn: "roomid1", nameIn: "test room", isPrivateIn: false, usersIn: [anotherUser])
        XCTAssertTrue(userTest.joinNewRoom(newRoom: room2))
        XCTAssertEqual(userTest.rooms.count, 2)
        XCTAssertTrue(userTest.isInRoom(roomID: room2.id))
        self.setUp()
        
    }
    
    func testCanNotJoinAlreadyInRoom() {
        let anotherUser = UserModel()
        let room = RoomModel(idIn: "roomid", nameIn: "test room", isPrivateIn: false, usersIn: [anotherUser])
        
        XCTAssertTrue(userTest.joinNewRoom(newRoom: room))
        XCTAssertEqual(userTest.rooms.count, 1)
        XCTAssertTrue(userTest.isInRoom(roomID: room.id))
        
        XCTAssertFalse(userTest.joinNewRoom(newRoom: room))
        XCTAssertEqual(userTest.rooms.count, 1)
        XCTAssertTrue(userTest.isInRoom(roomID: room.id))
        self.setUp()
    }

    func testCannotQuitRoomNotIn() {
        XCTAssertFalse(userTest.quitRoom(roomId: "aaaa"))
        XCTAssertEqual(userTest.rooms.count, 0)
        
        let anotherUser = UserModel()
        let room = RoomModel(idIn: "roomid", nameIn: "test room", isPrivateIn: false, usersIn: [anotherUser])
        XCTAssertTrue(userTest.joinNewRoom(newRoom: room))
        XCTAssertEqual(userTest.rooms.count, 1)
        XCTAssertTrue(userTest.isInRoom(roomID: room.id))
        
        XCTAssertFalse(userTest.quitRoom(roomId: "aaaa"))
        XCTAssertEqual(userTest.rooms.count, 1)
        self.setUp()
    }
    
    func testCanQuitRoom() {
        let anotherUser = UserModel()
        let room = RoomModel(idIn: "roomid", nameIn: "test room", isPrivateIn: false, usersIn: [anotherUser])
        XCTAssertTrue(userTest.joinNewRoom(newRoom: room))
        XCTAssertEqual(userTest.rooms.count, 1)
        XCTAssertTrue(userTest.isInRoom(roomID: room.id))
        
        XCTAssertTrue(userTest.quitRoom(roomId: room.id))
        XCTAssertEqual(userTest.rooms.count, 0)
        XCTAssertFalse(userTest.isInRoom(roomID: room.id))
    }

}
