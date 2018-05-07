//
//  VideoCollectionViewCell.swift
//  Video Recorder
//
//  Created by Matheus Medina da Costa Gomes on 06/05/2018.
//  Copyright © 2018 Matheus Gomes. All rights reserved.
//

import UIKit
import AVFoundation

class VideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var videoView: UIView!
    
    var playbackLayer = AVPlayerLayer()
    var videoPlayer: AVPlayer?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func setupView() {
        
        let cellBorderWidth:CGFloat = 1.0
        
        playbackLayer.videoGravity = .resizeAspectFill
        playbackLayer.frame = videoView.frame
        
        playbackLayer.player = videoPlayer
        
        videoView.layer.addSublayer(playbackLayer)
        
        self.layer.borderWidth  = cellBorderWidth
        self.layer.borderColor  = UIColor.white.cgColor
        self.backgroundColor    = UIColor.white
        
    }

    func resetVideo() {
        videoPlayer?.seek(to: kCMTimeZero)
        videoPlayer?.pause()
    }
    
    func startVideoPlayback() {
        videoPlayer?.play()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer?.currentItem, queue: .main) { _ in
            
            self.videoPlayer?.seek(to: kCMTimeZero)
            self.videoPlayer?.play()
            
        }
    }
    
}
