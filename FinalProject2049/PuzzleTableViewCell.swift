//
//  PuzzleTableViewCell.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 3/19/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import UIKit

class PuzzleTableViewCell: UITableViewCell {

    @IBOutlet weak var detailImageView: UIImageView!
    
    var puzzle : Puzzle! {
        didSet(newValue) {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI() {
        let image = UIImage(data: puzzle.pictureData)
        imageView!.image = image
    }

}
