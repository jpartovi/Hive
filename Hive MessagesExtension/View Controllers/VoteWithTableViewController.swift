//
//  VoteWithTableViewController.swift
//  Hive MessagesExtension
//
//  Created by Jack Albright on 7/13/22.
//

import UIKit

class VoteWithTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var voteTable: UITableView!
    
    @IBOutlet weak var voteButton: StyleButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        voteTable.dataSource = self
        voteTable.delegate = self
        voteTable.separatorStyle = .none
        //voteTable.showsVerticalScrollIndicator = false
        voteTable.reloadData()
        
    }
    
    var voteGroups = ["A", "B", "C"]
    var voteItems = [["p", "q"], ["r", "s", "t", "u"], ["x", "y", "z"]]
    var voteTallies = [[3, 2], [1, 0, 4, 0], [2, 1, 2]]
    var isOpen = [false, false, false]
    var voteSelections = [nil, nil, nil] as [Int?]
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return voteGroups.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isOpen[section] {
            return voteItems[section].count
        } else {
            return 0
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCell(withIdentifier: VoteCell.reuseIdentifier, for: indexPath) as! VoteCell
        
        let cellView = UIView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height))
        
        if voteSelections[indexPath.section] == indexPath.row {
            cellView.backgroundColor = Style.secondaryColor
            cell.voteCount.backgroundColor = Style.primaryColor
        } else {
            cellView.backgroundColor = Style.lightGreyColor
            cell.voteCount.backgroundColor = Style.greyColor
        }
        
        cell.backgroundView = cellView
        
        
        cell.label.text = voteItems[indexPath.section][indexPath.row]
        cell.counter.text = String(voteTallies[indexPath.section][indexPath.row])
        cell.voteCount.frame.size.width = CGFloat(voteTallies[indexPath.section][indexPath.row])/CGFloat(voteTallies[indexPath.section].max()!) * cell.contentView.frame.width * 3/5
        cell.voteCount.frame.size.height = cell.contentView.frame.height
        cell.voteCount.layer.cornerRadius = cell.voteCount.frame.height/2
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return voteGroups[section]
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        headerView.backgroundColor = Style.primaryColor
        headerView.tag = section
        
        let headerString = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width-10, height: 30))
        headerString.text = voteGroups[section]
        headerView.addSubview(headerString)
        
        if let selection = voteSelections[section] {
            let headerSelection = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width-20, height: 30))
            headerSelection.text = voteItems[section][selection]
            headerSelection.textAlignment = NSTextAlignment.right
            headerView.addSubview(headerSelection)
        }
        
        let headerTapped = UITapGestureRecognizer(target: self, action:#selector(sectionHeaderTapped))
        headerView.addGestureRecognizer(headerTapped)
        
        return headerView
    }
    
    @objc func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        
        let indexPath = NSIndexPath(row: 0, section: recognizer.view!.tag)
        if (indexPath.row == 0) {
            
            isOpen[indexPath.section] = !isOpen[indexPath.section]
            let range = NSMakeRange(indexPath.section, 1)
            let sectionToReload = NSIndexSet(indexesIn: range)
            voteTable.reloadSections(sectionToReload as IndexSet, with:UITableView.RowAnimation.fade)
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if voteSelections[indexPath.section] == indexPath.row {
            voteSelections[indexPath.section] = nil
            voteTallies[indexPath.section][indexPath.row] = voteTallies[indexPath.section][indexPath.row] - 1
        } else {
            
            if voteSelections[indexPath.section] != nil {
                voteTallies[indexPath.section][voteSelections[indexPath.section]!] = voteTallies[indexPath.section][voteSelections[indexPath.section]!] - 1
            }
            
            voteSelections[indexPath.section] = indexPath.row
            voteTallies[indexPath.section][indexPath.row] = voteTallies[indexPath.section][indexPath.row] + 1
        }
        
        let range = NSMakeRange(indexPath.section, 1)
        let sectionToReload = NSIndexSet(indexesIn: range)
        voteTable.reloadSections(sectionToReload as IndexSet, with:UITableView.RowAnimation.fade)
        
        
        
    }
    
    
    
    
    
    /*let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 80))
    headerView.backgroundColor = Style.greyColor
    headerView.tag = section
    
    let submitButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 80))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.setImage(UIImage(named: "SelectedLongHex")?.size(width: button.frame.width, height: button.frame.height), for: UIControl.State.selected)
        button.setImage(UIImage(named: "LongHex")?.size(width: button.frame.width, height: button.frame.height), for: UIControl.State.normal)
        button.backgroundColor = Style.greyColor
        button.tintColor = Style.lightTextColor
        return button
    }()
    
    let submitLabel: UILabel = {
        let label = UILabel()
        label.text = "Submit Votes"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Style.lightTextColor
        return label
    }()
    
    headerView.addSubview(submitButton)
    headerView.addSubview(submitLabel)*/
    
    
    
    

}



/*if trueSection == -1 {
 let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 80))
 headerView.backgroundColor = Style.greyColor
 headerView.tag = section
 
 let submitButton: UIButton = {
     let button = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 80))
     button.translatesAutoresizingMaskIntoConstraints = false
     button.clipsToBounds = true
     button.setImage(UIImage(named: "SelectedLongHex")?.size(width: button.frame.width, height: button.frame.height), for: UIControl.State.selected)
     button.setImage(UIImage(named: "LongHex")?.size(width: button.frame.width, height: button.frame.height), for: UIControl.State.normal)
     button.backgroundColor = Style.greyColor
     button.tintColor = Style.lightTextColor
     return button
 }()
 
 let submitLabel: UILabel = {
     let label = UILabel()
     label.text = "Submit Votes"
     label.translatesAutoresizingMaskIntoConstraints = false
     label.textColor = Style.lightTextColor
     return label
 }()
 
 headerView.addSubview(submitButton)
 headerView.addSubview(submitLabel)
 
 NSLayoutConstraint.activate([
     submitButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
     submitButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
     submitLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
     submitLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
 ])
 
 return headerView
 
}*/
