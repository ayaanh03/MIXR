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


extension UICollectionViewCell {
    

    func configureCell(color: UIColor) {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.backgroundColor = color
        self.layer.masksToBounds = true

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.8
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
}
