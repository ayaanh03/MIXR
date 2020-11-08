//
//  SongModelTests.swift
//  MIXRTests
//
//  Created by Yin junwei on 11/7/20.
//

import XCTest

class SongModelTests: XCTestCase {
    
    var songTest: SongModel = SongModel(nameIn: "Galway Girl", artistIn: "Ed Sheeran", spotifyIDIn: "spotifyid")
    
    override func setUp() {
        super.setUp()
        songTest = SongModel(nameIn: "Galway Girl", artistIn: "Ed Sheeran", spotifyIDIn: "spotifyid")
    }
    
    func testCanGetSongName() {
        XCTAssertEqual(songTest.name, "Galway Girl")
    }
    
    func testCanSetSongName() {
        songTest.name = "Perfect"
        XCTAssertEqual(songTest.name, "Perfect")
        self.setUp()
    }
    
    func testCanGetArtist() {
        XCTAssertEqual(songTest.artist, "Ed Sheeran")
    }
    
    func testCanSetArtist() {
        songTest.artist = "Coldplay"
        XCTAssertEqual(songTest.artist, "Coldplay")
        self.setUp()
    }

    func testCanGetSpotifyId() {
        XCTAssertEqual(songTest.spofityID, "spotifyid")
    }
    
    func testCanSetSpofityId() {
        songTest.spofityID = "newid"
        XCTAssertEqual(songTest.spofityID, "newid")
    }
}
