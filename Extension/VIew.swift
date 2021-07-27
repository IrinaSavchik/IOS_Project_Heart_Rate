//
//  VIew.swift
//  HeartRate
//
//  Created by Ирина Савчик on 26.06.21.
//

import Foundation
import UIKit

extension UIView {
    
    internal func show() {
        self.isHidden = false
        Self.animate(withDuration: 0.5, animations: {
            self.alpha = 1
        }) { _ in
        }
    }
    
    internal func hide() {
        Self.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }) { _ in
            self.isHidden = true
        }
    }
}
