//
//  VoteResultsNavigationController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/25/22.
//

import UIKit

class VoteResultsNavigationController: UINavigationController {
    
    var myID: String!
    var mURL: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vc = self.topViewController as? VoteResultsViewController {
            vc.myID = self.myID
            vc.mURL = self.mURL
        }
    }
}
