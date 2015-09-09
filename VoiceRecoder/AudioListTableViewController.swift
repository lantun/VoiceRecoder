//
//  AudioListTableViewController.swift
//  VoiceRecoder
//
//  Created by LanTun on 15/9/5.
//  Copyright (c) 2015年 LanTun. All rights reserved.
//

import UIKit

class AudioListTableViewController: UITableViewController,UITableViewDelegate, UITableViewDataSource {
    
    private var audioList:[[String:String]]!
    let cellIdentifier = "ApplicationCell"
    
    @IBOutlet var listtable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listtable.registerNib(UINib(nibName: "AudioListTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadAudioList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadAudioList() {
        if audioList?.count > 0 {
            audioList?.removeAll(keepCapacity: false)
        }
        NSUserDefaults.standardUserDefaults()
        audioList = Macro.prefs.objectForKey(Macro.saveKey) as! [[String:String]]
        listtable.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rownum = audioList.count
        println("row:\(rownum)")
        return rownum
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AudioListTableViewCell
        var dataitem = audioList?[indexPath.row]
        cell.label1.text = dataitem?["audioName"]
        cell.label2.text = dataitem?["audioLength"]
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var playerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AudioPlayViewController") as! AudioPlayViewController
        playerVC.selectIndex = indexPath.row
        navigationController?.pushViewController(playerVC, animated: true)
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var dataitem = audioList[indexPath.row]
            var delFileName = dataitem["audioName"]
            Macro.deleteAudioFile(delFileName!)
            audioList.removeAtIndex(indexPath.row)
            Macro.prefs.setObject(audioList, forKey: Macro.saveKey)
            Macro.prefs.synchronize()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

}
