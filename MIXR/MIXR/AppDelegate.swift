//
//  AppDelegate.swift
//  MIXR
//
//  Created by Christopher Haas on 11/6/20.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate{
    var window: UIWindow?
    
    
    let SpotifyClientID = "d96b26513f034d05b1c3a365fdeb9f18"
    let SpotifyRedirectURL = URL(string: "MIXR://returnAfterLogin")!
    public var accessToken = ""
    
    let scopes : SPTScope = [.playlistModifyPrivate, .appRemoteControl, .playlistModifyPublic, .playlistReadPrivate, .streaming, .userLibraryModify, .userReadPlaybackState, .userReadCurrentlyPlaying,.userTopRead]
    
    lazy var configuration = SPTConfiguration(
      clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )
    

    lazy var appRemote: SPTAppRemote = {
      let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
      appRemote.connectionParameters.accessToken = self.accessToken
      appRemote.delegate = self
        
      return appRemote
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
           
        
        
        if Auth.auth().currentUser?.uid != nil {
            self.window?.rootViewController = storyboard.instantiateViewController(identifier: "MainTabBarController")
            
        } else {
            self.window?.rootViewController =  storyboard.instantiateViewController(identifier: "LoginViewController")
            debugPrint("Not Logged In")
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let parameters = appRemote.authorizationParameters(from: url);

          if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
              appRemote.connectionParameters.accessToken = access_token
              self.accessToken = access_token
          } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
              debugPrint(error_description)
          }
        return true
    }

    
        func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
          self.appRemote.playerAPI?.delegate = self
          print("connected")
          self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
              if let error = error {
                debugPrint(error.localizedDescription)
              }
            })
        // Added function to resubscribe to updates in music player controller
        playerViewController.resub()
    }
      // Allows calling of MusicPlayerVC function
      var playerViewController: MusicPlayerViewController {
          get {
              let navController = self.window?.rootViewController?.children[0] as! UINavigationController
              return navController.topViewController as! MusicPlayerViewController
          }
      }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("disconnected")
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("failed")
    }

  func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
    debugPrint("Track name: %@", playerState.track.name)
  }

    func applicationWillResignActive(_ application: UIApplication) {
      if self.appRemote.isConnected {
        self.appRemote.disconnect()
      }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
      if let _ = self.appRemote.connectionParameters.accessToken {
        self.appRemote.connect()
      }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MIXR")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

