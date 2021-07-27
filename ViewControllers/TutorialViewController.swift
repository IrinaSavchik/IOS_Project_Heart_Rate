//
//  TutorialViewController.swift
//  HeartRate
//
//  Created by Ирина Савчик on 10.06.21.
//

import UIKit

class TutorialViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func closeActionButton(_ sender: Any) {
        Settings.shared.firstLaunch = false
        self.dismiss(animated: true, completion: nil)
    }
}
