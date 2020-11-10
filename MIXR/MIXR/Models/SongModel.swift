//
//  SongModel.swift
//  MIXR
//
//  Created by Yin junwei on 11/7/20.
//

import Foundation

class SongModel {
    var name: String
    var artist: String
    var spofityID: String
    
    init(nameIn: String, artistIn: String, spotifyIDIn: String) {
        name = nameIn
        artist = artistIn
        spofityID = spotifyIDIn
    }
}
