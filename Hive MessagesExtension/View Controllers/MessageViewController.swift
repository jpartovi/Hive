//
//  MessageViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/29/22.
//

import Foundation
import UIKit

class MessageViewController: StyleViewController {
    
    var delegate: MessageViewControllerDelegate?
    static let storyboardID = String(describing: MessageViewController.self)
    
    var myID: String!
    var mURL: URL!
    
    var titleText: String!
    var subtitleText: String!
    
    @IBOutlet weak var messageButton: HexButton!
    @IBOutlet weak var subtitleLabel: StyleLabel!
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        requestPresentationStyle(.expanded)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.systemBackground
        let textColor: UIColor = UIColor(named: "LabelColor")!
        
        
        messageButton.size(width: 130, textSize: 25)
        messageButton.style(title: title, imageTag: "ColorHex")
        
        subtitleLabel.style(text: subtitleText, textColor: textColor, fontSize: 18)
        subtitleLabel.adjustHeight()
    }
}

protocol MessageViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: StartEventViewController)
}
