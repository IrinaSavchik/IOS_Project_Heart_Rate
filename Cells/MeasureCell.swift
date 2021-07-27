//
//  MeasureCell.swift
//  HeartRate
//
//  Created by Ирина Савчик on 9.06.21.
//

import UIKit

class MeasureCell: UITableViewCell {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var beatsPerMinuteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        view.frame = view.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }
    
    func setupCell(measure: Measure) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeStyle = .short
        formatter.dateStyle = .long
        dateAndTimeLabel.text = formatter.string(from: measure.dateAndTime)
        beatsPerMinuteLabel.text = "\(measure.beatsPerMinute)"
    }
}
