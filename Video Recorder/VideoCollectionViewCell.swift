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
    
    var isFullScreen = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        if selected && (videoPlayer?.rate)! <= Float(0) {
//            self.videoPlayer?.play()
//            self.isFullScreen = true
//            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer?.currentItem, queue: .main) { _ in
//                self.videoPlayer?.seek(to: kCMTimeZero)
//                self.videoPlayer?.play()
//            }
//        } else {
//            self.videoPlayer?.seek(to: kCMTimeZero)
//            self.videoPlayer?.pause()
//            self.isFullScreen = false
//        }
//
//    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func setupView() {
        
        playbackLayer.videoGravity = .resizeAspectFill
        playbackLayer.frame = videoView.frame
        
        playbackLayer.player = videoPlayer
        
        videoView.layer.addSublayer(playbackLayer)
        
        self.layer.borderWidth  = 1.0
        self.layer.borderColor  = UIColor.white.cgColor
        self.backgroundColor    = UIColor.white
        
    }

    
}
