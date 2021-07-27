//
//  SubscriptionManager.swift
//  HeartRate
//
//  Created by Ирина Савчик on 4.07.21.
//

import Foundation
import SwiftyStoreKit
import StoreKit

class SubscriptionManager {
    
    static let shared = SubscriptionManager()
    
    internal static let weeklySubscription = "com.companyName.heartrate.subscription.weekly"
    internal static let monthlySubscription = "com.companyName.heartrate.subscription.monthly"
    
    private let sharedSecret = "sharedSecret"
    
    internal var monthlyProduct: SKProduct?
    internal var weeklyProduct: SKProduct?
    
    internal func retreive() {
        SwiftyStoreKit.retrieveProductsInfo([Self.weeklySubscription, Self.monthlySubscription]) { result in
            result.retrievedProducts.forEach { product in
                if product.productIdentifier == Self.weeklySubscription {
                    self.weeklyProduct = product
                } else if product.productIdentifier == Self.monthlySubscription {
                    self.monthlyProduct = product
                }
            }
        }
    }
    
    internal func productPurchase(identifier: String, completion: @escaping (Bool, String?) -> Void) {
        SwiftyStoreKit.purchaseProduct(identifier, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                Settings.shared.hasSubscription = true
                print("Purchase Success: \(purchase.productId)")
                completion(true, nil)
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                    completion(false, "Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                    completion(false, "Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                    completion(false, "The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                    completion(false, "The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                    completion(false, "The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                    completion(false, "Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                    completion(false, "Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                    completion(false, "User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                    completion(false, (error as NSError).localizedDescription)
                }
            }
        }
    }
    
    // TODO
    
    internal func restore() {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                self.verifySubscription()
                print("Restore Success: \(results.restoredPurchases)")
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
    
    internal func verifySubscription() {
        var serviceType = AppleReceiptValidator.VerifyReceiptURLType.production
        #if DEBUG
        serviceType = AppleReceiptValidator.VerifyReceiptURLType.sandbox
        #endif
        
        let appleValidator = AppleReceiptValidator(service: serviceType, sharedSecret: self.sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                
                // Verify the purchase of a Subscription
                let purchaseWeeklyResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing
                    productId: Self.weeklySubscription,
                    inReceipt: receipt)
                
                let purchaseMonthlyResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing
                    productId: Self.monthlySubscription,
                    inReceipt: receipt)
                
                Settings.shared.hasSubscription = self.checkHasSubscription(purchaseWeeklyResult) || self.checkHasSubscription(purchaseMonthlyResult)
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    private func checkHasSubscription(_ purchaseResult: VerifySubscriptionResult) -> Bool {
        switch purchaseResult {
        case .purchased(_, _):
            return true
        case .expired(let expiryDate, let items):
            print(" is expired since \(expiryDate)\n\(items)\n")
            return false
        case .notPurchased:
            print("The user has never purchased ")
            return false
        }
    }
}
