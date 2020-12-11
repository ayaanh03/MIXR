//
//  MusicPlayerViewController.swift
//  MIXR
//
//  Created by Christopher Haas on 12/3/20.
//

import UIKit


var appRemote: SPTAppRemote? {
  get {
    return (UIApplication.shared.delegate as? AppDelegate)?.appRemote
  }
}



class MusicPlayerViewController: UIViewController {
 
  private var playerState: SPTAppRemotePlayerState?
  private var playing: Bool?
  
  //MARK: From Spotify SDK Example Project (https://github.com/spotify/ios-sdk/tree/master/DemoProjects/NowPlayingView)
  

  
  private func getPlayerState() {
      appRemote?.playerAPI?.getPlayerState { (result, error) -> Void in
          guard error == nil else { return }

          let playerState = result as! SPTAppRemotePlayerState
          self.updateViewWithPlayerState(playerState)
      }
  }
  

  
  //Resub function to subscribe to changes
  func resub(){
    
    appRemote?.playerAPI?.delegate = self
    appRemote?.playerAPI?.subscribe(toPlayerState: { (result, error) in
        if let error = error {
          debugPrint(error.localizedDescription)
        }
      })
    getPlayerState()
  }
  
  
  //MARK: Code for music player
  @IBOutlet weak var songImage: UIImageView!
  @IBOutlet var songLabel: UILabel!
  @IBOutlet weak var artistLabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var prevButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
    
    override func viewWillAppear(_ animated: Bool) {
        checkSpotifyAccess()
    }
  
 
  
  // MARK: Album Art
  private func updateAlbumArtWithImage(_ image: UIImage) {
      self.songImage.image = image
      let transition = CATransition()
      transition.duration = 0.3
      transition.type = CATransitionType.fade
      self.songImage.layer.add(transition, forKey: "transition")
  }
  
  private func fetchAlbumArtForTrack(_ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void ) {
      appRemote?.imageAPI?.fetchImage(forItem: track, with:CGSize(width: 1000, height: 1000), callback: { (image, error) -> Void in
          guard error == nil else { return }

          let image = image as! UIImage
          callback(image)
      })
  }
  
  //MARK: Update functions
  private func updateViewWithPlayerState(_ playerState:SPTAppRemotePlayerState) {
      
      fetchAlbumArtForTrack(playerState.track) { (image) -> Void in
          self.updateAlbumArtWithImage(image)
      }
      updateViewWithRestrictions(playerState.playbackRestrictions)
      self.songLabel.text = playerState.track.name + " - " + playerState.track.artist.name
  }
  
  
  private func updateViewWithRestrictions(_ restrictions: SPTAppRemotePlaybackRestrictions) {
      nextButton.isEnabled = restrictions.canSkipNext
      prevButton.isEnabled = restrictions.canSkipPrevious
  }
  
  //MARK: Music Player buttons
  @IBAction func nextSong(_ sender: Any){
    appRemote?.playerAPI?.skip(toNext: self.defaultCallback)
  }
  
  @IBAction func prevSong(_ sender: Any){
    appRemote?.playerAPI?.skip(toPrevious: self.defaultCallback)
  }
  
  private func startPlayback() {
    appRemote?.playerAPI?.resume(self.defaultCallback)
  }
  
  private func pausePlayback() {
    appRemote?.playerAPI?.pause(self.defaultCallback)
  }
  
  func checkconnect() -> Bool{
    if appRemote?.isConnected == false {
      if appRemote?.authorizeAndPlayURI("") == false {
          // The Spotify app is not installed, present the user with an App Store page
          print("Spotify not found")
      }
      resub()
  }
    else{return true}
    return false
  }
  
  //MARK: Works (Test for stability) -Ay
  @IBAction func didPressPlayPauseButton(_ sender: Any) {
   
    if  checkconnect() {
      
    if playerState == nil || playerState!.isPaused {
        startPlayback()
    } else {
        pausePlayback()
    }
}
}
}

// MARK: - SPTAppRemotePlayerStateDelegate
// Need this for album art and play pause to work without crashing.
extension MusicPlayerViewController: SPTAppRemotePlayerStateDelegate {
       func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
           self.playerState = playerState
           updateViewWithPlayerState(playerState)
//        print("BIG STATE CHANGE")
       }
}
