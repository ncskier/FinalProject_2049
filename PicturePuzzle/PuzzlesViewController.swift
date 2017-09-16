//
//  PuzzlesTableViewController.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 3/18/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import RealmSwift

class PuzzlesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var segmentedControlView: UISegmentedControl!
    @IBOutlet weak var puzzlesTableView: UITableView!
    
    var token : NotificationToken?
    var savedPuzzles : Results<Puzzle>!
    var allPuzzles = [Puzzle]()
    var refreshControl = UIRefreshControl()
    var loadingFirebasePuzzles = false
    var loadedFirebasePuzzles = false
    
    var locationManager : CLLocationManager!
    let deltaLocation : Double = 0.25            // +/- degrees for lat/lon of location'
    var minLatitude: Double!
    var maxLatitude: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table View
        puzzlesTableView.delegate = self
        puzzlesTableView.dataSource = self
        
        // Load Saved Puzzles
        do {
            let realm = try Realm()
            token = realm.addNotificationBlock({ (notification, realm) -> Void in
                self.puzzlesTableView.reloadData()
            })
            
            savedPuzzles = realm.objects(Puzzle.self)
            
        } catch {
            print("Error loading saved puzzles: \(error)")
            
            let errorAlertController = UIAlertController(title: "Error Loading Saved Puzzles", message: "\(error)", preferredStyle: .alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            present(errorAlertController, animated: true, completion: nil)
        }
        
        // Select proper segment
        if savedPuzzles.count == 0 {
            segmentedControlView.selectedSegmentIndex = 1
        }
        
        // Get current location
        setupLocationServices()
        
        // Load Firebase data
        //        loadFirebasePuzzles()
        
        // Refresh Control
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        puzzlesTableView.addSubview(refreshControl)
        
        refreshControl.beginRefreshing()
        refreshControlPulled()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Deselect Selected Row
        if (puzzlesTableView.indexPathForSelectedRow != nil) {
            puzzlesTableView.deselectRow(at: puzzlesTableView.indexPathForSelectedRow!, animated: true)
        }
        
        // Update table
        puzzlesTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupLocationServices() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if (authorizationStatus == .restricted) {
            
            // Show Error Alert
            let errorAlertController = UIAlertController(
                title: "Location Authorization Restricted",
                message: "This app will be unable to verify the correctness of puzzles without enabled location services.",
                preferredStyle: .alert
            )
            let dismissAlertAction = UIAlertAction(
                title: "Dismiss",
                style: .default,
                handler: nil
            )
            errorAlertController.addAction(dismissAlertAction)
            
        } else if (authorizationStatus == .denied) {
            
            // Show Error Alert
            let errorAlertController = UIAlertController(
                title: "Location Authorisation Denied",
                message: "This app will be unable to verify the correctness of puzzles without enabled location services.",
                preferredStyle: .alert
            )
            let dismissAlertAction = UIAlertAction(
                title: "Dismiss",
                style: .default,
                handler: nil
            )
            errorAlertController.addAction(dismissAlertAction)
            
        } else {
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.distanceFilter = 2000
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.startUpdatingLocation()
            
            if (authorizationStatus == .notDetermined) {
                locationManager!.requestWhenInUseAuthorization()    // handled later by Delegate
            } else {
                locationManager!.startUpdatingLocation()
            }
        }
    }
    
    func refreshControlPulled() {
        // Change title
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        
        loadedFirebasePuzzles = false
        
        if (CLLocationManager.authorizationStatus() == .notDetermined) {
            locationManager!.requestWhenInUseAuthorization()    // handled later by Delegate
        } else {
            locationManager!.startUpdatingLocation()
        }
        
        //        loadFirebasePuzzles()
    }
    
    /* Use user's location when loading puzzles (query lat/lon in a +/- range from user lat/lon) */
    func loadFirebasePuzzles() {
        print("load Firebase puzzles")
        
        // Update status
        loadingFirebasePuzzles = true
        
        // Get current location
        let location = locationManager.location
        locationManager.stopUpdatingLocation()
        
        if (location == nil) {
            /* error */
            print("ERROR: Could not retreive location")
            
            // Alert User of error
            let errorAlertController = UIAlertController(title: "Error Reading Location", message: "There was an error trying to get your location.", preferredStyle: .alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            self.present(errorAlertController, animated: true, completion: nil)
        }
        
        minLatitude = location!.coordinate.latitude - deltaLocation
        maxLatitude = location!.coordinate.latitude + deltaLocation
        let minLongitude = location!.coordinate.longitude - deltaLocation
        let maxLongitude = location!.coordinate.longitude + deltaLocation
        
        print("minLat: \(minLatitude)")
        print("maxLat: \(maxLatitude)")
        print("minLon: \(minLongitude)")
        print("maxLon: \(maxLongitude)")
        
        // Firebase
        let firebaseReference = Database.database().reference(withPath: "puzzles")
//        let puzzlesReference = firebaseReference.child("puzzles")
        
        // Attach a closure to read the data at our posts reference
        firebaseReference.observe(.value, with: { (snapshot) in
//        puzzlesReference.queryStarting(atValue: minLongitude, childKey: "longitude").queryEnding(atValue: maxLongitude, childKey: "longitude").observe(.value, with: { (snapshot) in
            
            // Initialize allPuzzles
            self.allPuzzles = [Puzzle]()
            
            print("childrenCount: \(snapshot.childrenCount)")
            
            for snapshotChild in snapshot.children {
                var firebaseData = (snapshotChild as! DataSnapshot).value as! [String:NSObject]
                
                // Filter Latitude
                let latitude = firebaseData["latitude"] as! Double
                if (self.minLatitude < latitude && latitude < self.maxLatitude) {
                    firebaseData["id"] = (snapshotChild as! DataSnapshot).ref.key as NSObject
                    
                    // Check if puzzle is already saved (by using id)
                    let savedPuzzle = self.savedPuzzles.filter( { $0.id == (firebaseData["id"] as! String) } ).first
                    if savedPuzzle != nil {
                        // Update saved puzzle to firebase data
                        savedPuzzle!.updateData(fromFirebaseData: firebaseData)
                        
                        self.allPuzzles.append(savedPuzzle!)
                    } else {
                        self.allPuzzles.append(Puzzle(fromFirebaseData: firebaseData))
                    }
                }
            }
            
            // Sort Puzzles
            self.sortPuzzles()
            
            // Reload Table
            self.puzzlesTableView.reloadData()
            
            // End Refresh
            self.refreshControl.endRefreshing()
            self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
            self.loadingFirebasePuzzles = false
            self.loadedFirebasePuzzles = true
            
        }) { (error) in
            print(error.localizedDescription)
            
            // Alert User of error
            let errorAlertController = UIAlertController(title: "Error Retrieving Puzzles", message: "There was an error with the database retrieving the puzzles.", preferredStyle: .alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            self.present(errorAlertController, animated: true, completion: nil)
        }
    }
    
    func sortPuzzles() {
        if (segmentedControlView.selectedSegmentIndex == 1) {           // New Puzzles
            // Sort By Timestamp Descending (id)
            self.allPuzzles.sort(by: { $0.id > $1.id })
        } else if (segmentedControlView.selectedSegmentIndex == 2) {    // Top Puzzles
            // Sort By Votes Descending
            self.allPuzzles.sort(by: { $0.votes > $1.votes })
        }
    }
    
    //    func updateSavedPuzzle(savedPuzzle: Puzzle, withFirebaseData firebaseData: [String : NSObject]) {
    //        do {
    //            let realm = try Realm()
    //
    //            try realm.write({
    //                savedPuzzle.votes = Int(String(firebaseData["votes"]!))!
    //                savedPuzzle.usersCorrect = Int(String(firebaseData["usersCorrect"]!))!
    //            })
    //        }
    //        catch {
    //            print("error updating saved puzzle from realm: \(error)")
    //
    //            let errorAlertController = UIAlertController(title: "Error Retreiving Puzzle", message: "\(error)", preferredStyle: .Alert)
    //            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
    //            errorAlertController.addAction(dismissAlertAction)
    //            self.presentViewController(errorAlertController, animated: true, completion: nil)
    //        }
    //    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        
        // Sort Puzzles
        sortPuzzles()
        
        // Refresh Table
        puzzlesTableView.reloadData()
        
        // Scroll to first cell
        //        var canScroll = true
        //        if (segmentedControlView.selectedSegmentIndex == 0) {   // Saved Puzzles
        ////            if (savedPuzzles.count == 0) {
        ////                canScroll = false
        ////            }
        //
        //            // Update Refreshing
        //            if (refreshControl.refreshing) {
        //                refreshControl.endRefreshing()
        //            }
        //
        //        } else {    // All Puzzles
        //            if (allPuzzles.count == 0) {
        //                canScroll = false
        //            }
        //
        //            // Update Refreshing
        //            if (refreshControl.refreshing) {
        //                refreshControl.endRefreshing()
        //            }
        //            if (loadingFirebasePuzzles) {
        //                refreshControl.beginRefreshing()
        //            }
        //        }
        //
        //        if (canScroll) {
        //            puzzlesTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
        //        }
        
    }
    
    // MARK: - CLLocation Manager Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocation")
        if (!loadedFirebasePuzzles && !loadingFirebasePuzzles) {
            loadFirebasePuzzles()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error: \(error.localizedDescription)")
        
        // Show Error Alert
        let errorAlertController = UIAlertController(
            title: "Location Services Error",
            message: "\(error.localizedDescription)",
            preferredStyle: .alert
        )
        let dismissAlertAction = UIAlertAction(
            title: "Dismiss",
            style: .default,
            handler: nil
        )
        errorAlertController.addAction(dismissAlertAction)
        
        present(errorAlertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if (status == .authorizedWhenInUse) {
            locationManager!.startUpdatingLocation()
        }
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("location manager PAUSED")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("location manager RESUMED")
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (segmentedControlView.selectedSegmentIndex == 0) {       // Saved Puzzles
            return savedPuzzles.count
        } else {                                                    // Regular Firebase Puzzles
            return allPuzzles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "puzzleCell", for: indexPath) as! PuzzleTableViewCell
        
        if (segmentedControlView.selectedSegmentIndex == 0) {          // Saved Puzzles
            cell.puzzle = savedPuzzles[(indexPath as NSIndexPath).row]
        } else {                                                    // Regular Firebase Puzzles
            cell.puzzle = allPuzzles[(indexPath as NSIndexPath).row]
        }
        cell.updateUI()
        
        return cell
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        let destinationViewController = segue.destination as! PuzzleDetailViewController
        
        // Pass the selected object to the new view controller.
        let cell = sender as! PuzzleTableViewCell
        destinationViewController.puzzle = cell.puzzle
    }
    
}
