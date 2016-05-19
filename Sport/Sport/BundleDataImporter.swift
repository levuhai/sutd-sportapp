//
//  BundleDataImporter.swift
//  Sport
//
//  Created by Tien on 5/18/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class BundleDataImporter: SongImporter {
    
    static let sharedInstance = BundleDataImporter()
    
    func importToRepository(repository: SongRepository, completion: (() -> ())?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            let songPaths = NSBundle.mainBundle().pathsForResourcesOfType(nil, inDirectory: "songs")
            print("Count: \(songPaths.count)")
            for path in songPaths {
                
                let analysisOutput = AubioWrapper.simpleAnalyzeAudioFile(path)
                let persistentId = "persistent_id"
                let songTitle = path.stringByDeletingPathExtension.lastPathComponent
                let songData = SongData(persistentId: persistentId, title: songTitle, energy: analysisOutput.energy, valence: analysisOutput.valence, tempo: analysisOutput.tempo)
                
                repository.addSong(songData)
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                completion?()
            })
        }
    }
}
