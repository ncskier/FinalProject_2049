//
//  PuzzlesTableViewController.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 3/18/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

class PuzzlesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmentedControlView: UISegmentedControl!
    @IBOutlet weak var puzzlesTableView: UITableView!
    
    var token : NotificationToken?
    var savedPuzzles : Results<Puzzle>!
    var allPuzzles = [Puzzle]()
    var refreshControl = UIRefreshControl()
    var loadingFirebasePuzzles = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Segmented View
        
        
        // Table View
        puzzlesTableView.delegate = self
        puzzlesTableView.dataSource = self
        
        // Load Saved Puzzles
        do {
            let realm = try Realm()
            token = realm.addNotificationBlock({ (notification, realm) -> Void in
                self.puzzlesTableView.reloadData()
            })
            
            savedPuzzles = realm.objects(Puzzle)
            
        } catch {
            print("Error loading saved puzzles: \(error)")
            
            let errorAlertController = UIAlertController(title: "Error Loading Saved Puzzles", message: "\(error)", preferredStyle: .Alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            presentViewController(errorAlertController, animated: true, completion: nil)
        }
        
        // Load Firebase data
        loadFirebasePuzzles()
        
        // Refresh Control
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), forControlEvents: .ValueChanged)
        puzzlesTableView.addSubview(refreshControl)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Deselect Selected Row
        if (puzzlesTableView.indexPathForSelectedRow != nil) {
            puzzlesTableView.deselectRowAtIndexPath(puzzlesTableView.indexPathForSelectedRow!, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshControlPulled() {
        // Change title
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        
        if (segmentedControlView.selectedSegmentIndex == 0) {   // Saved Puzzles
            // Load Realm data
            
            refreshControl.endRefreshing()
            
        } else {    // Firebase Puzzles
            // Load firebase data
            loadFirebasePuzzles()
        }
    }
    
    func loadFirebasePuzzles() {
        // Update status
        loadingFirebasePuzzles = true
        
        // Firebase
        let fireBaseReference = Firebase(url: "https://shining-heat-3670.firebaseio.com/")
        let puzzlesReference = fireBaseReference.childByAppendingPath("puzzles")
        
        // Attach a closure to read the data at our posts reference
        puzzlesReference.observeEventType(
            //        puzzlesReference.queryLimitedToFirst(10).observeEventType(    // Get first 10 items
            .Value,
            withBlock: {(snapshot) in
                
                self.allPuzzles = [Puzzle]()
                
                for snapshotChild in snapshot.children {
                    var firebaseData = (snapshotChild as! FDataSnapshot).value as! [String : NSObject]
                    firebaseData["id"] = (snapshotChild as! FDataSnapshot).ref.key
                    let puzzle = Puzzle(fromFirebaseData: firebaseData)
                    self.allPuzzles.append(puzzle)
                }
                
                // Reload Table
                self.puzzlesTableView.reloadData()
                
                // End Refresh
                self.refreshControl.endRefreshing()
                self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
                self.loadingFirebasePuzzles = false
                
            }, withCancelBlock: {(error) in
                
                print("Error getting data from Firebase: \(error)")
                
                // Alert User of error
                let errorAlertController = UIAlertController(title: "Error Retrieving Puzzles", message: "There was an error with the database retrieving the puzzles.", preferredStyle: .Alert)
                let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                errorAlertController.addAction(dismissAlertAction)
                self.presentViewController(errorAlertController, animated: true, completion: nil)
        })
    }
    
    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
        
        // Refresh Data
        puzzlesTableView.reloadData()
        
        // Scroll to first cell
        var canScroll = true
        if (segmentedControlView.selectedSegmentIndex == 0) {   // Saved Puzzles
            if (savedPuzzles.count == 0) {
                canScroll = false
            }
            
            // Update Refreshing
            if (refreshControl.refreshing) {
                refreshControl.endRefreshing()
            }
            
        } else {    // All Puzzles
            if (allPuzzles.count == 0) {
                canScroll = false
            }
            
            // Update Refreshing
            if (refreshControl.refreshing) {
                refreshControl.endRefreshing()
            }
            if (loadingFirebasePuzzles) {
                refreshControl.beginRefreshing()
            }
        }
        
        if (canScroll) {
            puzzlesTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
        }
        
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (segmentedControlView.selectedSegmentIndex == 0) {   // Saved Puzzles
            return savedPuzzles.count
        } else {    // All Puzzles
            return allPuzzles.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("puzzleCell", forIndexPath: indexPath) as! PuzzleTableViewCell
        
        // Configure the cell...
        if (segmentedControlView.selectedSegmentIndex == 0) {   // Saved Puzzles
            cell.puzzle = savedPuzzles[indexPath.row]
        } else {    // All Puzzles
            cell.puzzle = allPuzzles[indexPath.row]
        }
        
        return cell
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return view.frame.width/4.0
//    }
    
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
