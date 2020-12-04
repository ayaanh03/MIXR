//
//  LibraryCollectionViewCell.swift
//  MIXR
//
//  Created by Yin junwei on 12/4/20.
//

import UIKit

class LibraryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var roomNameLabel: UILabel!
    
    func configure (with roomName: String) {
        roomNameLabel.text = roomName
        roomNameLabel.textAlignment = .center
        roomNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        roomNameLabel.textColor = UIColor.white
    }
}
