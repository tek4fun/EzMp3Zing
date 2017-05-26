//
//  DetailCellVC.swift
//  EzMp3Zing
//
//  Created by iOS Student on 2/14/17.
//  Copyright © 2017 tek4fun. All rights reserved.
//


import UIKit

class DetailCellVC: UITableViewCell {

    @IBOutlet weak var lb_Artist: UILabel!
    @IBOutlet weak var lb_Title: UILabel!
    @IBOutlet weak var img_Thumbnail: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
