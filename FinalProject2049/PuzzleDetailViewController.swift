//
//  PuzzleDetailViewController.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 3/19/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class PuzzleDetailViewController: UIViewController {
    
    @IBOutlet weak var solveButton: UIButton!
//    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var puzzleImageView: UIImageView!
    @IBOutlet weak var solvedLabel: UILabel!
    
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var usersCorrectLabel: UILabel!
    
    var userVote : Int!
    var puzzle : Puzzle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if (puzzle != nil) {
            puzzleImageView.image = UIImage(data: puzzle.pictureData)
            
            // Puzzle Saved
            let defaults = NSUserDefaults.standardUserDefaults()
//            let puzzleSaved = defaults.boolForKey(puzzle.id + ".saved")
//            if (puzzleSaved) {
//                saveButton.enabled = false
//            }
            
            // Get user vote
            userVote = defaults.integerForKey(puzzle.id + ".userVote")
            if (userVote == 1) {    // Up Vote
                upVoteButton.setImage(UIImage(named: "upCarrot_selected"), forState: .Normal)
            }
            if (userVote == -1) {    // Down Vote
                downVoteButton.setImage(UIImage(named: "downCarrot_selected"), forState: .Normal)
            }
            
            // Vote Label
            votesLabel.text = "\(puzzle.votes)"
            
            // Users Correct Label
            usersCorrectLabel.text = "\(puzzle.usersCorrect)"
            
            // Title/Tag
            title = puzzle.tag
            
        } else {
            print("Error: Puzzle object is nil")
            let errorAlertController = UIAlertController(title: "Error Loading Puzzle Data", message: "Sorry, there was an error loading the puzzle.", preferredStyle: .Alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            presentViewController(errorAlertController, animated: true, completion: nil)
            
            // Dismiss Puzzle Detail View
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        updateSolveButton()
        
        // Users Correct Label
        usersCorrectLabel.text = "\(puzzle.usersCorrect)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSolveButton() {
        // Retreive if user has answered Puzzle
        let defaults = NSUserDefaults.standardUserDefaults()
        let answeredCorrectly = defaults.boolForKey(puzzle.id + ".answeredCorrectly")
        
        if (answeredCorrectly) {
            // Deactivate and Hide Solve Button
            solveButton.enabled = false
            solveButton.hidden = true
            
            // Show solved label
            solvedLabel.hidden = false
            
            
        } else {
            // Hide solved label
            solvedLabel.hidden = true
        }
    }
    
//    @IBAction func saveButtonTapped(sender: UIButton) {
//        
////        print("title text: \(saveButton.titleLabel!.text)")
//        
//        print("Saved")
//        
//        // Save Puzzle
//        do {
//            let realm = try Realm()
//            
//            try realm.write({
//                realm.add(puzzle)
//            })
//        }
//        catch {
//            print("Error saving puzzle: \(error)")
//            
//            let errorAlertController = UIAlertController(title: "Error Saving Puzzle", message: "\(error)", preferredStyle: .Alert)
//            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
//            errorAlertController.addAction(dismissAlertAction)
//            presentViewController(errorAlertController, animated: true, completion: nil)
//        }
//        
//        // Set Puzzle Saved to defaults
//        let defaults = NSUserDefaults.standardUserDefaults()
//        defaults.setBool(true, forKey: puzzle.id + ".saved")
//        defaults.synchronize()
//        
//        // Change Save Button
////        saveButton.enabled = false
//        
////        print("Remove")
////        
////        // Remove Puzzle
////        do {
////            let realm = try Realm()
////            
////            try realm.write({
////                realm.delete(puzzle)
////            })
////        }
////        catch {
////            print("error deleting puzzle: \(error)")
////            
////            let errorAlertController = UIAlertController(title: "Error Removing Puzzle", message: "\(error)", preferredStyle: .Alert)
////            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
////            errorAlertController.addAction(dismissAlertAction)
////            presentViewController(errorAlertController, animated: true, completion: nil)
////        }
//    }
    
    @IBAction func upVoteButtonTapped(sender: UIButton) {
        if (userVote == 1) {    // Up Vote (Toggle)
            // Update User Vote
            userVote = 0
            
            // Update vote buttons
            updateVoteButtons()
            
            // Update Puzzle Data
            incrementRealmPuzzleVotesBy(-1)
            
        } else if (userVote == 0) {    // No Vote
            // Update User Vote
            userVote = 1
            
            // Update vote buttons
            updateVoteButtons()
            
            // Update Puzzle Data
            incrementRealmPuzzleVotesBy(1)
            
        } else {    // Down Vote
            // Update User Vote
            userVote = 1
            
            // Update vote buttons
            updateVoteButtons()
            
            // Update Puzzle Data
            incrementRealmPuzzleVotesBy(2)
        }
        
        // Update Votes Label
        updateVotesLabel()
        
        // Store userVote
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(userVote, forKey: puzzle.id + ".userVote")
        defaults.synchronize()
        
        // Update Firebase Data
        updatePuzzleFirebaseData()
    }
    
    @IBAction func downVoteButtonTapped(sender: UIButton) {
        if (userVote == -1) {    // Down Vote (Toggle)
            // Update User Vote
            userVote = 0
            
            // Update vote buttons
            updateVoteButtons()
            
            // Update Puzzle Data
            incrementRealmPuzzleVotesBy(1)
            
        } else if (userVote == 0) {    // No Vote
            // Update User Vote
            userVote = -1
            
            // Update vote buttons
            updateVoteButtons()
            
            // Update Puzzle Data
            incrementRealmPuzzleVotesBy(-1)
            
        } else {    // Up Vote
            // Update User Vote
            userVote = -1
            
            // Update vote buttons
            updateVoteButtons()
            
            // Update Puzzle Data
            incrementRealmPuzzleVotesBy(-2)
        }
        
        // Update Vote Label
        updateVotesLabel()
        
        // Store userVote
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(userVote, forKey: puzzle.id + ".userVote")
        defaults.synchronize()
        
        // Update Firebase Data
        updatePuzzleFirebaseData()
    }
    
    
    func updateVotesLabel() {
        votesLabel.text = "\(puzzle.votes)"
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
    
    func incrementRealmPuzzleVotesBy(votes: Int) {
        do {
            let realm = try Realm()
            
            try realm.write({
                puzzle.votes += votes
            })
        }
        catch {
            print("error updating puzzle votes: \(error)")
            
            let errorAlertController = UIAlertController(title: "Error Updating Puzzle Votes", message: "\(error)", preferredStyle: .Alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            self.presentViewController(errorAlertController, animated: true, completion: nil)
        }
    }
    
    func updatePuzzleFirebaseData() {
        let firebaseReference = Firebase(url: "https://shining-heat-3670.firebaseio.com/")
        let puzzlesReferece = firebaseReference.childByAppendingPath("puzzles")
        let puzzleReference = puzzlesReferece.childByAppendingPath(puzzle.id)
        let puzzleVotesReference = puzzleReference.childByAppendingPath("votes")
        puzzleVotesReference.setValue(puzzle.votes, withCompletionBlock: {(error, firebaseRef) in
            
            if (error != nil) {
                print("Error saving to firebase: \(error)")
                
                // Alert User of error
                let errorAlertController = UIAlertController(title: "Error Updating Puzzle Votes", message: "\(error)", preferredStyle: .Alert)
                let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                errorAlertController.addAction(dismissAlertAction)
                self.presentViewController(errorAlertController, animated: true, completion: nil)
            } else {
                print("Succesfully saved votes to Firebase")
            }
        })
    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "solvePuzzleSegue") {
            // Get the new view controller using segue.destinationViewController.
            let destinationViewController = segue.destinationViewController as! SolvePuzzleViewController
            
            // Pass the selected object to the new view controller.
            destinationViewController.puzzle = puzzle
        }
        
    }
    

}
