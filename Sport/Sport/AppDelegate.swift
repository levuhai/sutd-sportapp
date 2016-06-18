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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        FileManager.prepare()
        decorate()
        
        // Enable playing music while app is in the background
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        EssentiaWrapper.foo()
        
        Fabric.with([Crashlytics.self])
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        let type = event?.subtype
        if type == UIEventSubtype.RemoteControlPlay {
            SPAudioPlayer.sharedInstance.play()
        } else if type == UIEventSubtype.RemoteControlPause {
            print("UIEventSubtype.RemoteControlPause")
            SPAudioPlayer.sharedInstance.pause()
        } else if type == UIEventSubtype.RemoteControlNextTrack {
            print("UIEventSubtype.RemoteControlNextTrack")
            SPAudioPlayer.sharedInstance.moveToNext()
        } else if type == UIEventSubtype.RemoteControlPreviousTrack {
            print("UIEventSubtype.RemoteControlPreviousTrack")
            SPAudioPlayer.sharedInstance.moveToPrevious()
        } else if type == UIEventSubtype.RemoteControlBeginSeekingForward {
            print("UIEventSubtype.RemoteControlBeginSeekingForward")
        } else if type == UIEventSubtype.RemoteControlEndSeekingForward {
            print("UIEventSubtype.RemoteControlEndSeekingForward")
        } else if type == UIEventSubtype.RemoteControlBeginSeekingBackward {
            print("UIEventSubtype.RemoteControlBeginSeekingBackward")
        } else if type == UIEventSubtype.RemoteControlEndSeekingBackward {
            print("UIEventSubtype.RemoteControlEndSeekingBackward")
        }
        
    }
    
    func decorate() {
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = UIColor.sportPink()
        
        let barAttributes :Dictionary = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18),
                                         NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().titleTextAttributes = barAttributes
    }
}

