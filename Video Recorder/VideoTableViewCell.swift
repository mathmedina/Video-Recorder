//
//  VideoTableViewCell.swift
//  Video Recorder
//
//  Created by Matheus Medina da Costa Gomes on 06/05/2018.
//  Copyright © 2018 Matheus Gomes. All rights reserved.
//

import UIKit
import AVFoundation

class VideoTableViewCell: UITableViewCell {

    
    @IBOutlet var videoView: UIView!
    
    var playbackLayer = AVPlayerLayer()
    var videoPlayer: AVPlayer?
    
    var isFullScreen = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected && (videoPlayer?.rate)! <= Float(0) {
            self.videoPlayer?.play()
            self.isFullScreen = true
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer?.currentItem, queue: .main) { _ in
                self.videoPlayer?.seek(to: kCMTimeZero)
                self.videoPlayer?.play()
            }
        } else {
            self.videoPlayer?.seek(to: kCMTimeZero)
            self.videoPlayer?.pause()
            self.isFullScreen = false
        }
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func setupView() {
        
        playbackLayer.videoGravity = .resizeAspectFill
        playbackLayer.frame = videoView.bounds
        
        playbackLayer.player = videoPlayer
        
        videoView.layer.addSublayer(playbackLayer)
        
    }

    
}
