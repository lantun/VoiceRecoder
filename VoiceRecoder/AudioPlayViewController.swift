//
//  AudioPlayViewController.swift
//  VoiceRecoder
//
//  Created by LanTun on 15/9/7.
//  Copyright (c) 2015年 LanTun. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayViewController: UIViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func nextAudioAction(sender: AnyObject) {
        
    }
    
    @IBAction func stopAudioAction(sender: AnyObject) {
        audioPlayingFlag = 0
        
        if (timeTimer != nil) {
            timeTimer.invalidate()
            timeTimer = nil
        }
        audioPlayer.stop()
        audioPlayer = nil
        playPauseBtn.setTitle("Play Audio", forState: .Normal)
    }
    @IBAction func recordAgainAction(sender: AnyObject) {
    }

    @IBAction func playAudioAction(sender: AnyObject) {
        if currentIndex <= (audioList.count-1) {
            var tmpBtn:UIButton = sender as! UIButton
            if tmpBtn.currentTitle == "Play Audio" {
                if audioPlayingFlag == 0 {
                }
            }
        }
    }
    @IBAction func audioSliderAction(sender: AnyObject) {
    }
    
    func setupAudioPlayer(current_index:Int) {
        stopAudioAction(0)
        currentIndex = current_index
        var currentAudioItem = audioList[currentIndex] as! [String:String!]
        audioNameLabel.text = currentAudioItem["audioName"]
        audioLengthLabel.text = currentAudioItem["audioLength"]
        audioRemainLengthLabel.text = "-\(audioLengthLabel.text)"
        
        secondCount = 0;
        audioTotalSecond = Int(currentAudioItem["audioTotalSecond"])
        audioRemainSecond = audioTotalSecond
        
        audioSlider.minimumValue = 0.0
        audioSlider.maximumValue = audioTotalSecond
        audioSlider.continuous = true
        audioSlider.value = 0.0
        
        var dirPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var docsDir = dirPaths[0]
        var audioFilePath = docsDir.stringByAppendingPathComponent("\(audioNameLabel.text).caf")
        
        
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
