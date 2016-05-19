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

class ItunesDataImporter: SongImporter {
    
    static let sharedInstance = ItunesDataImporter()
    
    func importToRepository(repository: SongRepository, completion: (()->())?) {
        let mediaQuery = MPMediaQuery.songsQuery()
        let mediaItems = mediaQuery.items;
        
        guard let songs  = mediaItems else {
            completion?()
            return
        }
        
        // Copy song to app folder and start extracting.
        let importWorker = ImportWorker()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            
            for song in songs {
                // Import to app folder.
                let resultPath = importWorker.synchronousExportWithMediaItem(song)
                if (resultPath != nil) {
                    // Extract informations.
                    let analysisOutput = AubioWrapper.simpleAnalyzeAudioFile(resultPath!)
                    let persistentId = song.valueForProperty(MPMediaItemPropertyPersistentID) as! String
                    let songTitle = song.valueForProperty(MPMediaItemPropertyTitle) as! String
                    let songData = SongData(persistentId: persistentId, title: songTitle, energy: analysisOutput.energy, valence: analysisOutput.valence, tempo: analysisOutput.tempo)
                    
                    repository.addSong(songData)
                } else {
                    
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                completion?()
            })
        }
        
    }
    
    
}

// -----------------------------------------------------------------
// Import means import from other app to this app. Here is import from Ipod library.
private class ImportWorker: NSObject {
    
    // -------------------------------------------------------------
    // Synchronous export a song from ipod library. 
    // Return path to exported file if success, otherwise nil
    func synchronousExportWithMediaItem(song: MPMediaItem) -> String? {
        let exporter = createExporterWithMediaItem(song)
        
        guard let realExporter = exporter else {
            return nil
        }
        
        let semaphore = dispatch_semaphore_create(0)
        var resultPath: String? = nil
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        realExporter.exportAsynchronouslyWithCompletionHandler { 
            if (realExporter.status == .Completed) {
                let fileType = song.assetURL?.absoluteString.componentsSeparatedByString("?").first?.pathExtension
                print("File type: \(fileType)")
                let srcPath = exporter?.outputURL?.path
                let dstPath = srcPath?.stringByAppendingPathExtension(fileType!)
                FileManager.moveFileAtPath(srcPath!, toPath: dstPath!)
                
                resultPath = dstPath!
            }
            dispatch_semaphore_signal(semaphore)
        }
        
        return resultPath
    }
    
    // --------------------------------------------------------------
    // Return a exporter to export song from ipod library
    private func createExporterWithMediaItem(song: MPMediaItem) -> AVAssetExportSession? {
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
        print("Output \(exportPath)")
        return exporter
    }
}
