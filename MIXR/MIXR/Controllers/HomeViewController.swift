//
//  ViewController.swift
//  MIXR
//
//  Created by Christopher Haas on 11/6/20.
//

import UIKit
import SwiftUI
import FirebaseAuth
import Firebase

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @ObservedObject var libraryViewModel = LibraryViewModel()

    @IBOutlet weak var homeCollectionView: UICollectionView!
    private let reuseIdentifier = "homePlaylistCell"
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
//        let dbService = DatabaseServiceHelper()
//        dbService.generateProcess(roomCode: "09JQ") { (flag) in
//            debugPrint(flag)
//
//        }
        // Do any additional setup after loading the view.
       
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkSpotifyAccess()
        super.viewWillAppear(animated)
        
        self.homeCollectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "homePlaylistCell")
        let width = (self.view.frame.size.width - 10 * 4) / 3
        let layout = homeCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
                layout.itemSize = CGSize(width: width, height: width)
       
        let userCurr = Auth.auth().currentUser
        let uid = userCurr!.uid
        
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        
        let dbService = DatabaseServiceHelper()
        dbService.getUserFromDB(uid: uid) { (u) in

            self.libraryViewModel.rooms = u.playlists
            debugPrint(self.libraryViewModel.rooms)
            self.homeCollectionView.reloadData()
        }
        
    }
  
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        var max = 6
        
        if libraryViewModel.rooms.count < 6 {max = libraryViewModel.rooms.count}
        
        return max
    }

    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homePlaylistCell", for: indexPath)

        if let roomCell = collectionView.dequeueReusableCell(withReuseIdentifier: "homePlaylistCell", for: indexPath) as? HomeCollectionViewCell {

            // roomCell.configure(with: displayRooms[indexPath.row].name)
            roomCell.configure(with: libraryViewModel.rooms[indexPath.row].name)
            cell = roomCell
        }
        
        cell.configureCell()
        
        return cell
        
    }

    // MARK: UICollectionViewDelegate


    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.opacity = 0.8
        
        debugPrint(libraryViewModel.rooms[indexPath.row].id)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "PlaylistTableViewController") as! PlaylistTableViewController
        newViewController.id = libraryViewModel.rooms[indexPath.row].id
        newViewController.name = libraryViewModel.rooms[indexPath.row].name
        self.navigationController!.pushViewController(newViewController, animated: true)
    }
    
     func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.opacity = 1.0
    }
    
    
    
    

    

}

