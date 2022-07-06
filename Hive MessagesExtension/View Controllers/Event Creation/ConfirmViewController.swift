//
//  ConfirmViewSelector.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/3/22.
//

import Foundation
import UIKit

class ConfirmViewController: UIViewController {
    
    static let storyboardID = String(describing: ConfirmViewController.self)
    
    var event: Event! = nil
    
    @IBOutlet var eventNameTextField: UITextField!
    @IBOutlet weak var dayTimePairsTableView: UITableView!
    @IBOutlet weak var locationsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(event)
        fillEventDetails()
    }
    
    func fillEventDetails() {
        
        eventNameTextField.text = event.title
        setUpLocationsTableView()
        setUpDayTimePairsTableView()
    }
    
    func setUpDayTimePairsTableView() {
        dayTimePairsTableView.dataSource = self
        dayTimePairsTableView.delegate = self
    }
    
    func setUpLocationsTableView() {
        locationsTableView.dataSource = self
        locationsTableView.delegate = self
    }
}

extension ConfirmViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
        case dayTimePairsTableView:
            return event.dayTimePairs!.count
        case locationsTableView:
            return event.locations!.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        switch tableView {
        case dayTimePairsTableView:
            cell = dayTimePairsTableView.dequeueReusableCell(withIdentifier: DayTimePairCell.reuseIdentifier, for: indexPath) as! DayTimePairCell
            cell.textLabel!.text = event.dayTimePairs![indexPath.row].format()
        case locationsTableView:
            cell = locationsTableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier, for: indexPath)
            cell.textLabel?.text = event.locations![indexPath.row].title
        default:
            // TODO: This is not right, there should be some sort of error message here
            cell = UITableViewCell()
        }
        
        return cell
    }
}

extension ConfirmViewController: UITableViewDelegate {
    
}
