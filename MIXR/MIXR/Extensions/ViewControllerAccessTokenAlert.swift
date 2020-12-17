//
//  ViewControllerAccessTokenAlert.swift
//  MIXR
//
//  Created by Christopher Haas on 12/11/20.
//

import Foundation


extension UIViewController
{
    
    
    func presentAlert(title: String, message: String) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
    
    func displayError(_ error: NSError?) {
      if let error = error {
        print(error)
        presentAlert(title: "We are sorry", message: "We couldn't play that song.")
      }
    }
    
    var defaultCallback: SPTAppRemoteCallback {
      get {
        return {[weak self] _, error in
          if let error = error {
            self?.displayError(error as NSError)
          }
        }
      }
    }
    
    func checkSpotifyAccess(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var appRemote: SPTAppRemote? {
          get {
            return (UIApplication.shared.delegate as? AppDelegate)?.appRemote
          }
        }
        if appDelegate.accessToken == "" {
            let alert = UIAlertController(title: "Spotify is Not Linked" , message: "Please link to your spotify account.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Link", style: .default, handler: { action in
                                            appRemote?.authorizeAndPlayURI("", asRadio: false, additionalScopes: ["playlist-modify-public", "playlist-modify-private", "user-modify-playback-state", "user-library-modify"])
                                            appRemote?.playerAPI?.pause(self.defaultCallback)
                                            alert.dismiss(animated: true, completion: nil)}))
            self.present(alert, animated: true, completion: nil)
        }
    }

   
}
