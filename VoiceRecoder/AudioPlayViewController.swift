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
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try session.setActive(true)
        } catch _ {
        }
        currentIndex = selectIndex
        audioList = Macro.prefs.objectForKey(Macro.saveKey) as! [AnyObject]
        setupAudioPlayer(selectIndex)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidDisappear(animated: Bool) {
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
        } catch _ {
        }
        stopAudioAction(0)
        super.viewDidDisappear(true)
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
            let tmpBtn:UIButton = sender as! UIButton
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
        }else{
            stopPlaying()
        }
    }
    @IBAction func audioSliderAction(sender: AnyObject) {
        let slider:UISlider! = sender as! UISlider
        secondCount = Int(slider.value)
        audioRemainSecond = audioTotalSecond
        audioRemainSecond = audioRemainSecond-secondCount
        audioPlayer.currentTime = Double(slider.value)
        let sec = audioRemainSecond%Macro.second
        let minute = audioRemainSecond%(Macro.second*Macro.second)/Macro.second
        let hour = audioRemainSecond/(Macro.second*Macro.second)
        audioRemainLengthLabel.text = "\(hour):\(minute):\(sec)"
    }
    
    func setupAudioPlayer(current_index:Int) {
        
        stopAudioAction(0)
        currentIndex = current_index
        var currentAudioItem = audioList[currentIndex] as! [String:String!]
        let fileName: String! = currentAudioItem["audioName"]
        audioNameLabel.text = fileName
        audioLengthLabel.text = currentAudioItem["audioLength"]
        audioRemainLengthLabel.text = audioLengthLabel.text
        
        secondCount = 0;
        audioTotalSecond = Int(currentAudioItem["audioTotalSecond"]!)
        audioRemainSecond = audioTotalSecond
        
        audioSlider.minimumValue = 0.0
        audioSlider.maximumValue = Float(audioTotalSecond)
        audioSlider.continuous = true
        audioSlider.value = 0.0
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docsDir: String = dirPaths[0]
        
        let audioFilePath =  docsDir + "/" + fileName + ".caf"
        let audioSoundUrl:NSURL = NSURL.fileURLWithPath(audioFilePath, isDirectory: true)
        do {
            audioPlayer = try AVAudioPlayer.init(contentsOfURL: audioSoundUrl)
        } catch let error1 as NSError {
            print("init audioPlayer error:\(error1.userInfo)")
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
        let sec = audioRemainSecond%Macro.second
        let minute = audioRemainSecond%(Macro.second*Macro.second)/Macro.second
        let hour = audioRemainSecond/(Macro.second*Macro.second)
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
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
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
