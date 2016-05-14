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
import MobileCoreServices

protocol ItunesDataImporterDelegate {
    
}

class ItunesDataImporter: NSObject {
    
    class func importItunesSongs() {
        let mediaQuery = MPMediaQuery.songsQuery()
        let mediaItems = mediaQuery.items;
        
        guard let songs  = mediaItems else {
            return
        }
        
        func createExporterWithMediaItem(song: MPMediaItem) -> AVAssetExportSession? {
            print("Song persistent id \(song.persistentID)")
            if song.assetURL == nil {
                return nil
            }
            
            let avUrl = AVURLAsset(URL: song.assetURL!)
            
            let exporter = AVAssetExportSession(asset: avUrl, presetName: AVAssetExportPresetPassthrough)
            exporter?.outputFileType = "com.apple.quicktime-movie"
            let exportPath = FileManager.songImportFolder().stringByAppendingPathComponent("\(song.persistentID)")
            if NSFileManager.defaultManager().fileExistsAtPath(exportPath) {
                FileManager.removeItemAtPath(exportPath)
            }
            exporter?.outputURL = NSURL(fileURLWithPath: exportPath)
            
            return exporter
        }
        
        for song in songs {
            
            let exporter = createExporterWithMediaItem(song)
            
            exporter?.exportAsynchronouslyWithCompletionHandler({ 
                if exporter!.status == .Completed {
                    
                    let fileType = song.assetURL?.absoluteString.componentsSeparatedByString("?").first?.pathExtension
                    print("File type: \(fileType)")
                    let srcPath = exporter?.outputURL?.path
                    let dstPath = srcPath?.stringByAppendingPathExtension(fileType!)
                    FileManager.moveFileAtPath(srcPath!, toPath: dstPath!)
                    AubioWrapper.simpleAnalyzeAudioFile(dstPath)
                } else {
                    print("Export has problems: \(exporter?.error)")
                }
            })
        }
    }
    
    
   
    
}
