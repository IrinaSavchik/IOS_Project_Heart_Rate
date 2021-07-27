//
//  SubscribeViewController.swift
//  HeartRate
//
//  Created by Ирина Савчик on 29.06.21.
//

import UIKit

enum SubscriptionType {
    case weekly
    case monthly
}

class SubscribeViewController: UIViewController {
    @IBOutlet weak var oneWeekSubscribe: UIButton!
    @IBOutlet weak var oneMonthSubscribe: UIButton!
    @IBOutlet weak var rectangleImage: UIImageView!
    @IBOutlet weak var discountImage: UIImageView!
    @IBOutlet weak var oneWeekCircleImage: UIImageView!
    @IBOutlet weak var oneMonthCircleImage: UIImageView!
    
    private let subManager = SubscriptionManager.shared
    private var currentSubscription: SubscriptionType = SubscriptionType.monthly
    
    override func viewDidLoad() {
        super.viewDidLoad()
        oneMonthSubscribe.layer.borderWidth = 1
        oneMonthSubscribe.layer.borderColor = UIColor(red: 249/255, green: 48/255, blue: 84/255, alpha: 1.0).cgColor
        
        let weekPrice = subManager.weeklyProduct?.localizedPrice ?? "-"
        let monthPrice = subManager.monthlyProduct?.localizedPrice ?? "-"
        
        oneWeekSubscribe.setTitle("1 week: \(weekPrice)", for: UIControl.State.normal)
        oneMonthSubscribe.setTitle("1 month: \(monthPrice)", for: UIControl.State.normal)
    }
    
    @IBAction func onPrivacyPolicyClick(_ sender: Any) {
        if let url = URL(string: "https://onexeor.dev/apps/heart_rate/privacy-policy.html") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func onTermsAndConditionsClick(_ sender: Any) {
        if let url = URL(string: "https://onexeor.dev/apps/heart_rate/terms-and-conditions.html") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func onSubscribe(_ sender: Any) {
        subManager.productPurchase(identifier:
                                    currentSubscription == SubscriptionType.weekly ?
                                    SubscriptionManager.weeklySubscription : SubscriptionManager.monthlySubscription) { (status, msg) in
            
            if status {
                SubscriptionManager.shared.verifySubscription()
                self.navigationController?.popViewController(animated: true)
            } else {
                guard let msgText = msg else { return }
                let alert = UIAlertController(title: "Error!", message: "\(msgText)", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func closeActionButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func oneWeekSubscribeActionButton(_ sender: Any) {
        currentSubscription = SubscriptionType.weekly
        oneMonthSubscribe.layer.borderColor = UIColor.clear.cgColor
        oneWeekSubscribe.layer.borderWidth = 1
        oneWeekSubscribe.layer.borderColor = UIColor(red: 249/255, green: 48/255, blue: 84/255, alpha: 1.0).cgColor
        rectangleImage.image = UIImage(named:"Rectangle 130-1")
        discountImage.image = UIImage(named:"ic_discount-1")
        oneWeekCircleImage.image = UIImage(named:"Ellipse 13")
        oneMonthCircleImage.image = UIImage(named:"Ellipse 12")
        
    }
    
    @IBAction func oneMonthSubscribeActionButton(_ sender: Any) {
        currentSubscription = SubscriptionType.monthly
        oneWeekSubscribe.layer.borderColor = UIColor.clear.cgColor
        oneMonthSubscribe.layer.borderWidth = 1
        oneMonthSubscribe.layer.borderColor = UIColor(red: 249/255, green: 48/255, blue: 84/255, alpha: 1.0).cgColor
        rectangleImage.image = UIImage(named:"Rectangle 130")
        discountImage.image = UIImage(named:"ic_discount")
        oneWeekCircleImage.image = UIImage(named:"Ellipse 12")
        oneMonthCircleImage.image = UIImage(named:"Ellipse 13")
        
    }
}
