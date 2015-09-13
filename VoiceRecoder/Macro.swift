//
//  Macro.swift
//  VoiceRecoder
//
//  Created by LanTun on 15/9/5.
//  Copyright (c) 2015年 LanTun. All rights reserved.
//

import UIKit

struct Macro {
    static let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    static let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    static let second:Int = 60
    static let saveKey = "SaveRecoredAudioList"
    static func deleteAudioFile(audioFileName:String) {
        let fileManager = NSFileManager.defaultManager()
        var dirPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docsDir: AnyObject = dirPaths[0]
        let filePath = docsDir.stringByAppendingPathComponent("\(audioFileName).caf")
        if fileManager.fileExistsAtPath(filePath) {
            do {
                try fileManager.removeItemAtPath(filePath)
                UIAlertView(title: "Delete!", message: "Audio deleted successfully", delegate: nil, cancelButtonTitle: "OK").show()
            } catch _ {
            }
        }
        
    }
}
