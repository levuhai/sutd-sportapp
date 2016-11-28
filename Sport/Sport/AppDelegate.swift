//
//  AppDelegate.swift
//  Sport
//
//  Created by Tien on 5/7/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit
import AVFoundation
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController(rootViewController: firstViewController())
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        FileManager.prepare()
        decorate()
        
        // Enable playing music while app is in the background
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        Fabric.with([Crashlytics.self])
        return true
    }

    func firstViewController() -> UIViewController {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        if (!AppUserDefaults.isTutorialFinished()) {
            return sb.instantiateViewController(withIdentifier: "TourGuideController")
        } else if (!AppUserDefaults.isFirstInitialSuccessfully()) {
            return sb.instantiateViewController(withIdentifier: "InitialViewController")
        }
        return sb.instantiateViewController(withIdentifier: "MusicPlayerController")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        let type = event?.subtype
        if type == UIEventSubtype.remoteControlPlay {
            SPAudioPlayer.sharedInstance.play()
        } else if type == UIEventSubtype.remoteControlPause {
            print("UIEventSubtype.RemoteControlPause")
            SPAudioPlayer.sharedInstance.pause()
        } else if type == UIEventSubtype.remoteControlNextTrack {
            print("UIEventSubtype.RemoteControlNextTrack")
            SPAudioPlayer.sharedInstance.moveToNext()
        } else if type == UIEventSubtype.remoteControlPreviousTrack {
            print("UIEventSubtype.RemoteControlPreviousTrack")
            SPAudioPlayer.sharedInstance.moveToPrevious()
        } else if type == UIEventSubtype.remoteControlBeginSeekingForward {
            print("UIEventSubtype.RemoteControlBeginSeekingForward")
        } else if type == UIEventSubtype.remoteControlEndSeekingForward {
            print("UIEventSubtype.RemoteControlEndSeekingForward")
        } else if type == UIEventSubtype.remoteControlBeginSeekingBackward {
            print("UIEventSubtype.RemoteControlBeginSeekingBackward")
        } else if type == UIEventSubtype.remoteControlEndSeekingBackward {
            print("UIEventSubtype.RemoteControlEndSeekingBackward")
        }
        
    }
    
    func decorate() {
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor.sportPink()
        
        let barAttributes :Dictionary = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18),
                                         NSForegroundColorAttributeName: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = barAttributes
    }
}

