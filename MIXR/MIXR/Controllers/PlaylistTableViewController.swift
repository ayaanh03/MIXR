//
//  PlaylistTableViewController.swift
//  MIXR
//
//  Created by Christopher Haas on 12/2/20.
//

import UIKit
import Alamofire
import Firebase

class PlaylistTableViewController: UITableViewController {
    
    var name = ""
    var id = ""
    
    var songs = [Track]() {
        didSet{
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var headers: HTTPHeaders = []
    
    let refPlaylists: DatabaseReference! = Database.database().reference().child("playlists")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = name.capitalized

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        self.headers = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer " + appDelegate.accessToken
        ]
        refPlaylists.child(id).observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            let songIdList = value!["addedSongs"]! as! Array<String>
            
            for songId in songIdList {
                AF.request("https://api.spotify.com/v1/tracks?ids=\(songId)", headers: self.headers).responseData { response in
                 
                    guard let data = response.data  else { return }
                    guard let tracks = try? JSONDecoder().decode(Tracks.self, from: data) else {
                      print("Error: Couldn't decode data into a result")
                      return
                    }
                    
                    tracks.tracks.forEach{ track in
                        self.songs.append(track)
                        if self.songs.count != 0 {
                            let indexPath = IndexPath(row: self.songs.count-1, section: 0)
                            self.tableView.insertRows(at: [indexPath], with: .automatic)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkSpotifyAccess()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        
        var cell = UITableViewCell()
        
        cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
        cell.textLabel?.text = songs[indexPath.row].name + " by " + (songs[indexPath.row].artists.first?.name ?? "Unknown")
        return cell
    }
    
    
    @IBAction func postToSpotifyTapped(_ sender: Any) {
        var addedSongs = ""
          var p:NSDictionary?
          refPlaylists.observeSingleEvent(of: .value, with: { (DataSnapshot) in
          p = DataSnapshot.value as? NSDictionary
          if let a = p {
              if let songs = a["addedSongs"] as? [String] {
                  //Get new Song ID's
                  addedSongs = ""
                  songs.forEach{ songID in
                      addedSongs += "spotify:track:"+songID + ","
  //                    self.songIDList.append(songID)
                  }
              }
          }})
                
         
              var recURIString = ""
              songs.forEach { (track) in
                  recURIString += track.uri + ","
              }
            print("rec")
              print(recURIString)
            print("added")
            print(addedSongs)
              recURIString = recURIString + addedSongs
              recURIString = String(recURIString.dropLast()).replacingOccurrences(of: ",", with: "%2C").replacingOccurrences(of: ":", with: "%3A")
              self.getUser { (user) in
                 
                  let parameters : [String : Any] = [
                    "name" : self.name,
                      "public" : false
                  ]
              
                  
                  AF.request("https://api.spotify.com/v1/users/\(user.id)/playlists", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: self.headers).responseJSON { response in
                      
                      guard let data = response.data  else { return }
                      guard let playlist = try? JSONDecoder().decode(Playlist.self, from: data) else {
                        print("Error: Couldn't decode data into a result")
                        return
                      }

                      self.addToPlaylist(uris: recURIString, playlistID: playlist.id)

                     
                  }
              }
        
          
          
      }
      
      func getUser(completion: @escaping (User) -> Void) {
          
          AF.request("https://api.spotify.com/v1/me", headers: self.headers).responseData { response in
              
              guard let data = response.data  else { return }
              guard let user = try? JSONDecoder().decode(User.self, from: data) else {
                print("Error: Couldn't decode data into a result")
                return
              }
              completion(user)
          }
          
              
          
      }
      
      
      func addToPlaylist(uris: String, playlistID: String) {
          AF.request("https://api.spotify.com/v1/playlists/\(playlistID)/tracks?uris=\(uris)", method: .post, headers: self.headers).validate()
              .responseJSON { response in
                  switch response.result {
                  case .success:
                      let alert = UIAlertController(title: "Playlist Has been Created", message: "View Spotify Playlist titled \(self.name)", preferredStyle: .alert)
                      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                          self.dismiss(animated: true, completion: nil)
                      }))
                      self.present(alert, animated: true, completion: nil)

              
                  case .failure(let error):
                      print(error)
                  }
              }
      }
      
      
}
