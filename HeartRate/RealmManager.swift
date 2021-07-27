//
//  RealmManager.swift
//  HeartRate
//
//  Created by Ирина Савчик on 9.06.21.
//

import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    let realm = try! Realm()
    
    private init() { }
    
    func writeObject(measure: Measure) {
        try! realm.write {
            realm.add(measure)
        }
    }
    
    func readObjects() -> [Measure] {
        return Array(realm.objects(Measure.self))
    }
}
