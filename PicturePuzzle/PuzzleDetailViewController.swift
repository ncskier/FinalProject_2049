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
    @IBOutlet weak var saveButton: UIButton!
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
            puzzleImageView.image = UIImage(data: puzzle.pictureData as Data)
            
            // Puzzle Saved
            let defaults = UserDefaults.standard
            let puzzleSaved = defaults.bool(forKey: puzzle.id + ".saved")
            if (puzzleSaved) {
                saveButton.isEnabled = false
            }
            
            // Get user vote
            userVote = defaults.integer(forKey: puzzle.id + ".userVote")
            if (userVote == 1) {    // Up Vote
                upVoteButton.setImage(UIImage(named: "upCarrot_selected"), for: UIControlState())
            }
            if (userVote == -1) {    // Down Vote
                downVoteButton.setImage(UIImage(named: "downCarrot_selected"), for: UIControlState())
            }
            
            // Vote Label
            votesLabel.text = "\(puzzle.votes)"
            
            // Users Correct Label
            usersCorrectLabel.text = "\(puzzle.usersCorrect)"
            
            // Title/Tag
            title = puzzle.tag
            
        } else {
            print("Error: Puzzle object is nil")
            let errorAlertController = UIAlertController(title: "Error Loading Puzzle Data", message: "Sorry, there was an error loading the puzzle.", preferredStyle: .alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            present(errorAlertController, animated: true, completion: nil)
            
            // Dismiss Puzzle Detail View
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        let defaults = UserDefaults.standard
        let solved = defaults.bool(forKey: puzzle.id + ".solved")
        
        if (solved) {
            // Deactivate and Hide Solve Button
            solveButton.isEnabled = false
            solveButton.isHidden = true
            
            // Show solved label
            solvedLabel.isHidden = false
            
            
        } else {
            // Hide solved label
            solvedLabel.isHidden = true
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        //        print("title text: \(saveButton.titleLabel!.text)")
        
        print("Saved")
        
        // Save Puzzle
        do {
            let realm = try Realm()
            
            try realm.write({
                realm.add(puzzle)
            })
        }
        catch {
            print("Error saving puzzle: \(error)")
            
            let errorAlertController = UIAlertController(title: "Error Saving Puzzle", message: "\(error)", preferredStyle: .alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            present(errorAlertController, animated: true, completion: nil)
        }
        
        // Set Puzzle Saved to defaults
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: puzzle.id + ".saved")
        defaults.synchronize()
        
        // Change Save Button
        saveButton.isEnabled = false
        
        //        print("Remove")
        //
        //        // Remove Puzzle
        //        do {
        //            let realm = try Realm()
        //
        //            try realm.write({
        //                realm.delete(puzzle)
        //            })
        //        }
        //        catch {
        //            print("error deleting puzzle: \(error)")
        //
        //            let errorAlertController = UIAlertController(title: "Error Removing Puzzle", message: "\(error)", preferredStyle: .Alert)
        //            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        //            errorAlertController.addAction(dismissAlertAction)
        //            presentViewController(errorAlertController, animated: true, completion: nil)
        //        }
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
        
        // Update Firebase Data
        //        updatePuzzleFirebaseData()
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
        
        // Update Firebase Data
        //        updatePuzzleFirebaseData()
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
    
    func incrementPuzzleVotesBy(_ votes: Int) {
        // Update Vote Text
        votesLabel.text = "\(Int(votesLabel.text!)! + votes)"
        
        let firebaseReference = Database.database().reference()
        let puzzlesReferece = firebaseReference.child("puzzles")
        let puzzleReference = puzzlesReferece.child(puzzle.id)
        let puzzleVotesReference = puzzleReference.child("votes")
        
        // Retrieve Puzzle Votes from Firebase
        puzzleVotesReference.observeSingleEvent(of: .value, with: { snapshot in
            print("snapshot.value: \(String(describing: snapshot.value))")
            
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
            self.present(errorAlertController, animated: true, completion: nil)
        }
    }
    
    func updatePuzzleFirebaseData() {
        let firebaseReference = Database.database().reference()
        let puzzlesReferece = firebaseReference.child("puzzles")
        let puzzleReference = puzzlesReferece.child(puzzle.id)
        let puzzleVotesReference = puzzleReference.child("votes")
        puzzleVotesReference.setValue(puzzle.votes, withCompletionBlock: {(error, firebaseRef) in
            
            if (error != nil) {
                print("Error saving to firebase: \(String(describing: error))")
                
                // Alert User of error
                let errorAlertController = UIAlertController(title: "Error Updating Puzzle Votes", message: "\(String(describing: error))", preferredStyle: .alert)
                let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                errorAlertController.addAction(dismissAlertAction)
                self.present(errorAlertController, animated: true, completion: nil)
            } else {
                print("Succesfully saved votes to Firebase")
            }
        })
    }
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "solvePuzzleSegue") {
            // Get the new view controller using segue.destinationViewController.
            let destinationViewController = segue.destination as! SolvePuzzleViewController
            
            // Pass the selected object to the new view controller.
            destinationViewController.puzzle = puzzle
        }
        
    }
    
    
}
