//
//  Measure.swift
//  HeartRate
//
//  Created by Ирина Савчик on 9.06.21.
//

import RealmSwift

class Measure: Object {
    @objc dynamic var dateAndTime: Date = Date()
    @objc dynamic var beatsPerMinute: Int = 0
    
    convenience init(beatsPerMinute: Int) {
        self.init()
        self.beatsPerMinute = beatsPerMinute
    }
}
