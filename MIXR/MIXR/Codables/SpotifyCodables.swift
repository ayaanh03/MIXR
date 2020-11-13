//
//  SpotifyCodables.swift
//  MIXR
//
//  Created by Christopher Haas on 11/12/20.
//

import Foundation

struct Search: Decodable {
  var items: Items
  
  enum CodingKeys : String, CodingKey {
    case items = "tracks"
  }
}

struct Items: Decodable {
  var tracks: [Track]
  
  enum CodingKeys : String, CodingKey {
    case tracks = "items"
  }
}



struct Tracks: Decodable {
  var tracks: [Track]
  
  enum CodingKeys : String, CodingKey {
    case tracks
  }
}

struct Track: Decodable {
    let album: Album
    let artists: [Artist]
    let name: String
    let id: String
    let uri: String
  
  enum CodingKeys : String, CodingKey {
    case album
    case artists
    case name
    case id
    case uri
    
  }
}

struct Album: Decodable {
    let name: String
    let id: String
  
  enum CodingKeys : String, CodingKey {
    case name
    case id
    
  }
}



struct Artist: Decodable {
    let name: String
    let id: String
  
  enum CodingKeys : String, CodingKey {
    case name
    case id
    
  }
}

struct User: Decodable {
  var id: String
  
  enum CodingKeys : String, CodingKey {
    case id
  }
}

struct Playlist: Decodable {
  var id: String
  
  enum CodingKeys : String, CodingKey {
    case id
  }
}


struct playlistParams: Codable {
    var name: String
    var pub: Bool
    
    enum CodingKeys : String, CodingKey {
        case name
        case pub = "public"
    }
}
