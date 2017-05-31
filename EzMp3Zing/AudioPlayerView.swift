//
//  AudioPlayerView.swift
//  EzMp3Zing
//
//  Created by iOS Student on 2/14/17.
//  Copyright © 2017 tek4fun. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class AudioPlayerView: UIViewController, AVAudioPlayerDelegate {
    var overlayView: UIView!
    var alertView: UIView!
    @IBOutlet weak var btn_Rewind: UIButton!
    var animator: UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var snapBehavior : UISnapBehavior!
    var isSetup = false
    @IBOutlet weak var btn_Next: UIButton!
    let audioPlayer = AudioPlayer.sharedInstance
    let mpRemoteControlCenter = MPRemoteCommandCenter.shared()
    var isPause = false
    @IBOutlet weak var btn_Shuffle: UIButton!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var sld_Volume: UISlider!
    @IBOutlet weak var sld_Duration: UISlider!
    @IBOutlet weak var lbl_TotalTime: UILabel!
    @IBOutlet weak var lbl_CurrentTime: UILabel!
    @IBOutlet weak var btn_Play: UIButton!
    
    
    //var checkAddObserverAudio = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btn_Rewind.isEnabled = false
        btn_Next.isEnabled = false
        btn_Play.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(setupObserverAudio), name: NSNotification.Name(rawValue: "setupObserverAudio"), object: nil)
        //createOverlay()
        //createAlert()
//        audioPlayer.player.addObserver(audioPlayer.player, forKeyPath: "status", options: .new, context: nil)
        
        setBackGroundPlayer()
    }
    
    func updateNowPlayingCenter() {
        let center = MPNowPlayingInfoCenter.default()
        let remote = MPRemoteCommandCenter.shared()
        var songInfo = [String: AnyObject]()
        songInfo[MPMediaItemPropertyTitle] = audioPlayer.titleSong as AnyObject?
        let artwork = MPMediaItemArtwork(image: audioPlayer.thumbnail)
        songInfo[MPMediaItemPropertyArtwork] = artwork as AnyObject?
        songInfo[MPMediaItemPropertyArtist] = audioPlayer.artist as AnyObject?
        songInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration as AnyObject?
        songInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime as AnyObject?
        songInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0 as AnyObject?
        center.nowPlayingInfo = songInfo
        
        if self.audioPlayer.index.row <= 0 {
            remote.previousTrackCommand.isEnabled = false
        } else {
            remote.previousTrackCommand.isEnabled = true
        }
        if audioPlayer.index.row >= self.audioPlayer.totalSong - 1 {
            remote.nextTrackCommand.isEnabled = false
        } else {
            remote.nextTrackCommand.isEnabled = true
        }
    }
    
    func songDidPause(){
        let center = MPNowPlayingInfoCenter.default()
        var songInfo = [String: AnyObject]()
        songInfo[MPMediaItemPropertyTitle] = audioPlayer.titleSong as AnyObject?
        let artwork = MPMediaItemArtwork(image: audioPlayer.thumbnail)
        songInfo[MPMediaItemPropertyArtwork] = artwork as AnyObject?
        songInfo[MPMediaItemPropertyArtist] = audioPlayer.artist as AnyObject?
        songInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration as AnyObject?
        songInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0.0 as AnyObject?
        songInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime as AnyObject?
        center.nowPlayingInfo = songInfo
    }
    
    private func setupNowPlayingInfoCenter() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let center = MPRemoteCommandCenter.shared()
        
        center.playCommand.isEnabled = true
        center.playCommand.addTarget(handler: { (event) in
            self.audioPlayer.actionPlay()
            self.isPause = false
            self.updateNowPlayingCenter()
            return .success
        })
        
        center.pauseCommand.isEnabled = true
        center.pauseCommand.addTarget(handler: { (event) in
            self.audioPlayer.actionPause()
            self.songDidPause()
            self.isPause = true
            return .success
        })
        
        if audioPlayer.index.row >= self.audioPlayer.totalSong - 1 {
            center.nextTrackCommand.isEnabled = false
        } else {
            center.nextTrackCommand.isEnabled = true
        }
        center.nextTrackCommand.addTarget(handler: { (event) in
            self.songDidPause()
            self.isPause = false
            self.nextSong()
            self.updateNowPlayingCenter()
            return .success
        })
        
        
        if self.audioPlayer.index.row <= 0 {
            center.previousTrackCommand.isEnabled = false
        } else {
            center.previousTrackCommand.isEnabled = true
        }
        center.previousTrackCommand.addTarget(handler: { (event) in
            self.songDidPause()
            self.isPause = false
            self.previousSong()
            self.updateNowPlayingCenter()
            return .success
        })
    }
    
    func setBackGroundPlayer() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .defaultToSpeaker)
            //UIApplication.shared.beginReceivingRemoteControlEvents()
            print("AVAudioSession Category Playback OK")
            
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    func setupObserverAudio()
    {
        if !isSetup {
            setupNowPlayingInfoCenter()
            isSetup = true
        }
        lbl_Title.text = audioPlayer.titleSong
        addThumbImgForButton()
        btn_Rewind.isEnabled = true
        btn_Next.isEnabled = true
        btn_Play.isEnabled = true
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timeUpdate), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayer.player.currentItem)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "status") {
            if audioPlayer.player.status == .readyToPlay {
                if !isSetup {
                    setupNowPlayingInfoCenter()
                    isSetup = true
                }
                lbl_Title.text = audioPlayer.titleSong
                addThumbImgForButton()
                btn_Rewind.isEnabled = true
                btn_Next.isEnabled = true
                btn_Play.isEnabled = true
                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timeUpdate), userInfo: nil, repeats: true)
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayer.player.currentItem)
            }
        }
    }
    
    func playerItemDidReachEnd(_ notification: Notification){
        if audioPlayer.isOnline {
            if audioPlayer.repeating {
                audioPlayer.player.seek(to: kCMTimeZero)
                audioPlayer.player.play()
            } else {
                if audioPlayer.shuffling {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "shufflingSongs"),object: nil)
                } else {
                    audioPlayer.player.seek(to: kCMTimeZero)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "songDidReachEnd"),object: nil)
                }
            }
        } else {
            if audioPlayer.repeating {
                audioPlayer.player.seek(to: kCMTimeZero)
                audioPlayer.player.play()
            } else {
                if audioPlayer.shuffling {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "shufflingSongsLocal"),object: nil)
                } else {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "songDidReachEndLocal"),object: nil)
                }
            }
        }
    }
    
    func timeUpdate() {
        audioPlayer.duration = Float((audioPlayer.player.currentItem?.duration.seconds)!)
        audioPlayer.currentTime = Float(audioPlayer.player.currentTime().seconds)
        
        
        if !isPause {
            self.updateNowPlayingCenter()
        }
        let m = Int(floor(audioPlayer.currentTime/60))
        let s = Int(round(audioPlayer.currentTime - Float(m)*60))
        if audioPlayer.duration > 0 {
            let mduration = Int(floor(audioPlayer.duration/60))
            let sdduration = Int(round(audioPlayer.duration - Float(mduration)*60))
            self.lbl_CurrentTime.text = NSString(format: "%02d:%02d", m, s) as String //String(format: "%02d", m) + ":" + String(format: "%02d", s)
            self.lbl_TotalTime.text = NSString(format: "%02d:%02d", mduration, sdduration) as String //String(format: "%02d", mduration) + ":" + String(format: "%02d", sdduration)
            self.sld_Duration.value = Float(audioPlayer.currentTime/audioPlayer.duration)
            self.sld_Volume.value = audioPlayer.player.volume
        }
    }
    
    func addThumbImgForButton() {
        if(audioPlayer.playing == true) {
            btn_Play.setBackgroundImage(UIImage(named:"pause.png"), for: .normal)
        } else {
            btn_Play.setBackgroundImage(UIImage(named:"play.png"), for: .normal)
        }
    }
    
    //action
    @IBAction func Repeat(_ sender: UISwitch) {
        audioPlayer.Repeat(sender.isOn)
    }
    
    @IBAction func action_PlayPause(_ sender: AnyObject) {
        
        audioPlayer.action_PlayPause()
        addThumbImgForButton()
    }
    @IBAction func sld_Duration(_ sender: UISlider) {
        audioPlayer.sld_Duration(sender.value)
    }
    @IBAction func sld_Volume(_ sender: UISlider) {
        audioPlayer.sld_Volume(sender.value)
    }
    
    @IBAction func actionShowLyric(_ sender: AnyObject) {
        showAlert()
    }
    @IBAction func actionShuffle(_ sender: UIButton) {
        if audioPlayer.shuffling {
            sender.setImage(#imageLiteral(resourceName: "ic_shuffle_x2"), for: .normal)
            audioPlayer.shuffling = false
        } else {
            sender.setImage(#imageLiteral(resourceName: "ic_shuffle_white_x2"), for: .normal)
            audioPlayer.shuffling = true
        }
    }
    @IBAction func actionRewind(_ sender: Any) {
        previousSong()
    }
    
    @IBAction func actionNext(_ sender: Any) {
        nextSong()
    }
    @IBAction func actionHideAudioPlayer(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "hideAudioPlayer"),object: nil)
    }
    
    func playPause() {
        audioPlayer.action_PlayPause()
        addThumbImgForButton()
    }
    
    
    func nextSong(){
        if audioPlayer.isOnline{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "songDidReachEnd"),object: nil)
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "songDidReachEndLocal"),object: nil)
        }
    }
    func previousSong(){
        if audioPlayer.isOnline{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "prevSong"),object: nil)
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "prevSongLocal"),object: nil)
            
        }
    }
    
    // alert
    
    func createOverlay() {
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.clear
        overlayView.alpha = 0.0
        view.addSubview(overlayView)
    }
    
    func createAlert() {
        
        //let alertWidth: CGFloat = 375
        let alertWidth = self.view.frame.width
        let alertHeight: CGFloat = 150+100
        let buttonWidth: CGFloat = 40
        let alertViewFrame: CGRect = CGRect(x: 0, y: -100, width: self.view.frame.width, height: alertHeight)
        alertView = UIView(frame: alertViewFrame)
        alertView.backgroundColor = UIColor(hue:0.60, saturation:0.36, brightness:0.33, alpha:1.00)
        alertView.alpha = 0.0
        alertView.layer.cornerRadius = 10;
        alertView.layer.shadowColor = UIColor.black.cgColor;
        alertView.layer.shadowOffset = CGSize(width: 0, height: 5);
        alertView.layer.shadowOpacity = 0.3;
        alertView.layer.shadowRadius = 10.0;
        
        //create Close Button
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Dismiss.png"), for: UIControlState())
        button.backgroundColor = UIColor.clear
        button.frame = CGRect(x: alertWidth/2 - buttonWidth/2, y: alertHeight - buttonWidth/2, width: buttonWidth, height: buttonWidth)
        button.addTarget(self, action: #selector(AudioPlayerView.dismissAlert), for: UIControlEvents.touchUpInside)
        
        //create Text View
        let rectLabel = CGRect(x: 0, y: alertView.bounds.minY , width: alertView.frame.width, height: alertHeight - buttonWidth/2)
        let label = UITextView(frame: rectLabel)
        label.textColor = UIColor.white
        label.text = audioPlayer.lyric
        label.contentMode = .scaleToFill
        label.textAlignment = .center
        label.isEditable = false
        label.backgroundColor = UIColor(hue:0.60, saturation:0.36, brightness:0.33, alpha:1.00)
        alertView.addSubview(label)
        alertView.addSubview(button)
        view.addSubview(alertView)
    }
    
    func showAlert() {
        if (alertView == nil) {
            createAlert()
        }
        // Animate in the overlay
        UIView.animate(withDuration: 0.4, animations: {
            self.overlayView.alpha = 1.0
        })
        
        // Animate the alert view using UIKit Dynamics.
        alertView.alpha = 1.0
        
    }
    
    func dismissAlert() {
        
        UIView.animate(withDuration: 0.4, animations: {
            self.overlayView.alpha = 0.0
            self.alertView.alpha = 0.0
        }, completion: {
            (value: Bool) in
            self.alertView.removeFromSuperview()
            self.alertView = nil
        })
        
    }
    
}
