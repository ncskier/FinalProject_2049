//
//  Models.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 4/5/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import Foundation
import RealmSwift

class Puzzle: Object {
    
    dynamic var id : String = ""
    
    dynamic var pictureData : NSData!
    
    dynamic var longitude : Double = 0
    dynamic var latitude : Double = 0
    dynamic var horizontalAccuracy : Double = 10
    
    dynamic var tag : String = ""
    dynamic var votes : Int = 0
    dynamic var usersCorrect : Int = 0
    
    override var description : String {
        return "id: \(id)\n(\(latitude), \(longitude))\nHorizontal Accuracy: \(horizontalAccuracy)\ntag: \(tag)\nvotes: \(votes)\nusersCorrect: \(usersCorrect)"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
    convenience init(withPictureData pictureData: NSData, latitude: Double, longitude: Double, horizontalAccuracy: Double, tag: String) {
        self.init()
        
        self.pictureData = pictureData
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracy = horizontalAccuracy
        self.tag = tag
    }
    
    convenience init(fromFirebaseData firebaseData: [String : NSObject]) {
        self.init()
        
        id = firebaseData["id"] as! String
        
        pictureData = NSData(base64EncodedString: firebaseData["pictureData"] as! String, options: [])
        
        longitude = firebaseData["longitude"] as! Double
        latitude = firebaseData["latitude"] as! Double
        horizontalAccuracy = firebaseData["horizontalAccuracy"] as! Double
        
        tag = firebaseData["tag"] as! String
        
        votes = Int(String(firebaseData["votes"]!))!
        usersCorrect = Int(String(firebaseData["usersCorrect"]!))!
        
    }
    
    func convertToFirebaseData() -> [String : NSObject] {
        var dataDictionary = [String : NSObject]()
        
        dataDictionary["pictureData"] = "\(pictureData.base64EncodedStringWithOptions([]))"
        
        dataDictionary["longitude"] = longitude
        dataDictionary["latitude"] = latitude
        dataDictionary["horizontalAccuracy"] = horizontalAccuracy
        dataDictionary["tag"] = tag
        dataDictionary["votes"] = votes
        dataDictionary["usersCorrect"] = usersCorrect
        
        return dataDictionary
    }
    
    func updateData(fromFirebaseData firebaseData: [String : NSObject]) {
        
        // Connect to Realm
        var realm : Realm?
        do {
            realm = try Realm()
        } catch {
            print("Error Connecting to Realm: \(error)")
            
            let errorAlertController = UIAlertController(title: "Error Connecting to Realm", message: "\(error)", preferredStyle: .Alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(errorAlertController, animated: true, completion: nil)
        }
        
        // Update Saved Puzzle Object
        do {
            if (realm != nil) {
                try realm!.write( {
                    votes = Int(String(firebaseData["votes"]!))!
                    usersCorrect = Int(String(firebaseData["usersCorrect"]!))!
                })
            }
        } catch {
            print("Error updating saved puzzles: \(error)")
            
            let errorAlertController = UIAlertController(title: "Error Updating Saved Puzzles", message: "\(error)", preferredStyle: .Alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(errorAlertController, animated: true, completion: nil)
        }
    }
    
}
