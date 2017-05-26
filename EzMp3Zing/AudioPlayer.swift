//
//  ViewController.swift
//  EzMp3Zing
//
//  Created by iOS Student on 2/14/17.
//  Copyright © 2017 tek4fun. All rights reserved.
//


import UIKit
import AVFoundation

class AudioPlayer{

    static let sharedInstance = AudioPlayer()
    
    private init() {
    }
    
    var pathString = ""
    var repeating = false
    var playing = false
    var shuffling = false
    var duration = Float()
    var currentTime = Float()
    var titleSong = ""
    var lyric = ""
    var player = AVPlayer()
    var index = IndexPath()
    var isOnline = false
    var totalSong = 0
    var artist = ""
    var thumbnail = #imageLiteral(resourceName: "music-player")
    func setupAudio()
    {
       // var url = URL()
        var url: URL
    
        if let checkingUrl = URL(string: pathString)
        {
            url = checkingUrl
        }
        else
        {
            url = URL(fileURLWithPath: pathString)
        }
        let playerItem = AVPlayerItem(url:url)
        player = AVPlayer(playerItem:playerItem)
        player.rate = 1.0;
        player.volume = 0.5
        player.play()
        playing = true
    }
    
    
    //action
    func Repeat(_ repeatSong: Bool) {
        if(repeatSong == true){
            repeating = true
        }
        else{
            repeating = false
        }
    }
    
    func action_PlayPause() {
        if(playing == false){
            player.play()
            playing = true
        }
        else{
            player.pause()
            playing = false
        }
    }
    
    func actionPlay() {
        player.play()
        playing = true
    }
    
    func actionPause() {
        player.pause()
        playing = false
    }
    func sld_Duration(_ value: Float) {
        let timeToSeek = value * duration
        let time = CMTimeMake(Int64(timeToSeek), 1)
        player.seek(to: time)
    }
    
    func sld_Volume(_ value: Float) {
        player.volume = value
    }
    
    func shuffle(_ shuffleSong: Bool) {
        if shuffleSong == true {
            shuffling = true
        } else {
            shuffling = false
        }
    }
    
    
    
}

