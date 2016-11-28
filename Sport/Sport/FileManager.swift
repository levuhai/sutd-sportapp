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
    
    static var libraryFolder: String {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
    }
    
    /**
     Create folder if not existing
     
     - parameter path: folder path
     
     */
    fileprivate class func initializeFolder(_ path: String) {
        var isDirectory: ObjCBool = false
        var isExisting = false
        let fm = Foundation.FileManager.default
        if fm.fileExists(atPath: path, isDirectory: &isDirectory) {
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
        return libraryFolder.stringByAppendingPathComponent(IMPORT_FOLDER)
    }
    
    class func moveFileAtPath(_ srcPath: String, toPath dstPath: String) {
        do {
            if (Foundation.FileManager.default.fileExists(atPath: dstPath)) {
                try Foundation.FileManager.default.removeItem(atPath: dstPath)
            }
            try Foundation.FileManager.default.moveItem(atPath: srcPath, toPath: dstPath)
        } catch {
            print(error)
        }
    }
    
    class func removeItemAtPath(_ path: String) {
        do {
            try Foundation.FileManager.default.removeItem(atPath: path)
        } catch {
            
        }
    }
    
    class func createDirectoryAtPath(_ path: String) {
        do {
            try Foundation.FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            
        }
    }
}
