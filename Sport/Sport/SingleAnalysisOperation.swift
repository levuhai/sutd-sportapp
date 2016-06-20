//
//  SingleAnalysisOperation.swift
//  Sport
//
//  Created by Tien on 6/21/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import MediaPlayer

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
            print("Song with id \(songPersistentId) is existing")
            completeOperation()
            return
        }
        
        // Detect appropriate output file type
        var outputFileType: String? = nil
        let dispatchGroupPrepare = dispatch_group_create()
        dispatch_group_enter(dispatchGroupPrepare)
        
        let avUrl = AVURLAsset(URL: song.assetURL!)
        let exporter = AVAssetExportSession(asset: avUrl, presetName: AVAssetExportPresetPassthrough)
        guard let realExporter = exporter else {
            completeOperation()
            return
        }
        
        exporter?.determineCompatibleFileTypesWithCompletionHandler({ (supportedFileTypes) in
            print("Supported \(supportedFileTypes)")
            if supportedFileTypes.contains(AVFileTypeAppleM4A) {
                outputFileType = AVFileTypeAppleM4A
            } else if supportedFileTypes.contains(AVFileTypeQuickTimeMovie) {
                outputFileType = AVFileTypeQuickTimeMovie
            }
            dispatch_group_leave(dispatchGroupPrepare)
        })
        dispatch_group_wait(dispatchGroupPrepare, DISPATCH_TIME_FOREVER)
        
        guard let actualOutputFileType = outputFileType else {
            completeOperation()
            return
        }
        
        configureExporter(realExporter, outputFileType: actualOutputFileType)
        
        // Export
        var exportPath: String? = nil
        let dispatchGroupExport = dispatch_group_create()
        dispatch_group_enter(dispatchGroupExport)
        realExporter.exportAsynchronouslyWithCompletionHandler {
            if (realExporter.status == .Completed) {
                let fileType = self.song.assetURL!.absoluteString.componentsSeparatedByString("?").first?.pathExtension
                print("File type: \(fileType)")
                let srcPath = exporter?.outputURL?.path
                let dstPath = srcPath?.stringByAppendingPathExtension(fileType!)
                FileManager.moveFileAtPath(srcPath!, toPath: dstPath!)
                
                exportPath = dstPath!
            }
            print(realExporter.error)
            dispatch_group_leave(dispatchGroupExport)
        }
        dispatch_group_wait(dispatchGroupExport, DISPATCH_TIME_FOREVER)
        
        guard let realExportPath = exportPath else {
            completeOperation()
            return
        }
        
        let analysisOutput = AubioWrapper.simpleAnalyzeAudioFile(realExportPath)
        let songData = SongData(persistentId: songPersistentId, energy: analysisOutput.energy, valence: analysisOutput.valence, tempo: analysisOutput.tempo)
        repository.addSong(songData)
        
        
        cleanup(realExportPath)
        completeOperation()
    }
    
    func completeOperation() {
        executing = false
        finished = true
    }
    
    func configureExporter(exporter: AVAssetExportSession, outputFileType: String) {
        exporter.outputFileType = outputFileType
        
        let exportPath = FileManager.songImportFolder().stringByAppendingPathComponent("\(song.persistentID)")
        if NSFileManager.defaultManager().fileExistsAtPath(exportPath) {
            FileManager.removeItemAtPath(exportPath)
        }
        exporter.outputURL = NSURL(fileURLWithPath: exportPath)
    }
    
    private func cleanup(fileUrl: String) {
        FileManager.removeItemAtPath(fileUrl)
    }
    
}
