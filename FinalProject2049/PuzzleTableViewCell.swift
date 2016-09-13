//
//  PuzzleTableViewCell.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 3/19/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

class PuzzleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var usersCorrectLabel: UILabel!      // SOLVED
    
    var solvedImageView = UIImageView()
    let detailImageView = UIImageView()
    var userVote : Int!
    
    var puzzle : Puzzle!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Add Detail Image View
        addSubview(detailImageView)
        
        // Add Solved Image View
        addSubview(solvedImageView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI() {
        print("update UI \(puzzle.id)")
        
        let image = UIImage(data: puzzle.pictureData as Data)
        detailImageView.frame = CGRect(x: 0, y: 0, width: frame.width/2.0, height: frame.width/2.0)
        detailImageView.center = CGPoint(x: frame.width/4.0, y: frame.height/2.0)
        detailImageView.image = image
        
        // Vote Buttons
        // Get Previous Vote
        let defaults = UserDefaults.standard
        userVote = defaults.integer(forKey: puzzle.id + ".userVote")
        
        if (userVote == 1) {    // Up Vote
            upVoteButton.setImage(UIImage(named: "upCarrot_selected"), for: UIControlState())
            downVoteButton.setImage(UIImage(named: "downCarrot_deselected"), for: UIControlState())
        }
        if (userVote == -1) {    // Down Vote
            upVoteButton.setImage(UIImage(named: "upCarrot_deselected"), for: UIControlState())
            downVoteButton.setImage(UIImage(named: "downCarrot_selected"), for: UIControlState())
        }
        
        // Vote Label
        votesLabel.text = "\(puzzle.votes)"
        
        // Number Answer Label
        usersCorrectLabel.text = "\(puzzle.usersCorrect)"
        
        // Update Votes Info
        updateVoteButtons()
        updateVotesLabel()
        
        // Solved Image
        solvedImageView.image = UIImage(named: "green_checkmark")
        let length = self.frame.height - 35
        solvedImageView.frame = CGRect(x: 0, y: 0, width: length, height: length)
        solvedImageView.center = detailImageView.center
        solvedImageView.isHidden = true
        solvedImageView.alpha = 0.75
        bringSubview(toFront: solvedImageView)
        
        // Get Solved
        let solved = defaults.bool(forKey: puzzle.id + ".solved")
        if (solved) {
            print("\t \(puzzle.id) solved")
            bringSubview(toFront: solvedImageView)
            solvedImageView.isHidden = false
        }
    }
    
    func updateVotesLabel() {
        votesLabel.text = "\(puzzle.votes)"
    }
    
    func updateVoteButtons() {
        // Update vote buttons base on userVote
        
        if (userVote == 1) {    // Up Vote
            upVoteButton.setImage(UIImage(named: "upCarrot_selected"), for: UIControlState())
            downVoteButton.setImage(UIImage(named: "downCarrot_deselected"), for: UIControlState())
            
        } else if (userVote == -1) {    // Down Vote
            upVoteButton.setImage(UIImage(named: "upCarrot_deselected"), for: UIControlState())
            downVoteButton.setImage(UIImage(named: "downCarrot_selected"), for: UIControlState())
        
        } else {    // No Vote
            upVoteButton.setImage(UIImage(named: "upCarrot_deselected"), for: UIControlState())
            downVoteButton.setImage(UIImage(named: "downCarrot_deselected"), for: UIControlState())
        }
    }
    
    func incrementRealmPuzzleVotesBy(_ votes: Int) {
        do {
            let realm = try Realm()
            
            try realm.write({
                puzzle.votes += votes
            })
        }
        catch {
            print("error updating puzzle votes: \(error)")
            
            let errorAlertController = UIAlertController(title: "Error Updating Puzzle Votes", message: "\(error)", preferredStyle: .alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(errorAlertController, animated: true, completion: nil)
        }
    }
    
    func updatePuzzleFirebaseData() {
        let firebaseReference = Firebase(url: "https://shining-heat-3670.firebaseio.com/")
        let puzzlesReferece = firebaseReference?.child(byAppendingPath: "puzzles")
        let puzzleReference = puzzlesReferece?.child(byAppendingPath: puzzle.id)
        let puzzleVotesReference = puzzleReference?.child(byAppendingPath: "votes")
        puzzleVotesReference?.setValue(puzzle.votes, withCompletionBlock: {(error, firebaseRef) in
            
            if (error != nil) {
                print("Error saving to firebase: \(error)")
                
                // Alert User of error
                let errorAlertController = UIAlertController(title: "Error Updating Puzzle Votes", message: "\(error)", preferredStyle: .alert)
                let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                errorAlertController.addAction(dismissAlertAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(errorAlertController, animated: true, completion: nil)
            } else {
                print("Succesfully saved votes to Firebase")
            }
        })
    }
    
    func incrementPuzzleVotesBy(_ votes: Int) {
        // Update Vote Text
        votesLabel.text = "\(Int(votesLabel.text!)! + votes)"
        
        let firebaseReference = Firebase(url: "https://shining-heat-3670.firebaseio.com/")
        let puzzlesReferece = firebaseReference?.child(byAppendingPath: "puzzles")
        let puzzleReference = puzzlesReferece?.child(byAppendingPath: puzzle.id)
        let puzzleVotesReference = puzzleReference?.child(byAppendingPath: "votes")
        
        // Retrieve Puzzle Votes from Firebase
        puzzleVotesReference?.observeSingleEvent(of: .value, with: { snapshot in
            print("snapshot.value: \(snapshot?.value)")
            
            // Update Realm Puzzle Object
            do {
                let realm = try Realm()
                
                try realm.write({
                    self.puzzle.votes = (snapshot.value as! Int) + votes
                })
            }
            catch {
                print("error updating puzzle votes: \(error)")
                
                let errorAlertController = UIAlertController(title: "Error Updating Puzzle Votes", message: "\(error)", preferredStyle: .alert)
                let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                errorAlertController.addAction(dismissAlertAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(errorAlertController, animated: true, completion: nil)
            }
            
            // Update Firebase Data
            self.updatePuzzleFirebaseData()
            
            // Update Votes Label
            self.updateVotesLabel()
        })
    }
    
    @IBAction func upVoteButtonTapped(_ sender: UIButton) {
        if (userVote == 1) {    // Up Vote (Toggle)
            // Update User Vote
            userVote = 0
            
            // Update vote buttons
            updateVoteButtons()
            
            // Update Puzzle Data
            incrementPuzzleVotesBy(-1)
            
        } else if (userVote == 0) {    // No Vote
            // Update User Vote
            userVote = 1
            
            // Update vote buttons
            updateVoteButtons()
            
            // Update Puzzle Data
            incrementPuzzleVotesBy(1)
            
        } else {    // Down Vote
            // Update User Vote
            userVote = 1
            
            // Update vote buttons
            updateVoteButtons()
            
            // Update Puzzle Data
            incrementPuzzleVotesBy(2)
        }
        
        // Store userVote
        let defaults = UserDefaults.standard
        defaults.set(userVote, forKey: puzzle.id + ".userVote")
        defaults.synchronize()
    }

    @IBAction func downVoteButtonTapped(_ sender: UIButton) {
        if (userVote == -1) {    // Down Vote (Toggle)
            // Update User Vote
            userVote = 0
            
            // Update vote buttons
            updateVoteButtons()
            
            // Update Puzzle Data
            incrementPuzzleVotesBy(1)
            
        } else if (userVote == 0) {    // No Vote
            // Update User Vote
            userVote = -1
            
            // Update vote buttons
            updateVoteButtons()
            
            // Update Puzzle Data
            incrementPuzzleVotesBy(-1)
            
        } else {    // Up Vote
            // Update User Vote
            userVote = -1
            
            // Update vote buttons
            updateVoteButtons()
            
            // Update Puzzle Data
            incrementPuzzleVotesBy(-2)
        }
        
        // Store userVote
        let defaults = UserDefaults.standard
        defaults.set(userVote, forKey: puzzle.id + ".userVote")
        defaults.synchronize()
    }
}
