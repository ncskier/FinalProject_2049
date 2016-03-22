//
//  PuzzlesTableViewController.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 3/18/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import UIKit
import Firebase

class PuzzlesTableViewController: UITableViewController {
    
    var puzzles = [Puzzle]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fireBaseReference = Firebase(url: "https://shining-heat-3670.firebaseio.com/")
        let puzzlesReference = fireBaseReference.childByAppendingPath("puzzles")
        
        // Attach a closure to read the data at our posts reference
        puzzlesReference.observeEventType(.Value, withBlock: {(snapshot) in
            
            self.puzzles = [Puzzle]()
            
            for snapshotChild in snapshot.children {
                let firebaseData = (snapshotChild as! FDataSnapshot).value as! [String : NSObject]
                let puzzle = Puzzle(fromFirebaseData: firebaseData)
                self.puzzles.append(puzzle)
            }
            
            print("reload")
            print("puzzles: \(self.puzzles)")
            self.tableView.reloadData()
            
        }, withCancelBlock: {(error) in
            
            print("Error getting data from Firebase: \(error)")
            
            // Alert User of error
            let errorAlertController = UIAlertController(title: "Error Retrieving Puzzles", message: "There was an error with the database retrieving the puzzles.", preferredStyle: .Alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            self.presentViewController(errorAlertController, animated: true, completion: nil)
        })
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return puzzles.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("puzzleCell", forIndexPath: indexPath) as! PuzzleTableViewCell

        // Configure the cell...
        cell.puzzle = puzzles[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return view.frame.width/4.0
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        let destinationViewController = segue.destinationViewController as! PuzzleDetailViewController
        
        // Pass the selected object to the new view controller.
        let cell = sender as! PuzzleTableViewCell
        destinationViewController.puzzle = cell.puzzle
    }
    
}
