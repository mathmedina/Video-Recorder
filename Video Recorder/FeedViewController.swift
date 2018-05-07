//
//  FeedViewController.swift
//  Video Recorder
//
//  Created by Matheus Medina da Costa Gomes on 06/05/2018.
//  Copyright © 2018 Matheus Gomes. All rights reserved.
//

import UIKit
import AVFoundation

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var feedTableView: UITableView!
    
    let defaultManager = FileManager.default

    var videoURLs = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        feedTableView.register(UINib(nibName: "VideoTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "playerCell")
        
        loadVideoURLs()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadVideoURLs()
        feedTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadVideoURLs() {
        
        let documentsPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        do {
            try videoURLs = defaultManager.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        } catch let error as NSError {
            NSLog(error.localizedDescription)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return videoURLs.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = feedTableView.dequeueReusableCell(withIdentifier: "playerCell") as! VideoTableViewCell
        
        let currentRow = indexPath.row
        
        let cellPlayer = AVPlayer(url: videoURLs[currentRow])
        cell.videoPlayer = cellPlayer
        
        cell.setupView()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = feedTableView.cellForRow(at: indexPath) as! VideoTableViewCell
        if cell.isFullScreen {
            cell.playbackLayer.frame = self.view.bounds
        } else {
            cell.playbackLayer.frame = cell.videoView.bounds
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let frameHeight = feedTableView.frame.height
        return frameHeight/2
    }
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
