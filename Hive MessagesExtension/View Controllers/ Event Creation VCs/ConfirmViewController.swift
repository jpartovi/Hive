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
    
    
    var addressEditingIndex: Int? = nil
    
    @IBOutlet var eventTitleTextField: UITextField!
    @IBOutlet weak var locationsLabel: UILabel!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var firstLocationButton: HexButton!
    @IBOutlet weak var locationsTableView: UITableView!
    @IBOutlet weak var dayTimePairsLabel: UILabel!
    @IBOutlet weak var dayTimePairsTableView: UITableView!
    @IBOutlet weak var postButton: LargeHexButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleEventTitleTextField()
        
        firstLocationButton.style(imageTag: "LongHex", width: 150, height: 70, textColor: Style.lightTextColor, fontSize: 18)
        createDayTimePairs()
        fillEventDetails()
    }
    
    func styleEventTitleTextField() {
        
        eventTitleTextField.borderStyle = .none
        eventTitleTextField.font = Style.font(size: 30)
        eventTitleTextField.textColor = Style.tertiaryColor
        let underlineThickness = CGFloat(2)
        let underline = CALayer()
        underline.frame = CGRect(x: 0.0, y: eventTitleTextField.frame.height - underlineThickness, width: view.frame.width - 32, height: underlineThickness)
        underline.backgroundColor = Style.tertiaryColor.cgColor
        eventTitleTextField.layer.addSublayer(underline)
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
      
        if event.locations.isEmpty {
            firstLocationButton.isHidden = false
            addLocationButton.isHidden = true
        } else {
            firstLocationButton.isHidden = true
            addLocationButton.isHidden = false
        }
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
    
    @IBAction func addLocationButtonPressed(_ sender: Any) {
        event.locations.append(Location(title: "", place: nil))
        locationsTableView.reloadData()
        
        let lastCellIndexPath = IndexPath(row: 0, section: event.locations.count - 1)
        print("Last Cell Index: Row: " + String(lastCellIndexPath.row) + " section: " + String(lastCellIndexPath.section))
        locationsTableView.scrollToRow(at: lastCellIndexPath, at: .bottom, animated: false)
        let cell = locationsTableView.cellForRow(at: lastCellIndexPath) as! LocationCell
        cell.titleTextField.becomeFirstResponder()
        formatLocations()
        
        // TODO: make it so that the users cursor gets automatically put into the newest text field and keyboard opens
    }
    
    @objc func deleteLocation(sender: UIButton) {
        locationsTableView.reloadData()
        let index = sender.tag
        event.locations.remove(at: index)
        locationsTableView.deleteSections(IndexSet(integer: index), with: .fade)
        formatLocations()
    }
    
    @objc func addOrRemoveAddress(sender: UIButton) {
        addressEditingIndex = sender.tag
        if event.locations[addressEditingIndex!].place == nil {
            let autocompleteViewController = GMSAutocompleteViewController()
            autocompleteViewController.delegate = self
            navigationController?.present(autocompleteViewController, animated: true)
        } else {
            event.locations[addressEditingIndex!].place = nil
            locationsTableView.reloadData()
        }
    }
    
    @objc func locationTitleTextFieldDidChange(sender: UITextField) {
        print(sender.tag)
        
        // TODO: Better way to do this?? "try"?
        if event.locations.indices.contains(sender.tag) {
            event.locations[sender.tag].title = sender.text ?? ""
        }
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
            let location = event.locations[indexPath.section]
            cell.titleTextField.text = location.title
            cell.titleTextField.tag = indexPath.section
            cell.titleTextField.addTarget(self, action: #selector(locationTitleTextFieldDidChange(sender:)), for: .editingChanged)
            cell.deleteButton.tag = indexPath.section
            cell.deleteButton.addTarget(nil, action: #selector(deleteLocation(sender:)), for: .touchUpInside)
            cell.addOrRemoveAddressButton.tag = indexPath.section
            cell.addOrRemoveAddressButton.addTarget(nil, action: #selector(addOrRemoveAddress(sender:)), for: .touchUpInside)
            if let address = location.place?.formattedAddress {
                cell.addOrRemoveAddressButton.setTitle("- address", for: .normal)
                cell.changeAddressButton.isHidden = false
                cell.changeAddressButton.setTitle(address, for: .normal)
            } else {
                cell.addOrRemoveAddressButton.setTitle("+ address", for: .normal)
                cell.changeAddressButton.isHidden = true
            }
            return cell
        default:
            // TODO: This is not right, there should be some sort of error message here
            return UITableViewCell()
        }
    }
}

extension ConfirmViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !event.locations.isEmpty {
            if event.locations[indexPath.section].place != nil {
                return 86
            } else {
                return 50
            }
        } else {
            return 50
        }
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
        
        event.locations[addressEditingIndex!] = Location(title: event.locations[addressEditingIndex!].title, place: place)
        locationsTableView.reloadData()
        navigationController?.dismiss(animated: true)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        navigationController?.dismiss(animated: true)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        navigationController?.dismiss(animated: true)
    }
}
