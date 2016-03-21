//
//  PuzzleTableViewCell.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 3/19/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import UIKit

class PuzzleTableViewCell: UITableViewCell {

    let detailImageView = UIImageView()
    
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
        detailImageView.frame = CGRect(x: 0, y: 0, width: frame.width/2.0, height: frame.width/2.0)
        detailImageView.center = CGPoint(x: detailImageView.frame.width/2.0, y: frame.height/2.0)
        detailImageView.image = image
        addSubview(detailImageView)
        
    }

}
