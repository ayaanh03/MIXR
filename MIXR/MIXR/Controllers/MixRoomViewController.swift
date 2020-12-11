//
//  MixHostViewController.swift
//  MIXR
//
//  Created by Christopher Haas on 11/6/20.
//


import UIKit
import Alamofire
import Firebase

class MixRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var codeLabel: UILabel!
    
    @IBOutlet weak var generateButton: UIButton!
    
    @IBOutlet weak var addedSongsTableView: UITableView! {
        didSet{
            addedSongsTableView.delegate = self
            addedSongsTableView.dataSource = self
        }
    }
    
    let ref = Database.database().reference()
    var roomCode : String = ""
    var addedSongs = [Track]()
    
    var songIDList = [String]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var headers: HTTPHeaders = []
    
    override func viewDidLoad() {
        self.setupToHideKeyboardOnTapOnView()
        self.headers = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer " + appDelegate.accessToken
        ]
        generateButton.layer.cornerRadius = 5
        generateButton.isHidden = true;
        checkHost()
        pullSongs()
        self.addedSongsTableView.reloadData()
        super.viewDidLoad()
        codeLabel.text = "ROOM CODE: " + roomCode

        // Do any additional setup after loading the view.
    }
    
    
    
    // MARK: ADDED SONGS TABLE VIEW
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
        cell.textLabel?.text = addedSongs[indexPath.row].name
        return cell
    }
    
    func checkHost() {
        var p : NSDictionary?
        if let user = Auth.auth().currentUser  {
            ref.child("rooms/\(self.roomCode)").observeSingleEvent(of: .value, with: { (DataSnapshot) in
                p = DataSnapshot.value as? NSDictionary
                if let room = p {
                    if let host = room["host"] as? String {
                        

                        if user.uid == host{
                            self.generateButton.isHidden = false;
                        }
                    }
                }
            })
        }
        
        
    }
    
    
    
    func pullSongs() {
        var p:NSDictionary?
        ref.child("rooms/\(self.roomCode)").observeSingleEvent(of: .value, with: { (DataSnapshot) in
        p = DataSnapshot.value as? NSDictionary
        if let a = p {
            if let songs = a["addedSongs"] as? [String] {
                //Get new Song ID's
                let newSongs = songs.difference(from: self.songIDList)
                var songIDs = ""
                newSongs.forEach{ songID in
                    songIDs += songID + "%2C"
                    self.songIDList.append(songID)
                }
                songIDs = String(songIDs.dropLast(3))
                if songIDs != "" {

                    AF.request("https://api.spotify.com/v1/tracks?ids=\(songIDs)", headers: self.headers).responseData { response in
                        
                        guard let data = response.data  else { return }
                        guard let tracks = try? JSONDecoder().decode(Tracks.self, from: data) else {
                          print("Error: Couldn't decode data into a result")
                          return
                        }
                        
                        tracks.tracks.forEach{ track in
                            self.addedSongs.append(track)
                            if self.addedSongs.count != 0 {
                                let indexPath = IndexPath(row: self.addedSongs.count-1, section: 0)
                                self.addedSongsTableView.insertRows(at: [indexPath], with: .automatic)
                            }
                            
                            
                        }
                        
                    }
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
    
    @IBAction func refreshSongs(_ sender: Any) {
        pullSongs()
    }
    
    
    
    
    @IBAction func generatePlaylist(_ sender: Any) {
        pullSongs()
      var addedSongs = ""
        var p:NSDictionary?
        ref.child("rooms/\(self.roomCode)").observeSingleEvent(of: .value, with: { (DataSnapshot) in
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
              
        getRecommendations { (recs) in
            var recURIString = ""
            recs.tracks.forEach { (track) in
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
                    "name" : "MIXR ROOM \(self.roomCode)",
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
        let dbService = DatabaseServiceHelper()
        dbService.generateProcess(roomCode: roomCode) { (flag) in
            debugPrint("generate success: ", flag)
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
    
    func getRecommendations(completion: @escaping (Tracks) -> Void) {
        var url = "https://api.spotify.com/v1/recommendations?limit=15&seed_tracks="
        if self.addedSongs.count == 0 { return }
        self.addedSongs.forEach{ song in
            url += song.id + "%2C"
        }
        url = String(url.dropLast(3))
        AF.request(url, headers: self.headers).responseJSON { response in
            guard let data = response.data  else { return }
            guard let tracks = try? JSONDecoder().decode(Tracks.self, from: data) else {
              print("Error: Couldn't decode data into a result")
              return
            }
            completion(tracks)
        }
    }
    
    func addToPlaylist(uris: String, playlistID: String) {
      
      
        AF.request("https://api.spotify.com/v1/playlists/\(playlistID)/tracks?uris=\(uris)", method: .post, headers: self.headers).validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    let alert = UIAlertController(title: "Playlist Has been Created", message: "View Spotify Playlist titled MIXR ROOM: \(self.roomCode)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)

            
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AddSongTableViewController {
            destinationVC.roomCode = roomCode
           }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        pullSongs()
        addedSongsTableView.reloadData()
        
    }
    
}
