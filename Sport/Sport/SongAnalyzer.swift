//
//  SongAnalyzer.swift
//  Sport
//
//  Created by Tien on 5/12/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class SongAnalyzer: NSObject {
    class func analyzeWithPath(path: String) {
        AubioWrapper.simpleAnalyzeAudioFile(path);
    }
}
