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
    
    
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var submitCode: UIButton!
    

    
    private let reuseIdentifier = "homePlaylistCell"
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setupToHideKeyboardOnTapOnView()
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkSpotifyAccess()
        super.viewWillAppear(animated)
        
        
        self.homeCollectionView!.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "homePlaylistCell")
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
            self.homeCollectionView.reloadData()
            
        }
        
        viewDidLoad()
        
        
    }
  
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        var max = 6
        
        if libraryViewModel.rooms.count < 6 {max = libraryViewModel.rooms.count + 1}
        debugPrint(max)
        
        return max
    }

    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homePlaylistCell", for: indexPath) as! HomeCollectionViewCell
        
        
        if indexPath.row == 5 || indexPath.row == (libraryViewModel.rooms.count) {
            
//            cell.configure(with: "View More")
            let title = UILabel(frame: CGRect(x: 0, y: 0, width: cell.bounds.size.width, height: cell.bounds.size.height))
            title.textColor = UIColor.white
            title.text = "View More"
            title.tag = 100
            title.font = UIFont.boldSystemFont(ofSize: 16)
            title.textAlignment = .center
            cell.contentView.viewWithTag(100)?.removeFromSuperview()
            cell.contentView.addSubview(title)
            
        } else{
  

//          cell.configure(with: libraryViewModel.rooms[indexPath.row].name)
            let title = UILabel(frame: CGRect(x: 0, y: 0, width: cell.bounds.size.width, height: cell.bounds.size.height))
            title.textColor = UIColor.white
            title.text = libraryViewModel.rooms[indexPath.row].name
            title.tag = 100
            title.font = UIFont.boldSystemFont(ofSize: 16)
            title.textAlignment = .center
            cell.contentView.viewWithTag(100)?.removeFromSuperview()
            cell.contentView.addSubview(title)
           
        
        }
        
        cell.configureCell()

        return cell
        
        
    }

    // MARK: UICollectionViewDelegate


    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.opacity = 0.8
        
        if indexPath.row == 5 || indexPath.row == libraryViewModel.rooms.count {
            
            self.tabBarController?.selectedIndex = 1
            
        } else{
        
        debugPrint(libraryViewModel.rooms[indexPath.row].id)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "PlaylistTableViewController") as! PlaylistTableViewController
        newViewController.id = libraryViewModel.rooms[indexPath.row].id
        newViewController.name = libraryViewModel.rooms[indexPath.row].name
        self.navigationController!.pushViewController(newViewController, animated: true)
        }
    }
    
     func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.opacity = 1.0
    }
    
    
    
    @IBAction func joinPressed(_ sender: Any) {
        let ref = Database.database().reference()
        var p:NSDictionary?
        if let c = codeTextField.text {
          if c.count != 4 {
            print("Error code too long")
          }
          else {
            ref.child("rooms/\(c)").observeSingleEvent(of: .value, with: { (DataSnapshot) in
              p = DataSnapshot.value as? NSDictionary
              if let a = p
              {

                //Check if there are already users
                if let usersArr = a["users"] as? NSArray{
                    var b:[String] = usersArr.compactMap({$0 as? String})
                    if let user  = Auth.auth().currentUser {
                    
                      let uid = user.uid
                        if !b.contains(uid) {
                            b.append(uid)
                            
                            ref.child("rooms/\(c)/users").setValue(b)
                            
                            let dbService = DatabaseServiceHelper()
                            dbService.getUserFromDB(uid: uid) { (u) in
                                var rooms: Array<Dictionary<String, String>> = []
                                for r in u.rooms {
                                    rooms.append(["id": r.id, "name": r.name])
                                }
                                rooms.append(["id": c, "name": a["name"] as! String])
                                // debugPrint(rooms)
                                ref.child("users/\(uid)/rooms").setValue(rooms)
                            }
                        }
                    }
                    
                }
                // add a users array
                else {
                    if let user  = Auth.auth().currentUser {
                        let uid = user.uid
                        ref.child("rooms/\(c)/users").setValue([uid])
                    }
                    
                }
                
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "MixRoomViewController") as! MixRoomViewController
                newViewController.roomCode = c
                self.navigationController!.pushViewController(newViewController, animated: true)
              }
              else {
                // from https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
                let alert = UIAlertController(title: "Invalid Code", message: "No rooms exist with that code", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                      switch action.style{
                      case .default:
                            print("default")
                      case .cancel:
                            print("cancel")
                      case .destructive:
                            print("destructive")
                      @unknown default:
                        fatalError()
                      }}))
                self.present(alert, animated: true, completion: nil)
              }
            })
          }
        }
    }
    

    

}

