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
    
    @IBOutlet weak var roomSize: UILabel!
    
    @IBOutlet weak var addSongButton: UIButton!
    
    @IBOutlet weak var addedSongsTableView: UITableView! {
        didSet{
            addedSongsTableView.delegate = self
            addedSongsTableView.dataSource = self
        }
    }
    
    let queue = DispatchQueue(label: "com.company.app.queue", attributes: .concurrent)
    let group = DispatchGroup()
    
    let q1 = DispatchQueue(label: "com.company.app.queue", attributes: .concurrent)
    let g1 = DispatchGroup()
    
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
    
    var isgenerated = false
    
    override func viewDidLoad() {
        self.setupToHideKeyboardOnTapOnView()
        self.headers = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer " + appDelegate.accessToken
        ]
        
        addSongButton.layer.borderWidth = 1
        addSongButton.layer.cornerRadius = 5
        addSongButton.layer.borderColor = UIColor.systemGreen.cgColor
       
        generateButton.layer.cornerRadius = 5
        generateButton.isHidden = true;
        checkHost()
        pullSongs()
        self.addedSongsTableView.reloadData()
        super.viewDidLoad()
        self.addedSongsTableView.separatorInset = UIEdgeInsets.zero
        codeLabel.text = roomCode

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
        cell.textLabel?.textColor = UIColor.white
        cell.separatorInset = UIEdgeInsets.zero
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
                        self.adjustLargeTitleSize()

                    }
                    
                    if let size = room["size"] as? String {
                        if let users = room["users"] as? NSArray {
                            self.roomSize.text = "\(users.count + 1) / \(size)"
                            
                        }
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

         let alert = UIAlertController(title: "Room closed", message: "The playlist is generated and the room is closed.", preferredStyle: .alert)
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
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
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
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    
    
    
    @IBAction func generatePlaylist(_ sender: Any) {

        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        if (isgenerated) {
            self.dismiss(animated: false, completion: nil)
            let alert2 = UIAlertController(title: "Generate failed", message: "The playlist is already generated.", preferredStyle: .alert)

            alert2.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert2, animated: true)
            return
        }

        isgenerated = true

        
        print("sortedList is ", self.sortedDict)
        var count = 0
        var toGenerate = 0
        var recURIString = ""
        var addedSongs = ""
        var nme = ""
        var recSongs = [String]()

        var p:NSDictionary?
        ref.child("rooms/\(self.roomCode)").observeSingleEvent(of: .value, with: { (DataSnapshot) in
        p = DataSnapshot.value as? NSDictionary
        if let a = p {
            if var songs = a["addedSongs"] as? [String] {
                
                if let l = a["length"] as? String {
                    print("l is ", l)
                    toGenerate = Int(l)! - songs.count
                }

                addedSongs = ""
                if (toGenerate >= 0) {
                    songs.forEach{ songID in
                        addedSongs += "spotify:track:"+songID + ","
                    }
                } else {
                    var c = 0
                    for songID in songs {
                        if (c < toGenerate) {
                            addedSongs += "spotify:track:"+songID + ","
                            c += 1
                        } else {
                            break
                        }

                    }
                }
                
                if let n = a["name"] as? String {
                    nme = n
                }
                
                if (toGenerate > 0) {
                    self.sortedDict.forEach{ dict in
                        for v in dict.1 {
                            if (count < toGenerate) {
                                recSongs.append(v)
                                count += 1
                            } else {
                                break
                            }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dismiss(animated: false, completion: nil)
            let alert1 = UIAlertController(title: "Playlist Has Been Created", message: "You can view the new playlist in your Library.", preferredStyle: .alert)
            alert1.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert1, animated: true, completion: nil)
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
        }}}}}}

    func createDict() {
        
        
        self.group.enter()
        
        self.queue.async(group: group) {
            self.sets.forEach{ set1 in
                self.getRecs1(songs: set1)
            }
            self.group.leave()
        }
        
        self.group.notify(queue: self.queue) {
            print("length", self.tempTracks.count)
            self.tempTracks.forEach{ track in
                if let x = self.timesRecd[track.id] {
                    self.timesRecd[track.id]! += 1
                } else {
                    self.timesRecd[track.id] = 1
                }
                
            }
            let flipped = Dictionary(grouping: self.timesRecd.keys.sorted(), by: { self.timesRecd[$0]! })
            self.sortedDict = flipped.sorted(by: { $0.0 > $1.0 })
            self.tempTracks.removeAll()
            self.sets.removeAll()
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
        print("tempTracks is ", self.tempTracks)
        var url = "https://api.spotify.com/v1/recommendations?limit=15&seed_tracks="
        //if songs.count == 0 { return songs }
        songs.forEach{ song in
            url += song.id + "%2C"
        }
        url = String(url.dropLast(3))
        
        self.group.enter()
        AF.request(url, headers: self.headers).responseJSON { response in
            guard let data = response.data  else { return }
            guard let tracks = try? JSONDecoder().decode(Tracks.self, from: data) else {
              print("Error: Couldn't decode data into a result")
              return
            }
            
            for track in tracks.tracks {
                if (self.tempTracks.count < self.sets.count*15) {
                    self.tempTracks.append(track)
                } else {
                    break
                }
            }
            self.group.leave()
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




extension UIViewController {
  func adjustLargeTitleSize() {
    guard let title = title, #available(iOS 11.0, *) else { return }

    let maxWidth = UIScreen.main.bounds.size.width - 60
    var fontSize = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
    var width = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]).width

    while width > maxWidth {
      fontSize -= 1
        width = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]).width
    }

    navigationController?.navigationBar.largeTitleTextAttributes =
        [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontSize)
    ]
  }
}
