//
//  PuzzleDetailViewController.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 3/19/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import UIKit
import RealmSwift

class PuzzleDetailViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var puzzleImageView: UIImageView!
    
    var puzzle : Puzzle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if (puzzle != nil) {
            puzzleImageView.image = UIImage(data: puzzle.pictureData)
        } else {
            print("Error: Puzzle object is nil")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTapped(sender: UIButton) {
        
        print("title text: \(saveButton.titleLabel!.text)")
        
        if saveButton.titleLabel!.text == "Save" {
            
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
                
                let errorAlertController = UIAlertController(title: "Error Saving Puzzle", message: "\(error)", preferredStyle: .Alert)
                let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                errorAlertController.addAction(dismissAlertAction)
                presentViewController(errorAlertController, animated: true, completion: nil)
            }
            
            
        } else {
            
            print("Remove")
            
            // Remove Puzzle
            do {
                let realm = try Realm()
                
                try realm.write({
                    realm.delete(puzzle)
                })
            }
            catch {
                print("error deleting puzzle: \(error)")
                
                let errorAlertController = UIAlertController(title: "Error Removing Puzzle", message: "\(error)", preferredStyle: .Alert)
                let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                errorAlertController.addAction(dismissAlertAction)
                presentViewController(errorAlertController, animated: true, completion: nil)
            }
            
        }
        
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
