//
//  SongTableCell.swift
//  Sport
//
//  Created by Tien on 5/28/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class SongTableCell: UITableViewCell {

    @IBOutlet weak var albumIconImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songAlbumLabel: UILabel!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet weak var happinessLabel: UILabel!
    @IBOutlet weak var emotionImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func displaySong(_ song: SongViewData) {
        songTitleLabel.text = song.title
        songAlbumLabel.text = song.artist
        tempoLabel.text = "\(Int(song.tempo)) bpm"
        albumIconImageView.image = song.image
        energyLabel.text = String.init(format: "%.f%%", song.energy)
        happinessLabel.text = String.init(format: "%f", song.happiness)
    }
}
