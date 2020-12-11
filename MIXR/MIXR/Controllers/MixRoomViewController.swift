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
    
    var tempTracks = [Track]()
    var sortedDict = [(Int, [String])]()
    var finalTracks = [Track]()
    
    var songIDList = [String]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var headers: HTTPHeaders = []
    
    var sets = [[Track]]()
    var timesRecd = [String:Int]()
    
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
        cell.textLabel?.text = addedSongs[indexPath.row].name + " by " + (addedSongs[indexPath.row].artists.first?.name ?? "Unknown")
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
                    if let name = room["name"] as? String {
                        self.title = name
                    }
                   
                }
            })
        }
        
        
    }
    
    func countMemebers() {
        
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
                print("songIDs is ", songIDs)
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
        tempTracks.removeAll()
        //self.addedSongs.removeAll()
        //self.songIDList.removeAll()
        pullSongs()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if (self.addedSongs.count >= 5) {
                self.getSetsOf5()
            } else {
                self.sets = [self.addedSongs]
            }
            self.createDict()
        }
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.createDict()
        }
         */
        
    }
    
    
    
    
    @IBAction func generatePlaylist(_ sender: Any) {
        print("sortedList is ", self.sortedDict)
        var count = 0
        var recSongs = [String]()
        var p:NSDictionary?
        ref.child("rooms/\(self.roomCode)").observeSingleEvent(of: .value, with: { (DataSnapshot) in
        p = DataSnapshot.value as? NSDictionary
        if let a = p {
            if var songs = a["addedSongs"] as? [String] {
                self.sortedDict.forEach { dict in
                    for v in dict.1 {
                        if (count <= 14) {
                    
                            recSongs.append(v)
                            count += 1
                        } else {
                            break
                        }
                    }
                }
                
                songs += recSongs

                self.ref.child("rooms/\(self.roomCode)/addedSongs").setValue(NSArray(object: songs))
                
                let dbService = DatabaseServiceHelper()
                dbService.generateProcess(roomCode: self.roomCode, songs: songs) { (flag) in
                    debugPrint("generate success: ", flag)
                }
             
            }
        }})
        
        
            
        
        let alert = UIAlertController(title: "Playlist Has Been Created", message: "You can view the new playlist in your Library.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
      
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
    
    func getSetsOf5() {
        
        let loops = self.addedSongs.count-4
        let numSongs = self.addedSongs.count
        
        for i1 in 0...loops {
            for i2 in i1+1..<min(i1+1+loops, numSongs) {
                for i3 in i2+1..<min(i2+1+loops, numSongs) {
                    for i4 in i3+1..<min(i3+1+loops, numSongs) {
                        for i5 in i4+1..<min(i4+1+loops, numSongs) {
                            
                            print("i1, i2, i3, i4, i5 are ", i1, i2, i3, i4, i5)
                            
                            let group = [self.addedSongs[i1], self.addedSongs[i2], self.addedSongs[i3], self.addedSongs[i4], self.addedSongs[i5]]
                            self.sets.append(group)
                        }
                    }
                }
            }
        }
    }

    func createDict() {

        self.sets.forEach{ set1 in
            getRecs1(songs: set1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                print("length is ", self.tempTracks.count)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            self.tempTracks.forEach{ track in
                
                if let x = self.timesRecd[track.id] {
                    self.timesRecd[track.id]! += 1
                } else {
                    self.timesRecd[track.id] = 1
                }
                
            }
            let flipped = Dictionary(grouping: self.timesRecd.keys.sorted(), by: { self.timesRecd[$0]! })
            self.sortedDict = flipped.sorted(by: { $0.0 > $1.0 })
        }
    }
    
    func getTrack(tr: String, completion: @escaping (Track) -> Void) {
        var url = "https://api.spotify.com/v1/tracks/"
        url += tr
        AF.request(url, headers: self.headers).responseJSON { response in
            
            guard let data = response.data else { return }
            guard let track  = try? JSONDecoder().decode(Track.self, from: data) else {
                print("Error: Couldn't decode data into a result")
                return
            }
            completion(track)
        }
    }
    
    func getRecs1(songs: Array<Track>) {
        //self.tempTracks.removeAll()
        print("tempTracks is ", self.tempTracks)
        var url = "https://api.spotify.com/v1/recommendations?limit=15&seed_tracks="
        //if songs.count == 0 { return songs }
        songs.forEach{ song in
            url += song.id + "%2C"
        }
        url = String(url.dropLast(3))
        AF.request(url, headers: self.headers).responseJSON { response in
            guard let data = response.data  else { return }
            guard let tracks = try? JSONDecoder().decode(Tracks.self, from: data) else {
              print("Error: Couldn't decode data into a result")
              return
            }
            
            var c = 0
            tracks.tracks.forEach{ track in
                self.tempTracks.append(track)
                c += 1
            }
            c = 0
            print("function length", self.tempTracks.count)
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
    

    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AddSongTableViewController {
            destinationVC.roomCode = roomCode
           }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        checkSpotifyAccess()
        pullSongs()
        addedSongsTableView.reloadData()
        
    }
    
}
