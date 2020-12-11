//
//  AddSongTableViewController.swift
//  MIXR
//
//  Created by Christopher Haas on 11/12/20.
//

import UIKit
import Alamofire
import Firebase

class AddSongTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var songs = [Track](){
        didSet{
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var headers: HTTPHeaders = []
    
    var roomCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        self.headers = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer " + appDelegate.accessToken
        ]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        let artist =  songs[indexPath.row].artists.first?.name
        cell.textLabel?.text = songs[indexPath.row].name + " by " + (artist ?? "")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = songs[indexPath.row]
        let artist =  song.artists.first?.name
        let titleString = songs[indexPath.row].name + " by " + (artist ?? "")
        let alert = UIAlertController(title: titleString , message: "Do you want to add this song to the Mix?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {_ in alert.dismiss(animated: true) {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }}))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.addSongToRoom(song)
            self.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func addSongToRoom(_ song: Track){
        var ref = Database.database().reference()

        var p:NSDictionary?
        
      
           
          
        ref.child("rooms/\(self.roomCode)").observeSingleEvent(of: .value, with: { (DataSnapshot) in
        
            p = DataSnapshot.value as? NSDictionary ?? nil
             
            let user  = Auth.auth().currentUser
            var uid = ""
            if let user = user{
              uid = user.uid
            }
           
            if let room = p {
               
                // if let users = room["users"] as? [String]{
                    
                  // if users.contains(String(uid)) {
                        if let songs = room["addedSongs"] as? NSArray {
                            if !songs.contains(song.id){
                                let updatedSongs : NSArray = songs.adding(NSString(string: song.id)) as NSArray
                                ref.child("rooms/\(self.roomCode)/addedSongs").setValue(updatedSongs)
                            }
                        } else {
                            //Put first song in Room
                            ref.child("rooms/\(self.roomCode)/addedSongs").setValue(NSArray(object: NSString(string: song.id)))
                        }
                    // }
                // }
            }
            else{
                let alert = UIAlertController(title: "Unable to Connect to your room" , message: "Please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                                alert.dismiss(animated: true, completion: nil)}))
                self.present(alert, animated: true, completion: nil)
                
            
            }
            
        })
    }
    
    // MARK: Search Bar Config
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        if let searchText = searchBar.text{
//            getSongs(title: searchText)
//        }
//
//    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            getSongs(title: searchText)
        }
        
    }
    
    func getSongs(title: String) {
        let scrubbedTitle = title.replacingOccurrences(of: " ", with: "%20")
        AF.request("https://api.spotify.com/v1/search?q=\(scrubbedTitle)&type=track&offset=0&limit=10", headers: self.headers).responseData { response in
        
            guard let data = response.data else { return }

            guard var search = try? JSONDecoder().decode(Search.self, from: data) else {
              print("Error: Couldn't decode data into a result")
              return
            }

            self.songs = search.items.tracks
            self.tableView.reloadData()
        }
    }
}
