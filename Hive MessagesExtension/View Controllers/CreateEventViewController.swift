//
//  CreateEventViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/20/22.
//

// TODO: Can't see selected dates and times

import Foundation
import UIKit
import Messages

class CreateEventViewController: MSMessagesAppViewController {
    
    var dateTimePairs: [DayTimePair] = []
    
    var delegate: CreateEventViewControllerDelegate?
    static let storyboardID = "CreateEventViewController"
    
    // Connect storyboard elements
    @IBOutlet var eventTitleLabel: UILabel!
    @IBOutlet var eventTitleTextField: UITextField!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var timeAndDateButton: PrimaryButton!
    @IBOutlet var paymentButton: PrimaryButton!
    @IBOutlet var postButton: PrimaryButton!
    @IBOutlet var errorLabel: UILabel!
    
    // When the post button is pressed
    @IBAction func postButtonPressed(_ sender: UIButton!) {
        
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
        
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "type", value: "invite")]
        message.url = components.url!
        
        conversation.insert(message) {error in
            // empty for now
        }
        
        self.requestPresentationStyle(.compact)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for var pair in dateTimePairs {
            print(pair.day.formatDate() + " " + pair.timeFrame.format(title: true, timeRange: true))
        }
    }
    
    func setUpElements() {
        // BUG: something is wrong with the way these text fields are formatting
        //Style.styleTextFieldAndLabel(eventTitleTextField, eventTitleLabel)
        //Style.styleTieldAndLabel(descriptionTextField, descriptionLabel)
        //Style.styleTextFieldAndLabel(addressTextField, addressLabel)
    }
}

protocol CreateEventViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: CreateEventViewController)
    
}
