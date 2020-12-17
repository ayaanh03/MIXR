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
 
    override func viewDidLoad() {
        super.viewDidLoad()

      
        // Register cell classes
       
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryCell", for: indexPath)

        if let roomCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryCell", for: indexPath) as? LibraryCollectionViewCell {

            roomCell.configure(with: libraryViewModel.rooms[indexPath.row].name)
            cell = roomCell
        }
        cell.configureCell()
        
        return cell
        
    }

    // MARK: UICollectionViewDelegate

    


    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.opacity = 0.8
        
        debugPrint(libraryViewModel.rooms[indexPath.row].id)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "PlaylistTableViewController") as! PlaylistTableViewController
        newViewController.id = libraryViewModel.rooms[indexPath.row].id
        newViewController.name = libraryViewModel.rooms[indexPath.row].name
        self.navigationController!.pushViewController(newViewController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.opacity = 1.0
    }
    

}


