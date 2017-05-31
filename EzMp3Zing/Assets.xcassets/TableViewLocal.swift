//
//  TableViewLocal.swift
//  EzMp3Zing
//
//  Created by iOS Student on 2/14/17.
//  Copyright © 2017 tek4fun. All rights reserved.
//

import UIKit
import AVFoundation

class TableViewLocal: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var listSongs = [Song]()
    let audioPlay = AudioPlayer.sharedInstance
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var btn_showAudio: UIButton!
    @IBOutlet weak var view_AudioPlayer: UIView!
    @IBOutlet weak var constraintHeight: NSLayoutConstraint!
    var isUp = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        
        view_AudioPlayer.layer.shadowOffset = CGSize.zero
        view_AudioPlayer.layer.shadowColor = UIColor.black.cgColor
        view_AudioPlayer.layer.shadowOpacity = 1
        view_AudioPlayer.layer.shadowRadius = 2
        
        statusBar.layer.shadowOffset = CGSize.zero
        statusBar.layer.shadowColor = UIColor.black.cgColor
        statusBar.layer.shadowOpacity = 1
        statusBar.layer.shadowRadius = 2
        
        btn_showAudio.layer.cornerRadius = btn_showAudio.frame.height/2
        btn_showAudio.layer.shadowOffset = CGSize.zero
        btn_showAudio.layer.shadowColor = UIColor.black.cgColor
        btn_showAudio.layer.shadowOpacity = 1
        btn_showAudio.layer.shadowRadius = 1
        btn_showAudio.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        
        NotificationCenter.default.addObserver(self, selector: #selector(songDidReachEndLocal), name: NSNotification.Name(rawValue: "songDidReachEndLocal"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shufflingSongsLocal), name: NSNotification.Name(rawValue: "shufflingSongsLocal"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(prevSongLocal), name: NSNotification.Name(rawValue: "prevSongLocal"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideAudioPlayer), name: NSNotification.Name(rawValue: "hideAudioPlayer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAudioPlayer), name: NSNotification.Name(rawValue: "showAudioPlayer"), object: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    func getData()
    {
        listSongs.removeAll()
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            do
            {
                let folders = try FileManager.default.contentsOfDirectory(atPath: dir)
                for folder in folders
                {
                    if (folder != ".DS_Store")
                    {
                        let info = NSDictionary(contentsOfFile: dir+"/"+folder+"/"+"info.plist")
                        if let title = info!["title"] as? String,
                            let artistName = info!["artistName"] as? String,
                            let thumbnailPath = info!["localThumbnail"] as? String,
                            let lyric = info!["lyric"] as? String
                        {
                            let sourceLocal = dir+"/\(title)/\(title).mp3"
                            let currentSong = Song(title: title, artistName: artistName, localThumbnail: dir+thumbnailPath, localSource: sourceLocal, lyric: lyric)
                            listSongs.append(currentSong)
                        }
                    }
                }
                myTableView.reloadData()
            }
            catch let error as NSError
            {
                print(error)
            }
        }
    }
    func removeSongAtIndex(_ index: Int)
    {
        if let dir = kDOCUMENT_DIRECTORY_PATH{
            do
            {
                let path = dir+"/\(listSongs[index].title)"
                try FileManager.default.removeItem(atPath: path)
                listSongs.remove(at: index)
                self.myTableView.reloadData()
            }
            catch let error as NSError
            {
                print(error)
            }
        }
    }
    
    func hideAudioPlayer(){
        if isUp {
            isUp = false
            UIView.animate(withDuration: 0.3) {
                self.constraintHeight.constant = 0
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    @IBAction func showAudioPlayer(_ sender: UIButton){
        if !isUp {
            isUp = true
            UIView.animate(withDuration: 0.3) {
                self.constraintHeight.constant = 170
                self.view.layoutIfNeeded()
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showAudioPlayer"),object: nil)
        }
    }
    
    //UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSongs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DetailCellVC
        cell.img_Thumbnail.image = listSongs[indexPath.row].thumbnail
        cell.lb_Title.text = "\(listSongs[indexPath.row].title)"
        cell.lb_Artist.text = listSongs[indexPath.row].artistName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        audioPlay.pathString = listSongs[indexPath.row].sourceLocal
        audioPlay.titleSong = listSongs[indexPath.row].title
        audioPlay.lyric = listSongs[indexPath.row].lyric
        audioPlay.thumbnail = listSongs[indexPath.row].thumbnail
        audioPlay.artist = listSongs[indexPath.row].artistName
        audioPlay.totalSong = listSongs.count
        audioPlay.index = indexPath
        audioPlay.isOnline = false
        audioPlay.setupAudio()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupObserverAudio"),object: nil)
    }
    func songDidReachEndLocal(){
        //DeSelect Previous Cell
        let prevIndex = audioPlay.index
        myTableView.deselectRow(at: prevIndex, animated: true)
        
        //Select Current Cell
        if audioPlay.index.row < listSongs.count - 1{
            self.audioPlay.index.row += 1
        } else {
            self.audioPlay.index.row = 0
        }
        let index = audioPlay.index
        myTableView.selectRow(at: index, animated: true, scrollPosition: .middle)
        
        
        audioPlay.pathString = listSongs[index.row].sourceLocal
        audioPlay.titleSong = listSongs[index.row].title
        audioPlay.lyric = listSongs[index.row].lyric
        audioPlay.thumbnail = listSongs[index.row].thumbnail
        audioPlay.artist = listSongs[index.row].artistName
        audioPlay.setupAudio()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupObserverAudio"),object: nil)
    }
    
    func shufflingSongsLocal() {
        //DeSelect Previous Cell
        let prevIndex = audioPlay.index
        myTableView.deselectRow(at: prevIndex, animated: true)
        
        //random Song
        let randomNumber = randomSong()
        audioPlay.index.row = randomNumber
        
        //Select Current Cell
        let index = audioPlay.index
        myTableView.selectRow(at: index, animated: true, scrollPosition: .middle)
        
        
        audioPlay.pathString = listSongs[index.row].sourceLocal
        audioPlay.titleSong = listSongs[index.row].title
        audioPlay.lyric = listSongs[index.row].lyric
        audioPlay.thumbnail = listSongs[index.row].thumbnail
        audioPlay.artist = listSongs[index.row].artistName
        audioPlay.setupAudio()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupObserverAudio"),object: nil)
    }
    
    func prevSongLocal(){
        //DeSelect Previous Cell
        let prevIndex = audioPlay.index
        myTableView.deselectRow(at: prevIndex, animated: true)
        
        //Prev Song
        if audioPlay.index.row > 0 {
            self.audioPlay.index.row -= 1
        } else {
            self.audioPlay.index.row = listSongs.count - 1
        }
        
        //Select Current Cell
        let index = audioPlay.index
        myTableView.selectRow(at: index, animated: true, scrollPosition: .middle)
        
        
        audioPlay.pathString = listSongs[index.row].sourceLocal
        audioPlay.titleSong = listSongs[index.row].title
        audioPlay.lyric = listSongs[index.row].lyric
        audioPlay.thumbnail = listSongs[index.row].thumbnail
        audioPlay.artist = listSongs[index.row].artistName
        audioPlay.setupAudio()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupObserverAudio"),object: nil)
        
    }
    
    func randomSong() -> Int {
        var randomNumber = arc4random_uniform(UInt32(listSongs.count))
        while audioPlay.index.row == Int(randomNumber - 1) {
            randomNumber = arc4random_uniform(UInt32(listSongs.count))
        }
        return Int(randomNumber)
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Delete")
        { action, index in
            self.removeSongAtIndex(indexPath.row)
        }
        edit.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/255, alpha: 1.0)
        return [edit]
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
}
