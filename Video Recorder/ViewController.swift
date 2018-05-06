//
//  ViewController.swift
//  Video Recorder
//
//  Created by Matheus Medina da Costa Gomes on 05/05/2018.
//  Copyright © 2018 Matheus Gomes. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    
    

    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var previewView: UIView!
    @IBOutlet var deleteVideoButton: UIButton!
    
    
    var session = AVCaptureSession()
    var videoOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var playbackLayer: AVPlayerLayer?
    var videoPlayer: AVPlayer?
    
    var isPlayingVideo = false
    var currentVideoURL:URL?
    
    var fileManager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupSession()
        requestAccess()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = previewView.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupSession() {
        
        session.sessionPreset = .high
        let backCamera = AVCaptureDevice.default(for: .video)
        let microphone = AVCaptureDevice.default(for: .audio)
        do {
            
            
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
            previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            previewView.layer.addSublayer(previewLayer!)
            
            //input
            let videoInput = try AVCaptureDeviceInput(device: backCamera!)
            let audioInput = try AVCaptureDeviceInput(device: microphone!)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
            if session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }
            
            //output
            videoOutput.setOutputSettings([AVVideoCodecKey : AVVideoCodecType.h264], for: (previewLayer?.connection)!)
            
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
            

            session.startRunning()
            
            
            
            
            
        } catch let error as NSError {
            NSLog(error.localizedDescription)
        }
        
    }
    
    func previewVideo(url: URL) {
        
        videoPlayer = AVPlayer(url: url)
        
        playbackLayer = AVPlayerLayer(player: videoPlayer)
        playbackLayer?.frame = previewView.bounds
        previewView.layer.addSublayer(playbackLayer!)
        
        
        videoPlayer?.play()
        currentVideoURL = url
        self.deleteVideoButton.isHidden = false
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer?.currentItem, queue: .main) { _ in
            self.videoPlayer?.seek(to: kCMTimeZero)
            self.videoPlayer?.play()
        }
        
        NSLog("Started video preview - url: \(url)")
    }
    
    @IBAction func deleteCurrentVideo(_ sender: Any) {
        
        playbackLayer?.removeFromSuperlayer()
        videoPlayer?.pause()
        
        do {
            
            try fileManager.removeItem(at: currentVideoURL!)
            NSLog("Successfully deleted current video")
        } catch let error as NSError {
            
            NSLog(error.localizedDescription)
            
        }
        
        self.isPlayingVideo = false
        self.deleteVideoButton.isHidden = true
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            NSLog("FileOutput: \(error?.localizedDescription)")
        } else {
            self.previewVideo(url: outputFileURL)
            self.isPlayingVideo = true
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        NSLog("Started recording to \(fileURL)")
    }
    
    
    //TouchDown
    @IBAction func startRecording(_ sender: Any) {
        
        if !videoOutput.isRecording {
            
            let outputFileName = NSUUID().uuidString
            let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
            videoOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            
        } else {
            videoOutput.stopRecording()
        }
        
        NSLog("Start recording (TouchDown)")
    }
    
    //TouchUpOutside
    @IBAction func cancelRecording(_ sender: Any) {
        NSLog("Cancel recording (TouchUpOutside)")
        videoOutput.stopRecording()
    }
    
    //TouchUpInside
    @IBAction func stopRecording(_ sender: Any) {
        NSLog("Stop recording (TouchUpInside)")
        videoOutput.stopRecording()
    }
    
    func requestAccess() {
        
        let videoAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let audioAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        let libraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        if videoAuthorizationStatus != .authorized {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    NSLog("Video access granted")
                }
            }
        }
        
        if libraryAuthorizationStatus != .authorized {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    NSLog("Library access granted")
                }
            }
        }
        
    }
    
    
}
