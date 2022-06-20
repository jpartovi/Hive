//
//  InviteViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/17/22.
//

import UIKit
import Messages

class InviteViewController: UIViewController {
    
    var delegate: InviteViewControllerDelegate?
    static let storyboardID = "InviteViewController"
    
}


protocol InviteViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: InviteViewController)
    
}
