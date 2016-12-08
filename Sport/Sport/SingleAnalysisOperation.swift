//
//  SingleAnalysisOperation.swift
//  Sport
//
//  Created by Tien on 6/21/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import MediaPlayer
import AudioKit

class SingleAnalysisOperation: ConcurrentOperation {
    
    let song: MPMediaItem
    let repository: SongRepository
    
    init(song: MPMediaItem, repository: SongRepository) {
        self.song = song
        self.repository = repository
        
        super.init()
    }
    
    override func start() {
        super.start()
        
        beginProcessing()
    }
    
    func beginProcessing() {
        let songPersistentId = "\(song.persistentID)"
        // Check and skip existing songs.
        if song.assetURL == nil || repository.isSongExisting(songPersistentId) {
            completeOperation()
            return
        }
        
        // Detect appropriate output file type
        var outputFileType: String? = nil
        let dispatchGroupPrepare = DispatchGroup()
        dispatchGroupPrepare.enter()
        
        let avUrl = AVURLAsset(url: song.assetURL!)
        let exporter = AVAssetExportSession(asset: avUrl, presetName: AVAssetExportPresetPassthrough)
        guard let realExporter = exporter else {
            completeOperation()
            return
        }
        
        exporter?.determineCompatibleFileTypes(completionHandler: { (supportedFileTypes) in
            if supportedFileTypes.contains(AVFileTypeAppleM4A) {
                outputFileType = AVFileTypeAppleM4A
            } else if supportedFileTypes.contains(AVFileTypeQuickTimeMovie) {
                outputFileType = AVFileTypeQuickTimeMovie
            }
            dispatchGroupPrepare.leave()
        })
        dispatchGroupPrepare.wait(timeout: DispatchTime.distantFuture)
        
        guard let actualOutputFileType = outputFileType else {
            completeOperation()
            return
        }
        
        configureExporter(realExporter, outputFileType: actualOutputFileType)
        
        // Export
        var exportPath: String? = nil
        let dispatchGroupExport = DispatchGroup()
        dispatchGroupExport.enter()
        realExporter.exportAsynchronously {
            if (realExporter.status == .completed) {
                let fileType = self.song.assetURL!.absoluteString.components(separatedBy: "?").first?.pathExtension
                let srcPath = exporter?.outputURL?.path
                let dstPath = srcPath?.stringByAppendingPathExtension(fileType!)
                FileManager.moveFileAtPath(srcPath!, toPath: dstPath!)
                
                exportPath = dstPath!
            }
            dispatchGroupExport.leave()
        }
        dispatchGroupExport.wait(timeout: DispatchTime.distantFuture)
        
        guard let realExportPath = exportPath else {
            completeOperation()
            return
        }
        
        let file = try! AKAudioFile(forReading: URL(fileURLWithPath: realExportPath))
        
        let analysisOutput = AubioWrapper.analyzeAudioFile(realExportPath, dataArray: file.arraysOfFloats[0])
        let songData = SongData(persistentId: songPersistentId, energy: (analysisOutput?.energy)!, valence: (analysisOutput?.valence)!, tempo: (analysisOutput?.tempo)!)
        repository.addSong(songData)
        
        
        cleanup(realExportPath)
        completeOperation()
    }
    
    func completeOperation() {
        isExecuting = false
        isFinished = true
    }
    
    func configureExporter(_ exporter: AVAssetExportSession, outputFileType: String) {
        exporter.outputFileType = outputFileType
        
        let exportPath = FileManager.songImportFolder().stringByAppendingPathComponent("\(song.persistentID)")
        if Foundation.FileManager.default.fileExists(atPath: exportPath) {
            FileManager.removeItemAtPath(exportPath)
        }
        exporter.outputURL = URL(fileURLWithPath: exportPath)
    }
    
    fileprivate func cleanup(_ fileUrl: String) {
        FileManager.removeItemAtPath(fileUrl)
    }
    
}
