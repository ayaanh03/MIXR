//
//  HomeCollectionViewCell.swift
//  MIXR
//
//  Created by Christopher Haas on 12/2/20.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var roomNameLabel: UILabel!
    
    
    func configure (with roomName: String) {
        roomNameLabel.text = roomName
        roomNameLabel.textAlignment = .center
        roomNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        roomNameLabel.textColor = UIColor.white
    }
}
