//
//  SpotifyCodables.swift
//  MIXR
//
//  Created by Christopher Haas on 11/12/20.
//

import Foundation


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
  
  enum CodingKeys : String, CodingKey {
    case album
    case artists
    case name
    case id
    
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


