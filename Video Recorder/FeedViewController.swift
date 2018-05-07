//
//  FeedViewController.swift
//  Video Recorder
//
//  Created by Matheus Medina da Costa Gomes on 06/05/2018.
//  Copyright © 2018 Matheus Gomes. All rights reserved.
//

import UIKit
import AVFoundation

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet var feedCollectionView: UICollectionView!
    var collectionLayout = FeedCollectionViewLayout()
    
    
    let defaultManager = FileManager.default
    
    var documentsPath: URL?
    
    var videoURLs = [(String, Date)]()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        documentsPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        loadVideoURLs()
        
        let space: CGFloat = 2
        
        
        feedCollectionView.register(UINib(nibName: "VideoCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "playerCell")
        feedCollectionView.backgroundColor = self.view.backgroundColor
        
        feedCollectionView.dataSource = self
        feedCollectionView.delegate = self
        feedCollectionView.isPagingEnabled = false
        feedCollectionView.contentInset = UIEdgeInsets(top: 0, left: space, bottom: 0, right: space)
        
        collectionLayout.scrollDirection = .vertical
        
        feedCollectionView.allowsSelection = true
        feedCollectionView.allowsMultipleSelection = false
        
        let itemWidth = view.frame.width
        let itemHeight = view.frame.height/2
        collectionLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        collectionLayout.minimumLineSpacing = space
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadVideoURLs()
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func loadVideoURLs() {
        

        
        do {
            let urls = try defaultManager.contentsOfDirectory(at: documentsPath!, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            videoURLs = urls.map { url in
                (url.lastPathComponent, (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast)
                }
                .sorted(by: { $0.1 > $1.1 })
            
        } catch let error as NSError {
            NSLog(error.localizedDescription)
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return videoURLs.count
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: "playerCell", for: indexPath) as! VideoCollectionViewCell
        
        let currentRow = indexPath.row

        
        let currentURL = URL(fileURLWithPath: videoURLs[currentRow].0, isDirectory: false, relativeTo: documentsPath)
        let cellPlayer = AVPlayer(url: currentURL)
        cell.videoPlayer = cellPlayer

        
        cell.setupView()
        
        cell.playbackLayer.videoGravity = .resizeAspectFill
        cell.playbackLayer.frame = cell.bounds

        
        return cell
        
    }


    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = feedCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell
        if (cell.videoPlayer?.rate)! <= Float(0) {
            cell.startVideoPlayback()
        } else {
            cell.resetVideo()
        }
    }

    
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if feedCollectionView.cellForItem(at: indexPath) != nil {
            let cell = feedCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell
            cell.resetVideo()
        }
    }
    
    
    
    @IBAction func segueToCamera(_ sender: Any) {
        performSegue(withIdentifier: "dismiss", sender: self)
    }
    
    
    
}
