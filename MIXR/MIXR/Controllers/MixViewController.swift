//
//  MixViewController.swift
//  MIXR
//
//  Created by Christopher Haas on 11/6/20.
//


import UIKit
import Alamofire

class MixViewController: UIViewController {
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func apiTapped(_ sender: Any) {
        print("here")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.accessToken
        ]

        AF.request("https://api.spotify.com/v1/playlists/5tgEw5cJutXuUc0vcEJntw", headers: headers).responseJSON { response in
            debugPrint(response)
        }
          
//            guard let result = try? JSONDecoder().decode(Result.self, from: data) else {
//              print("Error: Couldn't decode data into a result")
//              return
          
    }
    
}
