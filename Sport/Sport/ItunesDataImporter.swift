//
//  ItunesDataImporter.swift
//  Sport
//
//  Created by Tien on 5/8/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

protocol ItunesDataImporterDelegate {
    
}

class ItunesDataImporter: NSObject {
    class func importItunesSongs() {
        let mediaQuery = MPMediaQuery.songsQuery()
        let songs = mediaQuery.items;
        
        guard let songArray  = songs else {
            return
        }
        
        for song in songArray {
            print("Song path: \(song.assetURL), persistent id \(song.persistentID)")
            if song.assetURL == nil {
                continue
            }
            
            let avUrl = AVURLAsset(URL: song.assetURL!)
            
            let exporter = AVAssetExportSession(asset: avUrl, presetName: AVAssetExportPresetPassthrough)
            
            let exportPath = basePathForExportFile().stringByAppendingPathComponent("\(song.persistentID)")
            exporter?.outputURL = NSURL(fileURLWithPath: exportPath)
            exporter?.outputFileType = "com.apple.quicktime-movie"
            exporter?.exportAsynchronouslyWithCompletionHandler({ 
                print("Export completed with url \(exporter!.outputURL)")
                let fileExist = NSFileManager.defaultManager().fileExistsAtPath((exporter!.outputURL?.path)!)
                if fileExist {
                    print("File exist")
                } else {
                    print("File not exist")
                }
                let srcPath = exporter?.outputURL?.path
                let dstPath = srcPath?.stringByAppendingString(".mp3")
                do {
                    try NSFileManager.defaultManager().moveItemAtPath(srcPath!, toPath: dstPath!)
                } catch {
                    print(error)
                }
                AubioWrapper.simpleAnalyzeAudioFile(dstPath)
                print("Export status \(exporter?.status == .Completed)")
                print("Export error \(exporter?.error)")
            })
        }
    }
    
    class func basePathForExportFile() -> NSString {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
    }
   
    
}
