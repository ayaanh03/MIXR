//
//  LibraryCollectionViewController.swift
//  MIXR
//
//  Created by Christopher Haas on 12/2/20.
//

import UIKit
import SwiftUI
import FirebaseAuth

private let reuseIdentifier = "Cell"

class LibraryCollectionViewController: UICollectionViewController {
    
    @ObservedObject var libraryViewModel = LibraryViewModel()
    // @State var displayRooms = [RoomModel(idIn: "1111", nameIn: "test", isPrivateIn: true, usersIn: [])]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let width = (self.view.frame.size.width - 10 * 4) / 3
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
                layout.itemSize = CGSize(width: width, height: width)
       
        let userCurr = Auth.auth().currentUser
        let uid = userCurr!.uid
        
        let dbService = DatabaseServiceHelper()
        dbService.getUserFromDB(uid: uid) { (u) in

            self.libraryViewModel.rooms = u.playlists
            // self.displayRooms = u.rooms
            debugPrint(self.libraryViewModel.rooms)
            self.collectionView.reloadData()
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLoad()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource




    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        // displayRooms = libraryViewModel.rooms
        
        //return displayRooms.count
        return libraryViewModel.rooms.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
//
//        // Configure the cell
//        cell.configureCell()
//        let y = (cell.bounds.size.width/2) - 20
//        let title = UILabel(frame: CGRect(x: 0, y: y, width: cell.bounds.size.width, height: 40))
//        title.text = "Text"
//        title.textAlignment = .center
//        title.font = UIFont.boldSystemFont(ofSize: 16)
//        title.textColor = UIColor.white
//
//        cell.contentView.addSubview(title)

        // displayRooms = libraryViewModel.rooms
        var cell = UICollectionViewCell()
        if let roomCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryCell", for: indexPath) as? LibraryCollectionViewCell {

            // roomCell.configure(with: displayRooms[indexPath.row].name)
            roomCell.configure(with: libraryViewModel.rooms[indexPath.row].name)
            cell = roomCell
        }
        
        return cell
        
    }

    // MARK: UICollectionViewDelegate

    


    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.opacity = 0.8
        
        debugPrint(libraryViewModel.rooms[indexPath.row].id)
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let newViewController = storyBoard.instantiateViewController(withIdentifier: "MixRoomViewController") as! MixRoomViewController
//        newViewController.roomCode = libraryViewModel.rooms[indexPath.row].id
//        self.navigationController!.pushViewController(newViewController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.opacity = 1.0
    }
    
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}



extension UICollectionViewCell {
    func configureCell() {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.backgroundColor = UIColor.systemGreen
        self.layer.masksToBounds = true

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
}
