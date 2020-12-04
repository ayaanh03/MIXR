//
//  LibraryViewModel.swift
//  MIXR
//
//  Created by Yin junwei on 12/4/20.
//

import Foundation

class LibraryViewModel: ObservableObject {
    @Published var rooms = [RoomModel]()
}
