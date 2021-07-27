//
//  Settings.swift
//  HeartRate
//
//  Created by Ирина Савчик on 29.06.21.
//
import Foundation

class Settings {
    static let shared = Settings()
    
    private init() {}
    
    private let defaults = UserDefaults.standard
    
    var firstLaunch: Bool {
        set {
            defaults.set(newValue, forKey: "firstLaunch")
        }
        get {
            return defaults.value(forKey: "firstLaunch") as? Bool ?? true
        }
    }
    
    var firstSubscription: Bool {
        set {
            defaults.set(newValue, forKey: "firstSubscription")
        }
        get {
            return defaults.value(forKey: "firstSubscription") as? Bool ?? true
        }
    }
    
    var hasSubscription: Bool {
        set {
            defaults.set(newValue, forKey: "subscriptionPaid")
        }
        get {
            return defaults.value(forKey: "subscriptionPaid") as? Bool ?? false
        }
    }
    
    internal var canMeasured: Bool {
        get {
            return defaults.value(forKey: "measurementCount") as? Int ?? 0 < 2
        }
    }
    
    internal func checkMeasurementCount() {
        let lastDate = defaults.value(forKey: "measurementDate") as? Date ?? Date()
        let calendar = Calendar.current
        
        if !calendar.isDateInToday(lastDate) {
            defaults.set(0, forKey: "measurementCount")
        }
    }
    
    internal func onMeasured() {
        var count = defaults.value(forKey: "measurementCount") as? Int ?? 0

        count += 1
        defaults.set(count, forKey: "measurementCount")
        defaults.set(Date(), forKey: "measurementDate")
    }
}
