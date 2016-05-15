//
//  FileManager.swift
//  Sport
//
//  Created by Tien on 5/13/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class FileManager: NSObject {
    static let IMPORT_FOLDER = "Import"
    
    class func prepare() {
        initializeFolder(songImportFolder())
    }
    
    /**
     Create folder if not existing
     
     - parameter path: folder path
     
     */
    private class func initializeFolder(path: String) {
        var isDirectory: ObjCBool = false
        var isExisting = false
        let fm = NSFileManager.defaultManager()
        if fm.fileExistsAtPath(path, isDirectory: &isDirectory) {
            // If this is existing and is a directory -> no need to do anything more.
            isExisting = isDirectory.boolValue
            // If this exist but it's a file, remove it.
            if (!isDirectory.boolValue) {
                removeItemAtPath(path)
            }
        } else {
            isExisting = false
        }
        // If folder is not existing, create it
        if !isExisting {
            createDirectoryAtPath(path)
        }
    }
    
    class func songImportFolder() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        return documentDirectory.stringByAppendingPathComponent(IMPORT_FOLDER)
    }
    
    class func moveFileAtPath(srcPath: String, toPath dstPath: String) {
        do {
            try NSFileManager.defaultManager().moveItemAtPath(srcPath, toPath: dstPath)
        } catch {
            print(error)
        }
    }
    
    class func removeItemAtPath(path: String) {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
        } catch {
            
        }
    }
    
    class func createDirectoryAtPath(path: String) {
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            
        }
    }
}
