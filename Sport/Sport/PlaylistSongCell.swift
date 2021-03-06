//
//  PlaylistSongCell.swift
//  Sport
//
//  Created by Tien on 6/5/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class PlaylistSongCell: UITableViewCell {

    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var playingIndicatorImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var selectedIndicatorView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func displaySongInfo(_ title: String, album: String, image: UIImage, playing: Bool) {
        albumImageView.image = image
        playingIndicatorImageView.isHidden = !playing
        titleLabel.text = title
        albumLabel.text = album
    }
    
    func displaySongInfo(_ songInfo: SongViewData) {
        albumImageView.image = songInfo.image
        playingIndicatorImageView.isHidden = !songInfo.isPlaying
        selectedIndicatorView.isHidden = !songInfo.isPlaying
        titleLabel.text = songInfo.title
        albumLabel.text = songInfo.artist
        let f = songInfo.tempo
        let s = NSString(format: "%.0f", f)
        bpmLabel.text = "\(s) bpm"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        //selectedIndicatorView.hidden = !selected
    }

}
