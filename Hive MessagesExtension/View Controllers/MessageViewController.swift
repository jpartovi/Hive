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
    
    @IBOutlet weak var button: HexButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.size(size: 150, textSize: 25)
        button.style(imageTag: "ColorHex")
    }
}

protocol MessageViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: StartEventViewController)
}
