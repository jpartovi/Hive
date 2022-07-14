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
    
    var daysAndTimes: [Day : [Time]] = [:]
    
    var pollFlag = false
    var pollMessage: MSMessage!
    
    
    var addressEditingIndex: Int? = nil
    
    @IBOutlet var eventTitleTextField: UITextField!
    @IBOutlet weak var locationsLabel: UILabel!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var firstLocationButton: HexButton!
    @IBOutlet weak var locationsTableView: UITableView!
    @IBOutlet weak var dayTimePairsLabel: UILabel!
    @IBOutlet weak var daysAndTimesTableView: UITableView!
    @IBOutlet weak var postButton: HexButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHexFooter()
        
        styleEventTitleTextField()
        
        firstLocationButton.style(imageTag: "LongHex", width: 150, height: 70, textColor: Style.lightTextColor, fontSize: 18)
        loadDaysAndTimes()
        fillEventDetails()
        
        postButton.style(width: 130, height: 150, fontSize: 25)
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
        eventTitleTextField.placeholder = "Event Title"
    }
    
    func loadDaysAndTimes() {
        for day in event.days {
            daysAndTimes[day] = (event.times)
        }
    }
    func fillEventDetails() {
        
        eventTitleTextField.text = event.title
        locationsTableView.dataSource = self
        locationsTableView.delegate = self
        formatLocations()
        setUpDayTimePairsTableView()
    }
    
    func setUpDayTimePairsTableView() {
        daysAndTimesTableView.dataSource = self
        daysAndTimesTableView.delegate = self
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
        
        // TODO: Data to encode
        /*
         - Event title
         - Event type (key)?
         - Location options
            - Location name
            - GMSPlace ID
         - Days and times
            - Day in string form
            - Followed by times in string form
         - Duration
         
         */
        
        event.title = eventTitleTextField.text!
        
        // LoadDaysAndTimes
        for (index, day) in event.days.enumerated() {
            let cell = daysAndTimesTableView.cellForRow(at: IndexPath(item: index, section: 0)) as! DayAndTimesCell
            daysAndTimes[day] = []
            for (time, isSelected) in cell.times {
                if isSelected {
                    daysAndTimes[day]!.append(time)
                }
            }
        }
        print(daysAndTimes)
        
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
        
        let lastCellIndexPath = IndexPath(row: event.locations.count - 1, section: 0)
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
        locationsTableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .fade)
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
        case daysAndTimesTableView:
            return daysAndTimes.count
        case locationsTableView:
            return event.locations.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        switch tableView {
        case daysAndTimesTableView:
            let cell = daysAndTimesTableView.dequeueReusableCell(withIdentifier: DayAndTimesCell.reuseIdentifier, for: indexPath) as! DayAndTimesCell
            var day = event.days[indexPath.row]
            cell.dayLabel.text = day.formatDate() + ":"
            for time in daysAndTimes[day]! {
                cell.times.append((time, true))
            }
            cell.duration = event.duration
            return cell
        case locationsTableView:
            let cell = locationsTableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier, for: indexPath) as! LocationCell
            let location = event.locations[indexPath.row]
            cell.titleTextField.text = location.title
            cell.titleTextField.tag = indexPath.row
            cell.titleTextField.addTarget(self, action: #selector(locationTitleTextFieldDidChange(sender:)), for: .editingChanged)
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(nil, action: #selector(deleteLocation(sender:)), for: .touchUpInside)
            cell.addOrRemoveAddressButton.tag = indexPath.row
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        switch tableView {
        case locationsTableView:
            let verticalPadding: CGFloat = 8
            let maskLayer = CALayer()
            maskLayer.cornerRadius = LocationCell.cornerRadius
            maskLayer.backgroundColor = UIColor.black.cgColor
            maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
            cell.layer.mask = maskLayer
        case daysAndTimesTableView:
            let verticalPadding: CGFloat = 8
            let maskLayer = CALayer()
            maskLayer.cornerRadius = DayAndTimesCell.cornerRadius
            maskLayer.backgroundColor = UIColor.black.cgColor
            maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
            cell.layer.mask = maskLayer
        default:
            break
        }
        
    }
}

extension ConfirmViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case locationsTableView:
            if event.locations[indexPath.row].place != nil {
                return 86
            } else {
                return 50
            }
        case daysAndTimesTableView:
            return 50
        default:
            return 0
        }
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
