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
    
    dynamic var tags : String = ""
    
    override var description : String {
        return "(\(latitude), \(longitude))\nHorizontal Accuracy: \(horizontalAccuracy)\ntags: \(tags)"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
    convenience init(withPictureData pictureData: NSData, latitude: Double, longitude: Double, horizontalAccuracy: Double, tags: String) {
        self.init()
        
        self.pictureData = pictureData
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracy = horizontalAccuracy
        self.tags = tags
    }
    
    convenience init(fromFirebaseData firebaseData: [String : NSObject]) {
        self.init()
        
        id = firebaseData["id"] as! String
        
        pictureData = NSData(base64EncodedString: firebaseData["pictureData"] as! String, options: [])
        
        longitude = Double(firebaseData["longitude"] as! String)!
        latitude = Double(firebaseData["latitude"] as! String)!
        horizontalAccuracy = Double(firebaseData["horizontalAccuracy"] as! String)!
        
        tags = firebaseData["tags"] as! String
    }
    
    func convertToFirebaseData() -> [String : String] {
        var dataDictionary = [String : String]()
        
        
        dataDictionary["pictureData"] = "\(pictureData.base64EncodedStringWithOptions([]))"
        
        dataDictionary["longitude"] = "\(longitude)"
        dataDictionary["latitude"] = "\(latitude)"
        dataDictionary["horizontalAccuracy"] = "\(horizontalAccuracy)"
        dataDictionary["tags"] = tags
        
        return dataDictionary
    }
    
}
