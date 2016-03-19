//
//  Models.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 3/18/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

class Puzzle: Object {
    dynamic var id = NSUUID().UUIDString        // create unique id

    dynamic var pictureData : NSData!
    
    dynamic var latitude : Double = 0
    dynamic var longitude : Double = 0
    dynamic var horizontalAccuracy : Double = 0
    
    dynamic var tag = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}