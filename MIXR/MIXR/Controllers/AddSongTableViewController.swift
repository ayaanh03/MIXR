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
    
    // MARK: Search Bar Config
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text{
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

            search.items.tracks.forEach{ track in
                self.songs.append(track)
                if self.songs.count != 0 {
                    let indexPath = IndexPath(row: self.songs.count-1, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}
