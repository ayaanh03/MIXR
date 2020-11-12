//
//  MixJoinViewController.swift
//  MIXR
//
//  Created by Christopher Haas on 11/12/20.
//

//


import UIKit
import Alamofire
import Firebase

class MixJoinViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var addedSongsTableView: UITableView!
    
    var roomCode : String = ""
    var addedSongs : Tracks = Tracks(tracks: [])
    
    var songIDList = [String]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var headers: HTTPHeaders = []
        
        
    
    var ref = Database.database().reference()
    
    
    override func viewDidLoad() {
        self.setupToHideKeyboardOnTapOnView()
        super.viewDidLoad()
        self.headers = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer " + appDelegate.accessToken
        ]
        
        addedSongsTableView.delegate = self
        addedSongsTableView.dataSource = self
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    // MARK: ADDED SONGS TABLE VIEW
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedSongs.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell = UITableViewCell()
        
        cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
        cell.textLabel?.text = addedSongs.tracks[indexPath.row].name
        return cell
    }
    
    
    
    func pullSongs() {
        var p:NSDictionary?

              
              
        ref.child("rooms/\(self.roomCode)").observeSingleEvent(of: .value, with: { (DataSnapshot) in

        p = DataSnapshot.value as? NSDictionary
        if let a = p {
            
            if let songs = a["songsAdded"] as? [String] {
                //Get new Song ID's
                let newSongs = songs.difference(from: self.songIDList)
                var songIDs = ""
                newSongs.forEach{ songID in
                    songIDs += songID + "%2C"
                    self.songIDList.append(songID)
                }
                songIDs = String(songIDs.dropLast(3))
                AF.request("https://api.spotify.com/v1/tracks?ids=\(songIDs)", headers: self.headers).responseData { response in
                    guard let data = response.data  else { return }
                    guard let tracks = try? JSONDecoder().decode(Tracks.self, from: data) else {
                      print("Error: Couldn't decode data into a result")
                      return
                  }
                    self.addedSongs.tracks += tracks.tracks
                }
            }
        } else {
            
         // from https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
         let alert = UIAlertController(title: "Error Retrieving Songs", message: "We were unable to retrieve the information for this room.", preferredStyle: .alert)
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
