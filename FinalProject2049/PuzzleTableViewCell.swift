//
//  PuzzleTableViewCell.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 3/19/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import UIKit

class PuzzleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var numberAnswersLabel: UILabel!
    
    let detailImageView = UIImageView()
    var userVote: Int!
    
    var puzzle : Puzzle! {
        didSet(newValue) {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Add Detail Image View
        addSubview(detailImageView)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI() {
        let image = UIImage(data: puzzle.pictureData)
        detailImageView.frame = CGRect(x: 0, y: 0, width: frame.width/2.0, height: frame.width/2.0)
        detailImageView.center = CGPoint(x: frame.width/4.0, y: frame.height/2.0)
        detailImageView.image = image
        
        // Vote Buttons
        // Get Previous Vote
        let defaults = NSUserDefaults.standardUserDefaults()
        userVote = defaults.integerForKey(puzzle.id)
        
        if (userVote == 1) {    // Up Vote
            upVoteButton.setImage(UIImage(named: "upCarrot_selected"), forState: .Normal)
        }
        if (userVote == -1) {    // Down Vote
            downVoteButton.setImage(UIImage(named: "downCarrot_selected"), forState: .Normal)
        }
        
        // Vote Label
        
        
        // Number Answer Label
        
    }
    
    func updateVoteButtons() {
        // Update vote buttons base on userVote
        
        if (userVote == 1) {    // Up Vote
            upVoteButton.setImage(UIImage(named: "upCarrot_selected"), forState: .Normal)
            downVoteButton.setImage(UIImage(named: "downCarrot_deselected"), forState: .Normal)
            
        } else if (userVote == -1) {    // Down Vote
            upVoteButton.setImage(UIImage(named: "upCarrot_deselected"), forState: .Normal)
            downVoteButton.setImage(UIImage(named: "downCarrot_selected"), forState: .Normal)
        
        } else {    // No Vote
            upVoteButton.setImage(UIImage(named: "upCarrot_deselected"), forState: .Normal)
            downVoteButton.setImage(UIImage(named: "downCarrot_deselected"), forState: .Normal)
        }
    }
    
    @IBAction func upVoteButtonTapped(sender: UIButton) {
        if (userVote == 1) {    // Up Vote (Toggle)
            // Update User Vote
            userVote = 0
            
            // Update vote buttons
            updateVoteButtons()
            
        } else {    // No Up Vote
            // Update User Vote
            userVote = 1
            
            // Update vote buttons
            updateVoteButtons()
        }
        
        // Store userVote
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(userVote, forKey: puzzle.id)
        
        // Update Puzzle Data
        
        
    }

    @IBAction func downVoteButtonTapped(sender: UIButton) {
        if (userVote == -1) {    // Down Vote (Toggle)
            // Update User Vote
            userVote = 0
            
            // Update vote buttons
            updateVoteButtons()
            
        } else {    // No Down Vote
            // Update User Vote
            userVote = -1
            
            // Update vote buttons
            updateVoteButtons()
        }
        
        // Store userVote
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(userVote, forKey: puzzle.id)
        
        // Update Puzzle Data
        
    }
}
