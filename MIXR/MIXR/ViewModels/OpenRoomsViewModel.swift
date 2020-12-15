//
//  OpenRoomsViewModel.swift
//  MIXR
//
//  Created by Christopher Haas on 12/11/20.
//

import Foundation

class OpenRoomsViewModel: ObservableObject {
    @Published var rooms = [RoomModel]()
}

