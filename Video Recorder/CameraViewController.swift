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

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    
    
    
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var previewView: UIView!
    @IBOutlet var deleteVideoButton: UIButton!
    
    
    var session = AVCaptureSession()
    var videoOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var playbackLayer: AVPlayerLayer?
    var videoPlayer: AVPlayer?
    
    var viewState = CurrentViewState.idle
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
        
        viewState = .idle
        updateButtons()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            NSLog("FileOutput: \(error?.localizedDescription)")
        } else {
            self.previewVideo(url: outputFileURL)
            self.viewState = .playing
            updateButtons()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        NSLog("Started recording to \(fileURL)")
        viewState = .recording
        updateButtons()
    }
    
    
    //TouchDown
    @IBAction func startRecording(_ sender: Any) {
        
        if !videoOutput.isRecording {
            
            let outputFileName = NSUUID().uuidString
            let documentsPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
            let outputFilePath = documentsPath.appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
            videoOutput.startRecording(to: outputFilePath, recordingDelegate: self)
            
        }
        
        if viewState == .playing {
            playbackLayer?.removeFromSuperlayer()
            videoPlayer?.pause()
            viewState = .idle
        }
        
        updateButtons()
        NSLog("Start recording (TouchDown)")
    }
    
    //TouchUpOutside
    @IBAction func cancelRecording(_ sender: Any) {
        NSLog("Cancel recording (TouchUpOutside)")
        videoOutput.stopRecording()
        updateButtons()
    }
    
    //TouchUpInside
    @IBAction func stopRecording(_ sender: Any) {
        NSLog("Stop recording (TouchUpInside)")
        videoOutput.stopRecording()
        updateButtons()
    }
    
    func updateButtons() {
        
        let recButtonColor = #colorLiteral(red: 1, green: 0.03442570571, blue: 0.4200517621, alpha: 0.7982662671)
        let idleButtonColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6981752997)
        let saveButtonColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 0.6973726455)
        
        let recButtonTitle = ""
        let idleButtonTitle = ""
        let saveButtonTitle = "SALVAR"
        
        switch viewState {
            
        case .idle:
            self.cameraButton.backgroundColor = idleButtonColor
            self.cameraButton.setTitle(idleButtonTitle, for: .normal)
            self.deleteVideoButton.isHidden = true
            
        case .recording:
            self.cameraButton.backgroundColor = recButtonColor
            self.cameraButton.setTitle(recButtonTitle, for: .highlighted)
            self.deleteVideoButton.isHidden = true
            
        case .playing:
            self.cameraButton.backgroundColor = saveButtonColor
            self.cameraButton.setTitle(saveButtonTitle, for: .normal)
            self.deleteVideoButton.isHidden = false
        }
        
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
    
    enum CurrentViewState {
        case idle
        case recording
        case playing
    }
    
    
}
