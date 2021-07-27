//
//  SettingsViewController.swift
//  HeartRate
//
//  Created by Ирина Савчик on 26.05.21.
//

import UIKit
import MessageUI
import LinkPresentation
import StoreKit

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIActivityItemSource {
    @IBOutlet weak var tutorialView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var rateView: UIView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var subscribeView: UIView!
    @IBOutlet weak var termsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewGesture()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func setupViewGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapTutorialAction))
        tutorialView.addGestureRecognizer(tap)
        tutorialView.isUserInteractionEnabled = true
        
        let tapShare = UITapGestureRecognizer(target: self, action: #selector(tapShareAction))
        shareView.addGestureRecognizer(tapShare)
        shareView.isUserInteractionEnabled = true
        
        let tapContact = UITapGestureRecognizer(target: self, action: #selector(tapContactAction))
        contactView.addGestureRecognizer(tapContact)
        contactView.isUserInteractionEnabled = true
        
        let tapRateInAppStore = UITapGestureRecognizer(target: self, action: #selector(tapRateAction))
        rateView.addGestureRecognizer(tapRateInAppStore)
        rateView.isUserInteractionEnabled = true
        
        let tapSubscribe = UITapGestureRecognizer(target: self, action: #selector(tapSubscribeAction))
        subscribeView.addGestureRecognizer(tapSubscribe)
        subscribeView.isUserInteractionEnabled = true
        
        let tapPrivacyPolicy = UITapGestureRecognizer(target: self, action: #selector(tapPrivacyPolicyAction))
        privacyView.addGestureRecognizer(tapPrivacyPolicy)
        privacyView.isUserInteractionEnabled = true
        
        let tapTermsConditions = UITapGestureRecognizer(target: self, action: #selector(tapTermsConditionsAction))
        termsView.addGestureRecognizer(tapTermsConditions)
        termsView.isUserInteractionEnabled = true
    }
    
    @objc func tapTutorialAction() {
        self.performSegue(withIdentifier: "tutorial", sender: self)
    }
    
    @objc func tapShareAction() {
        let text = "Measure your pulse with Heart Rate!"
        var shareController : UIActivityViewController
        
        if #available(iOS 13.0, *) {
            shareController = UIActivityViewController(activityItems:  [self], applicationActivities: nil)
        } else {
            let url = URL(string: "https://itunes.apple.com/app/1575142512")
            shareController = UIActivityViewController(activityItems:  [text, url!], applicationActivities: nil)
        }
        present(shareController, animated: true, completion: nil)
    }
    
    /// ------------------------------ for UIActivityViewController ------------------------------
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return UIImage()
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return "Measure your pulse with Heart Rate!\nhttps://itunes.apple.com/app/1575142512"
    }
    
    @available(iOS 13.0, *)
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = "Measure your pulse with Heart Rate!"
        metadata.iconProvider = NSItemProvider.init(object: UIImage(named: "AppIcon")!)
        metadata.originalURL = URL(string: "https://itunes.apple.com/app/1575142512")
        metadata.url = metadata.originalURL
        return metadata
    }
    /// ------------------------------ for UIActivityViewController ------------------------------

    @objc func tapContactAction() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@gmail.com"])
            mail.setMessageBody("", isHTML: true)
            mail.delegate = self
            
            present(mail, animated: true)
        } else {
            print("Error")
        }
    }
    
    @objc func tapRateAction() {
        SKStoreReviewController.requestReview()
    }
    
    @objc func tapSubscribeAction() {
        self.performSegue(withIdentifier: "subscribe", sender: self)
    }
    
    @objc func tapPrivacyPolicyAction() {
        if let url = URL(string: "https://onexeor.dev/apps/heart_rate/privacy-policy.html") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func tapTermsConditionsAction() {
        if let url = URL(string: "https://onexeor.dev/apps/heart_rate/terms-and-conditions.html") {
            UIApplication.shared.open(url)
        }
    }
    
    private func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeSettingsActionButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

