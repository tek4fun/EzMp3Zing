//
//  Song.swift
//  EzMp3Zing
//
//  Created by iOS Student on 2/13/17.
//  Copyright © 2017 tek4fun. All rights reserved.
//

import UIKit

struct Song {
    var title = ""
    var artistName = ""
    var thumbnail = #imageLiteral(resourceName: "music-player")
    var sourceOnline = ""
    var sourceLocal = ""
    var localThumbnail = ""
    let baseThumbnail = "http://image.mp3.zdn.vn//thumb/240_240/"
    var lyric = ""
    init (title: String, artistName: String, thumbnail: String, source: String, lyric: String)
    {
        self.title = title
        self.artistName = artistName
        let thumbnailURL = baseThumbnail+thumbnail
        var dataImage = try? Data(contentsOf: URL(string: thumbnailURL)!)
        self.sourceOnline = source
        self.lyric = lyric
        DispatchQueue.main.async {
            dataImage = try? Data(contentsOf: URL(string: thumbnailURL)!)
        }
        if dataImage != nil {
            self.thumbnail = UIImage(data: dataImage!)!
        }
    }
    
    init(title: String, artistName: String, localThumbnail: String, localSource: String, lyric: String){
        self.title = title
        self.artistName = artistName
        self.localThumbnail = localThumbnail
        let dataImage = try? Data(contentsOf: URL(fileURLWithPath: self.localThumbnail))
        self.thumbnail = UIImage(data:dataImage!)!
        self.sourceLocal = localSource
        self.lyric = lyric
    }
}
