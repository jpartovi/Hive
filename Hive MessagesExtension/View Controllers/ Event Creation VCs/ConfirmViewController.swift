//
//  ConfirmViewSelector.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/3/22.
//

import Foundation
import UIKit
import Messages
import GooglePlaces

class ConfirmViewController: MSMessagesAppViewController {
    
    static let storyboardID = String(describing: ConfirmViewController.self)
    
    var event: Event! = nil
    
    var pollFlag = false
    var pollMessage: MSMessage!
    
    @IBAction func addLocationButtonPressed(_ sender: Any) {
        
        let autocompleteViewController = GMSAutocompleteViewController()
        autocompleteViewController.delegate = self
        navigationController?.present(autocompleteViewController, animated: true)
    }
    
    @IBOutlet var eventTitleTextField: UITextField!
    @IBOutlet weak var locationsLabel: UILabel!
    @IBOutlet weak var locationsTableView: UITableView!
    @IBOutlet weak var dayTimePairsLabel: UILabel!
    @IBOutlet weak var dayTimePairsTableView: UITableView!
    @IBOutlet weak var postButton: LargeHexButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(event)
        createDayTimePairs()
        fillEventDetails()
    }
    
    func createDayTimePairs() {
        var dayTimePairs = [DayTimePair]()
        for day in event.days {
            for timeFrame in event.times {
                dayTimePairs.append(DayTimePair(day: day, timeFrame: timeFrame))
            }
        }
        event.dayTimePairs = dayTimePairs
    }
    
    func fillEventDetails() {
        
        eventTitleTextField.text = event.title
        locationsTableView.dataSource = self
        locationsTableView.delegate = self
        formatLocations()
        setUpDayTimePairsTableView()
    }
    
    func setUpDayTimePairsTableView() {
        dayTimePairsTableView.dataSource = self
        dayTimePairsTableView.delegate = self
    }
    
    func formatLocations() {
        
        print("Format Locations")
        
        let labelHeightAnchor = locationsLabel.heightAnchor.constraint(equalToConstant: 20)
        let tableViewHeightAnchor = locationsTableView.heightAnchor.constraint(equalToConstant: 140)
        
        if event.locations.isEmpty {
            locationsLabel.isHidden = true
            labelHeightAnchor.constant = 0
            tableViewHeightAnchor.constant = 0
        } else if event.locations.count == 1 {
            labelHeightAnchor.constant = 20
            locationsTableView.isHidden = true
            tableViewHeightAnchor.constant = 0
            locationsLabel.isHidden = false
            locationsLabel.text = "Location: " + event.locations[0].title
        } else {
            labelHeightAnchor.constant = 20
            tableViewHeightAnchor.constant = 140
            locationsLabel.isHidden = false
            locationsLabel.text = "Location Options:"
        }
        
        
        print(labelHeightAnchor.constant)
        print(tableViewHeightAnchor.constant)
        labelHeightAnchor.isActive = true
        tableViewHeightAnchor.isActive = true
    }
    
    // When the post button is pressed
    @IBAction func postButtonPressed(_ sender: UIButton!) {
        
        event.title = eventTitleTextField.text!
        
        guard let conversation = MessagesViewController.conversation else { fatalError("Received nil conversation") }
        
        let session = conversation.selectedMessage?.session ?? MSSession()
        
        let alternateMessageLayout = MSMessageTemplateLayout()
        alternateMessageLayout.caption = "Caption"
        alternateMessageLayout.imageTitle = "Image Title"
        alternateMessageLayout.imageSubtitle = "Image subtitle"
        alternateMessageLayout.trailingCaption = "Trailing caption"
        alternateMessageLayout.subcaption = "Subcaption"
        alternateMessageLayout.trailingSubcaption = "Trailing subcaption"
        
        let message = MSMessage(session: session)
        let messageLayout = MSMessageLiveLayout(alternateLayout: alternateMessageLayout)
        
        message.layout = alternateMessageLayout
        message.summaryText = "Summary Text"
        
        if pollFlag {
            conversation.insert(pollMessage) {error in
                // empty for now
            }
        } else {
            var components = URLComponents()
            components.queryItems = [URLQueryItem(name: "type", value: "invite")]
            components.queryItems = [URLQueryItem(name: "type", value: "invite"), URLQueryItem(name: "title", value: event.title), URLQueryItem(name: "description", value: "DESCRIPTION"), URLQueryItem(name: "address", value: event.locations[0].title)]
            message.url = components.url!

            conversation.insert(message) {error in
                // empty for now
            }
        }
        
        self.requestPresentationStyle(.compact)
        
    }
    
    @objc func deleteLocation(sender: UIButton) {
        event.locations.remove(at: sender.tag)
        locationsTableView.reloadData()
        formatLocations()
    }
}

extension ConfirmViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
        case dayTimePairsTableView:
            return event.dayTimePairs.count
        case locationsTableView:
            return 1
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView {
        case dayTimePairsTableView:
            return 1
        case locationsTableView:
            return event.locations.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        switch tableView {
        case dayTimePairsTableView:
            let cell = dayTimePairsTableView.dequeueReusableCell(withIdentifier: DayTimePairCell.reuseIdentifier, for: indexPath) as! DayTimePairCell
            cell.textLabel!.text = event.dayTimePairs[indexPath.row].format()
            return cell
        case locationsTableView:
            let cell = locationsTableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier, for: indexPath) as! LocationCell
            cell.textField.text = event.locations[indexPath.section].title
            cell.addressLabel.text = event.locations[indexPath.section].place.formattedAddress
            cell.deleteButton.tag = indexPath.section
            cell.deleteButton.addTarget(nil, action: #selector(deleteLocation(sender:)), for: .touchUpInside)
            return cell
        default:
            // TODO: This is not right, there should be some sort of error message here
            return UITableViewCell()
        }
    }
}

extension ConfirmViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
     
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}

extension ConfirmViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        navigationController?.dismiss(animated: true)
        showInputDialog(title: "Add this Location",
                        subtitle: "Enter a name to describe this place (eg. Stacy's House)",
                        actionTitle: "Add",
                        cancelTitle: "Cancel",
                        autofillText: place.name!,
                        inputPlaceholder: "Enter name here",
                        inputKeyboardType: .asciiCapable, actionHandler:
                                { (input:String?) in
            self.event.locations.append(Location(title: input!, place: place))
            self.locationsTableView.reloadData()
            self.formatLocations()
                                })
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        navigationController?.dismiss(animated: true)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        navigationController?.dismiss(animated: true)
    }
}
