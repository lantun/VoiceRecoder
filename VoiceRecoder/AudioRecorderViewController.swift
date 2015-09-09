//
//  AudioRecorderViewController.swift
//  VoiceRecoder
//
//  Created by LanTun on 15/9/5.
//  Copyright (c) 2015年 LanTun. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorderViewController: UIViewController,AVAudioRecorderDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var audioProgressBar: UIProgressView!

    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    var currentAudionName:String!
    var progressTimer:NSTimer!
    var timeTimer:NSTimer!
    var totalSecond:Int!
    
    var secondCount:Int!
    var isRecordingSave:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        secondCount = 0
        totalSecond = 0
        recordTimeLabel.text = "00:00:00"
        isRecordingSave = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recordAction(sender: AnyObject) {
        if count(nameTextField.text) > 0{
            nameTextField.resignFirstResponder()
            if setupRecord() {
                if !audioRecorder!.recording {
                    println("start recording...")
                    AVAudioSession.sharedInstance().setActive(true, error: nil)
                    totalSecond = 0
                    audioRecorder!.record()
                    recordTimeLabel.text = "00:00:00"
                    progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.01,
                        target: self,
                        selector: "progressBarAction",
                        userInfo: nil,
                        repeats: true)
                    timeTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timeTimerAction", userInfo: nil, repeats: true)
                }
            }
        }else{
            showAlert()
        }
    }
    @IBAction func stopAction(sender: AnyObject) {
        nameTextField.resignFirstResponder()
        if audioRecorder!.recording {
            if progressTimer != nil {
                progressTimer.invalidate()
            }
            if timeTimer != nil {
                timeTimer.invalidate()
            }
            audioRecorder!.stop()
            audioRecorder!.meteringEnabled = false
            var error:NSError = NSError()
            var audioSession:AVAudioSession = AVAudioSession.sharedInstance()
            audioSession.setActive(false, error: NSErrorPointer(&error))
            totalSecond = secondCount
            secondCount = 0
            println("stop recording...")
        }
    }

    @IBAction func saveAction(sender: AnyObject) {
        if count(nameTextField.text) > 0 {
            stopAction(saveButton)
            if totalSecond > 0 {
                isRecordingSave = true
                
                var tmpAudioList:[AnyObject]? = Macro.prefs.objectForKey(Macro.saveKey) as? [AnyObject]
                
                var tmpDict:[String: String!]! = [
                    "audioName":nameTextField.text.capitalizedString,
                    "audioTotalSecond":"\(totalSecond)",
                    "audioLength":recordTimeLabel.text?.capitalizedString,
                    "audioSaveTime":"\(NSDate(timeIntervalSince1970: 0.0))",
                ]
                tmpAudioList?.insert(tmpDict, atIndex: 0)
                Macro.prefs.setValue(tmpAudioList, forKey: Macro.saveKey)
                Macro.prefs.synchronize()
                self.navigationController?.popViewControllerAnimated(true)
            
            }else{
                UIAlertView(title: "Alert!", message: "Please record something.", delegate: nil, cancelButtonTitle: "Ok").show()
            }
        }else{
            showAlert()
        }
    }
    
    func showAlert() {
        UIAlertView(title: "Alert!", message: "Please set recording audio name first.", delegate: nil, cancelButtonTitle: "Ok").show()
    }
    
    func timeTimerAction() {
        secondCount = secondCount+1
        var sec = secondCount%Macro.second
        var minute = secondCount%(Macro.second*Macro.second)/Macro.second
        var hour = secondCount/(Macro.second*Macro.second)
        recordTimeLabel.text = "\(hour):\(minute):\(sec)"
    }
    
    func progressBarAction() {
        audioRecorder!.updateMeters()
        var peakPowerForChannel = pow(10, (0.1*audioRecorder!.peakPowerForChannel(0)))
        if peakPowerForChannel <= 1.0 {
            audioProgressBar.progress = peakPowerForChannel
        }
    }
    
    func setupRecord() ->Bool {
        var error:NSError?
        var audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: NSErrorPointer(&error))
        audioSession.setActive(true, error: NSErrorPointer(&error))
        
        var fileManager = NSFileManager.defaultManager()
        var dirPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var docsDir: AnyObject = dirPaths[0]
        var audioNameStr = "\(nameTextField.text).caf"
        var soundFilePath = docsDir.stringByAppendingPathComponent(audioNameStr)
        if !fileManager.isWritableFileAtPath(soundFilePath) {
            fileManager.removeItemAtPath(soundFilePath, error: &error)
        }
        var soundFileURL:NSURL = NSURL.fileURLWithPath(soundFilePath)!
        var recordSettings = [AVFormatIDKey:NSNumber(integer: kAudioFormatAppleIMA4),
            AVSampleRateKey: NSNumber(float: 44100.0),
            AVNumberOfChannelsKey:NSNumber(integer: 1),
            AVEncoderBitRateKey:NSNumber(integer: 12800),
            AVLinearPCMBitDepthKey:NSNumber(integer: 16),
            AVEncoderAudioQualityKey:NSNumber(integer: AVAudioQuality.Max.rawValue)]
        audioRecorder = AVAudioRecorder(URL: soundFileURL, settings: recordSettings, error: &error)
        
        if (error != nil) {
            println("error:\(error?.localizedDescription)")
        }else{
            audioRecorder.prepareToRecord()
        }
        audioRecorder!.meteringEnabled = true
        var audioHWAvailable = audioSession.inputAvailable
        if !audioHWAvailable {
            UIAlertView(title: "Warning", message: "Audio input hardware not available", delegate: nil, cancelButtonTitle: "OK").show()
            return false
        }
        return true
    }
    
    func isRecordedAudioNameExist() ->Bool {
        for dataItem in (Macro.prefs.objectForKey(Macro.saveKey) as! [NSDictionary]) {
            if dataItem.objectForKey("audioName")?.lowercaseString == nameTextField.text.lowercaseString {
                UIAlertView(title: "Alert!!", message: "Audio name already exist! Please choose another.", delegate: nil, cancelButtonTitle: "Ok").show()
                return true
            }
        }
        return false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
