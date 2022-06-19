//
//  TimeViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/17/22.
//

import UIKit
import Messages

class TimeViewController: UIViewController {
    
    var delegate: TimeViewControllerDelegate?
    static let storyboardID = "TimeViewController"
    
}

protocol TimeViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: TimeViewController)
    
}
