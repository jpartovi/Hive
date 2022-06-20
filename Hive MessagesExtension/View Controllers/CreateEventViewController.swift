//
//  CreateEventViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/20/22.
//

import Foundation

import UIKit
import Messages

class CreateEventViewController: UIViewController {
    
    var delegate: CreateEventViewControllerDelegate?
    static let storyboardID = "CreateEventViewController"
    
    @IBOutlet var timeAndDate: UIButton!
    @IBOutlet var post: UIButton!
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
        
        /*
        let myBaseURL = "url"
        guard var components = URLComponents(string: myBaseURL) else {
            fatalError("Invalid base url")
        }
         
        let size = URLQueryItem(name: "Size", value: "Large")
        let count = URLQueryItem(name: "Topping_Count", value: "2")
        let cheese = URLQueryItem(name: "Topping_0", value: "Cheese")
        let pepperoni = URLQueryItem(name: "Topping_1", value: "Pepperoni")
        components.queryItems = [size, count, cheese, pepperoni]
         
        guard let url = components.url  else {
            fatalError("Invalid URL components.")
        }
         
        message.url = url
        */
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "type", value: "invite")]
        message.url = components.url!
        
        conversation.insert(message) {error in
            // empty for now
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        Style.styleButton(timeAndDate, color: Style.primaryColor, filled: true)
    }
}

protocol CreateEventViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: CreateEventViewController)
    
}
