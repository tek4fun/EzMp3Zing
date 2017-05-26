//
//  TableViewOnline.swift
//  EzMp3Zing
//
//  Created by iOS Student on 2/13/17.
//  Copyright © 2017 tek4fun. All rights reserved.
//

import UIKit
import AVFoundation
let kDOCUMENT_DIRECTORY_PATH = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first
class TableViewOnline: UIViewController, UITableViewDelegate,UITableViewDataSource {
    var listSongs = [Song]()
    @IBOutlet weak var view_Navbar: UIView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var lb_Day: UILabel!
    @IBOutlet weak var btn_Next: UIButton!
    @IBOutlet weak var btn_showAudio: UIButton!

    @IBOutlet weak var view_AudioPlayer: UIView!
    
    @IBOutlet weak var constraintHeight: NSLayoutConstraint!
    
    let actInd = UIActivityIndicatorView()
    var trasFrame = UIView()
    let showButton = UIButton()
    let audioPlay = AudioPlayer.sharedInstance
    var lastWeek:Int = 0
    var currentWeek:Int = 0
    var currentYear:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        
        getCurrentWeek()
        getCurrentYear()
        lastWeek = currentWeek
        btn_Next.isEnabled = false
        lb_Day.text = "\(currentWeek)/\(currentYear)"
        getData()
        
        view_AudioPlayer.layer.shadowOffset = CGSize.zero
        view_AudioPlayer.layer.shadowColor = UIColor.black.cgColor
        view_AudioPlayer.layer.shadowOpacity = 1
        view_AudioPlayer.layer.shadowRadius = 2
        
        view_Navbar.bringSubview(toFront: myTableView)
        view_Navbar.layer.shadowOffset = CGSize.zero
        view_Navbar.layer.shadowColor = UIColor.black.cgColor
        view_Navbar.layer.shadowOpacity = 1
        view_Navbar.layer.shadowRadius = 2
        
        btn_showAudio.layer.cornerRadius = btn_showAudio.frame.height/2
        btn_showAudio.layer.shadowOffset = CGSize.zero
        btn_showAudio.layer.shadowColor = UIColor.black.cgColor
        btn_showAudio.layer.shadowOpacity = 1
        btn_showAudio.layer.shadowRadius = 1
        btn_showAudio.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)


        
        NotificationCenter.default.addObserver(self, selector: #selector(songDidReachEnd), name: NSNotification.Name(rawValue: "songDidReachEnd"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shufflingSongs), name: NSNotification.Name(rawValue: "shufflingSongs"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(prevSong), name: NSNotification.Name(rawValue: "prevSong"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideAudioPlayer), name: NSNotification.Name(rawValue: "hideAudioPlayer"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func hideAudioPlayer(){

        UIView.animate(withDuration: 0.3) {
            self.constraintHeight.constant = 0
            self.view.layoutIfNeeded()
        }

    }
    
    
    
    @IBAction func showAudioPlayer(_ sender: UIButton){
        UIView.animate(withDuration: 0.3) {
            self.constraintHeight.constant = 170
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func actionPreWeek(_ sender: UIButton) {
        if currentWeek > 0 {
            currentWeek -= 1
        } else {
            currentWeek = 52
            currentYear -= 1
        }
        if currentWeek == lastWeek {
            btn_Next.isEnabled = false
        } else {
            btn_Next.isEnabled = true
        }
        listSongs.removeAll()
        lb_Day.text = "\(currentWeek)/\(currentYear)"
        getData()
        
    }
    @IBAction func actionNextWeek(_ sender: UIButton) {
        if currentWeek < 52 {
            currentWeek += 1
        } else {
            currentWeek = 1
            currentYear += 1
        }
        if currentWeek == lastWeek {
            btn_Next.isEnabled = false
        } else {
            btn_Next.isEnabled = true
        }
        listSongs.removeAll()
        lb_Day.text = "\(currentWeek)/\(currentYear)"
        getData()
        
    }
    
    
    func getData()
    {
        let data = NSData(contentsOf: URL(string: "http://mp3.zing.vn/bang-xep-hang/bai-hat-Au-My/IWZ9Z0BW.html?w=\(currentWeek)&y=\(currentYear)")!)
        
        let doc = TFHpple(htmlData: data as Data!)
        if let elements = doc?.search(withXPathQuery: "//h3[@class='title-item']/a") as? [TFHppleElement]
        {
            showActivityIndicatory(uiView: self.view)
            for element in elements
            {
                DispatchQueue.global(qos: .default).async(execute: {
                    let id = self.getID(path: element.object(forKey: "href") as NSString)
                    let url = NSURL(string: "http://api.mp3.zing.vn/api/mobile/song/getsonginfo?keycode=fafd463e2131914934b73310aa34a23f&requestdata={\"id\":\"\(id)\"}".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
                    
                    let lyric = NSURL(string: "http://api.mp3.zing.vn/api/mobile/song/getlyrics?keycode=fafd463e2131914934b73310aa34a23f&requestdata={\"id\":\"\(id)\"}".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
                    var stringData = ""
                    var lyricData = ""
                    do {
                        stringData = try String(contentsOf: url! as URL)
                        lyricData = try String(contentsOf: lyric! as URL)
                    }
                    catch let error as NSError
                    {
                        print(error)
                    }
                    let json = self.convertStringToDictionary(text: stringData)
                    let lyricJson = self.convertStringToDictionary(text: lyricData)
                    if (json != nil)
                    {
                        self.addSongToList(json!, lyricJson!)
                    }
                })
            }
        }
        
    }
    
    func addSongToList(_ json: [String: AnyObject],_ lyricJson: [String: AnyObject])
    {
        if let title = json["title"] as? String,
            let artistName = json["artist"] as? String,
            let thumbnail = json["thumbnail"] as? String,
            let lyric = lyricJson["content"] as? String,
            let source = json["source"]!["128"] as? String {
            let currentSong = Song(title: title, artistName: artistName, thumbnail: thumbnail, source: source, lyric: lyric)
            DispatchQueue.main.async {
                self.listSongs.append(currentSong)
                self.myTableView.reloadData()
                self.actInd.stopAnimating()
                self.trasFrame.removeFromSuperview()
            }
        }
    }
    
    func getCurrentYear() {
        let date = Date()
        let calendar = Calendar.current
        currentYear = Int(calendar.component(.year, from: date))
    }
    
    func getCurrentWeek() {
        // get week
        let data = NSData(contentsOf: URL(string: "http://mp3.zing.vn/bang-xep-hang/bai-hat-Au-My/IWZ9Z0BW.html")!)
        let doc = TFHpple(htmlData: data as Data!)
        
        //split week number from String
        
        if let element = /*String(describing:*/ doc?.search(withXPathQuery: "//p[@class='pull-left']/strong") as? [TFHppleElement] {
            for elemen in element {
                let content = elemen.content
                let stringArray = content?.components(separatedBy: " ")
                let trimmedStringArray = stringArray?[1].components(separatedBy: ":")
                let week = trimmedStringArray?[0]
                currentWeek = Int(week!)!
            }
        }
    }
    func getID(path: NSString) -> NSString {
        let id = (path.lastPathComponent as NSString).deletingPathExtension
        return id as NSString
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Sumtingwong!")
            }
        }
        return nil
    }
    
    
    
    
    func downloadSong(index: Int) {
        let dataSong = try? Data(contentsOf: URL(string:listSongs[index].sourceOnline)!)
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            let pathToWriteSong = "\(dir)/\(listSongs[index].title)"
            //writing
            do
            {
                try FileManager.default.createDirectory(atPath: pathToWriteSong, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError
            {
                print(error.localizedDescription)
            }
            
            //ghi bai hat
            writeDataToPath(dataSong! as NSObject, path: "\(pathToWriteSong)/\(listSongs[index].title).mp3")
            writeInfoSong(listSongs[index], path: pathToWriteSong)
        }
    }
    
    func writeInfoSong(_ song: Song, path: String)
    {
        let dictData = NSMutableDictionary()
        dictData.setValue(song.title, forKey: "title")
        dictData.setValue(song.artistName, forKey: "artistName")
        dictData.setValue("/\(song.title)/thumbnail.png", forKey: "localThumbnail")
        dictData.setValue(song.sourceOnline, forKey: "sourceOnline")
        dictData.setValue(song.lyric, forKey: "lyric")
        //writing info
        writeDataToPath(dictData, path: "\(path)/info.plist")
        
        //writing thumbnail
        let dataThumbnail = NSData(data: UIImagePNGRepresentation(song.thumbnail)!) as Data
        writeDataToPath(dataThumbnail as NSObject, path: "\(path)/thumbnail.png")
    }
    
    func writeDataToPath(_ data: NSObject, path: String)
    {
        if let dataToWrite = data as? Data
        {
            try? dataToWrite.write(to: URL(fileURLWithPath: path), options: [.atomic])
        }
        else if let dataInfo = data as? NSDictionary
        {
            dataInfo.write(toFile: path, atomically: true)
        }
    }
    
    func showActivityIndicatory(uiView: UIView) {
        trasFrame = UIView(frame: CGRect(x: myTableView.frame.minX, y: myTableView.frame.minY, width: myTableView.frame.width, height: myTableView.frame.height))
        trasFrame.alpha = 0.5
        trasFrame.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.3)
        
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        actInd.center = trasFrame.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        
        uiView.addSubview(trasFrame)
        uiView.addSubview(actInd)
        actInd.startAnimating()
    }
    
    //UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSongs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DetailCellVC
        if indexPath.row < listSongs.count{
            cell.img_Thumbnail.image = listSongs[indexPath.row].thumbnail
            cell.lb_Artist.text = listSongs[indexPath.row].artistName
            cell.lb_Title.text = listSongs[indexPath.row].title
            return cell
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        audioPlay.pathString = listSongs[indexPath.row].sourceOnline
        audioPlay.titleSong = listSongs[indexPath.row].title
        audioPlay.lyric = listSongs[indexPath.row].lyric
        audioPlay.thumbnail = listSongs[indexPath.row].thumbnail
        audioPlay.artist = listSongs[indexPath.row].artistName
        audioPlay.index = indexPath
        audioPlay.totalSong = listSongs.count
        audioPlay.isOnline = true
        audioPlay.setupAudio()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupObserverAudio"), object: nil)
    }
    
    func songDidReachEnd(){
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
        
        
        audioPlay.pathString = listSongs[index.row].sourceOnline
        audioPlay.titleSong = listSongs[index.row].title
        audioPlay.lyric = listSongs[index.row].lyric
        audioPlay.thumbnail = listSongs[index.row].thumbnail
        audioPlay.artist = listSongs[index.row].artistName
        audioPlay.setupAudio()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupObserverAudio"),object: nil)
    }
    
    func shufflingSongs() {
        //DeSelect Previous Cell
        let prevIndex = audioPlay.index
        myTableView.deselectRow(at: prevIndex, animated: true)
        
        //random Song
        let randomNumber = randomSong()
        audioPlay.index.row = randomNumber
        
        //Select Current Cell
        let index = audioPlay.index
        myTableView.selectRow(at: index, animated: true, scrollPosition: .middle)
        
        
        audioPlay.pathString = listSongs[index.row].sourceOnline
        audioPlay.titleSong = listSongs[index.row].title
        audioPlay.lyric = listSongs[index.row].lyric
        audioPlay.thumbnail = listSongs[index.row].thumbnail
        audioPlay.artist = listSongs[index.row].artistName
        audioPlay.setupAudio()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupObserverAudio"),object: nil)
    }
    
    func prevSong(){
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
        
        
        audioPlay.pathString = listSongs[index.row].sourceOnline
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
        let edit = UITableViewRowAction(style: .normal, title: "Download") { action, index in
            DispatchQueue.global(qos: .default).async(
                execute: {
                    self.downloadSong(index: indexPath.row)
            })
            self.myTableView.reloadData()
        }
        edit.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/255, alpha: 1.0)
        return [edit]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}


