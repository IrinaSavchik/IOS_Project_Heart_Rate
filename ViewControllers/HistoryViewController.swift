//
//  HistoryViewController.swift
//  HeartRate
//
//  Created by Ирина Савчик on 26.05.21.
//

import UIKit

class HistoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var data: [Measure] = []
    var sections: [String:[Measure]] = [:]
    var sectionKeys: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 255/255, green: 248/255, blue: 248/255, alpha: 1)
        
        let nib = UINib(nibName: String(describing: MeasureCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: MeasureCell.self))
        
        data = RealmManager.shared.readObjects()
        self.generateSections()
        tableView.reloadData()
    }
    
    @IBAction func closeActionButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func generateSections() {
        data.sort { i1, i2 in
            return i1.dateAndTime.compare(i2.dateAndTime).rawValue > 0
        }
        
        data.forEach { item in
            let headerTitle = getSectionTitle(date: item.dateAndTime)
            let header = sections[headerTitle]
            
            if header != nil {
                sections[headerTitle]?.append(item)
            } else {
                sectionKeys.append(headerTitle)
                sections[headerTitle] = [item]
            }
        }
    }
    
    private func getSectionTitle(date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.timeStyle = .none
            formatter.dateStyle = .long
            return formatter.string(from: date)
        }
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewContainer = UIView(frame: CGRect(x:0, y:0, width: tableView.frame.width, height: 62))
        viewContainer.backgroundColor = UIColor(red: 255/255, green: 248/255, blue: 248/255, alpha: 1)
        let labelHeader = UILabel(frame: CGRect(x:13, y:20, width: 200, height: 27))
        labelHeader.font = UIFont(name:"Poppins-SemiBold", size: 18.0)
        
        labelHeader.text = sectionKeys[section]
        labelHeader.textColor = UIColor.black
        
        viewContainer.addSubview(labelHeader)
        return viewContainer
    }
}

extension HistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName = sectionKeys[section]
        return self.sections[sectionName]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MeasureCell.self), for: indexPath)
        guard let measureCell = cell as? MeasureCell else { return cell }
        
        let sectionName = sectionKeys[indexPath.section]
        let item = sections[sectionName]?[indexPath.row]
        
        guard let unwrappedItem = item else { return UITableViewCell() }
        
        measureCell.setupCell(measure: unwrappedItem)
        measureCell.selectionStyle = .none
        
        return measureCell
    }
}


