//
//  AudioPlayViewController.swift
//  VoiceRecoder
//
//  Created by LanTun on 15/9/7.
//  Copyright (c) 2015年 LanTun. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayViewController: UIViewController,AVAudioPlayerDelegate {
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var audioLengthLabel: UILabel!
    @IBOutlet weak var audioNameLabel: UILabel!
    @IBOutlet weak var audioRemainLengthLabel: UILabel!

    var secondCount:Int!
    var audioTotalSecond:Int!
    var audioRemainSecond:Int!
    var audioPlayingFlag:Int!
    
    private var audioPlayer: AVAudioPlayer!
    private var audioList: [AnyObject]!
    private var timeTimer: NSTimer!
    private var currentIndex:Int!
    
    internal var selectIndex:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayback, error: nil)
        session.setActive(true, error: nil)
        currentIndex = selectIndex
        audioList = Macro.prefs.objectForKey(Macro.saveKey) as! [AnyObject]
        setupAudioPlayer(selectIndex)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func nextAudioAction(sender: AnyObject) {
        if currentIndex < audioList.count-1 {
            currentIndex = currentIndex+1
            setupAudioPlayer(currentIndex)
        }else{
            stopPlaying()
        }
        
    }
    
    @IBAction func stopAudioAction(sender: AnyObject) {
        audioPlayingFlag = 0
        
        if (timeTimer != nil) {
            timeTimer.invalidate()
            timeTimer = nil
        }
        if audioPlayer != nil {
            audioPlayer.stop()
            audioPlayer = nil
            playPauseBtn.setTitle("Play Audio", forState: .Normal)
        }
        
    }
    @IBAction func recordAgainAction(sender: AnyObject) {
        stopAudioAction(0)
    }

    @IBAction func playAudioAction(sender: AnyObject) {
        if currentIndex <= (audioList.count-1) {
            var tmpBtn:UIButton = sender as! UIButton
            if tmpBtn.currentTitle == "Play Audio" {
                if audioPlayingFlag == 0 {
                    setupAudioPlayer(currentIndex)
                }
                audioPlayer.play()
                playPauseBtn.setTitle("Pause Audio", forState: UIControlState.Normal)
                if timeTimer == 0 {
                    timeTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "audioPlaying", userInfo: nil, repeats: true)
                }
            }else{
                audioPlayingFlag = 2
                if timeTimer != 0 {
                    timeTimer.invalidate()
                    timeTimer = nil
                }
                audioPlayer.pause()
                playPauseBtn.setTitle("Play Audio", forState: UIControlState.Normal)
            }
        }
    }
    @IBAction func audioSliderAction(sender: AnyObject) {
        var slider:UISlider! = sender as! UISlider
        secondCount = Int(slider.value)
        audioRemainSecond = audioTotalSecond
        audioRemainSecond = audioRemainSecond-secondCount
        audioPlayer.currentTime = Double(slider.value)
        var sec = audioRemainSecond%Macro.second
        var minute = audioRemainSecond%(Macro.second*Macro.second)/Macro.second
        var hour = audioRemainSecond/(Macro.second*Macro.second)
        audioRemainLengthLabel.text = "\(hour):\(minute):\(sec)"
    }
    
    func setupAudioPlayer(current_index:Int) {
        stopAudioAction(0)
        currentIndex = current_index
        var currentAudioItem = audioList[currentIndex] as! [String:String!]
        var fileName: String! = currentAudioItem["audioName"]
        audioNameLabel.text = fileName
        audioLengthLabel.text = currentAudioItem["audioLength"]
        audioRemainLengthLabel.text = "-\(audioLengthLabel.text)"
        
        secondCount = 0;
        audioTotalSecond = currentAudioItem["audioTotalSecond"]!.toInt()
        audioRemainSecond = audioTotalSecond
        
        audioSlider.minimumValue = 0.0
        audioSlider.maximumValue = Float(audioTotalSecond)
        audioSlider.continuous = true
        audioSlider.value = 0.0
        
        var dirPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var docsDir: AnyObject = dirPaths[0]
        
        var audioFilePath = docsDir.stringByAppendingPathComponent(fileName.stringByAppendingString(".caf"))
        var audioSoundUrl:NSURL = NSURL(fileURLWithPath: audioFilePath)!
        var error:NSError!
        audioPlayer = AVAudioPlayer(contentsOfURL: audioSoundUrl, error: NSErrorPointer(&error))
        if error != nil {
            println("\(error.userInfo)")
            return
        }
        audioPlayer.delegate = self
        audioPlayer.volume = 1.0
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
        playPauseBtn.setTitle("Pause Audio", forState: UIControlState.Normal)
        timeTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "audioPlaying", userInfo: nil, repeats: true)
        
    }
    func audioPlaying() {
        secondCount = secondCount+1
        audioRemainSecond = audioRemainSecond-1
        if audioRemainSecond<0 {
            audioRemainSecond = 0
        }
        audioSlider.value = Float(secondCount)
        var sec = audioRemainSecond%Macro.second
        var minute = audioRemainSecond%(Macro.second*Macro.second)/Macro.second
        var hour = audioRemainSecond/(Macro.second*Macro.second)
        audioRemainLengthLabel.text = "\(hour):\(minute):\(sec)"
        
    }
    
    func stopPlaying() {
        audioSlider.value = 0.0
        audioNameLabel.text = ""
        audioLengthLabel.text = "00:00:00"
        audioRemainLengthLabel.text = "00:00:00"
        stopAudioAction(0)
        UIAlertView(title: "Alert!", message: "There is no more audio. Do you want to start from first?", delegate: self, cancelButtonTitle: "Ok").show()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        nextAudioAction(0)
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
