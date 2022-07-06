//
//  StartEventViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/3/22.
//

import Foundation
import UIKit
import Messages

class StartEventViewController: MSMessagesAppViewController {
    
    var delegate: StartEventViewControllerDelegate?
    static let storyboardID = String(describing: StartEventViewController.self)
    
    @IBAction func lunchButtonPressed(_ sender: Any) {
        
        nextPage(type: Type.lunch)
        self.requestPresentationStyle(.expanded)
    }
    
    func nextPage(type: Type) {
        
        let event = Event(title: type.defaultTitle(), type: type)
        
        let locationsVC = (storyboard?.instantiateViewController(withIdentifier: LocationsViewController.storyboardID) as? LocationsViewController)!
        locationsVC.event = event
        self.navigationController?.pushViewController(locationsVC, animated: true)
    }
}

protocol StartEventViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: StartEventViewController)
}

