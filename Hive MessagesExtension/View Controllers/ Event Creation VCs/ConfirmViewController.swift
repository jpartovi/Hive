//
//  ConfirmViewSelector.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/3/22.
//

import Foundation
import UIKit
import Messages

class ConfirmViewController: MSMessagesAppViewController {
    
    static let storyboardID = String(describing: ConfirmViewController.self)
    
    var event: Event! = nil
    
    var pollFlag = false
    var pollMessage: MSMessage!
    
    @IBOutlet var eventTitleTextField: UITextField!
    @IBOutlet weak var dayTimePairsTableView: UITableView!
    @IBOutlet weak var locationsTableView: UITableView!
    
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
}

extension ConfirmViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
        case dayTimePairsTableView:
            return event.dayTimePairs.count
        case locationsTableView:
            return event.locations.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        switch tableView {
        case dayTimePairsTableView:
            cell = dayTimePairsTableView.dequeueReusableCell(withIdentifier: DayTimePairCell.reuseIdentifier, for: indexPath) as! DayTimePairCell
            cell.textLabel!.text = event.dayTimePairs[indexPath.row].format()
        case locationsTableView:
            cell = locationsTableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier, for: indexPath)
            cell.textLabel?.text = event.locations[indexPath.row].title
        default:
            // TODO: This is not right, there should be some sort of error message here
            cell = UITableViewCell()
        }
        
        return cell
    }
}

extension ConfirmViewController: UITableViewDelegate {
    
}
