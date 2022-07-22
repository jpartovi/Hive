//
//  VoteNavigationController.swift
//  Hive MessagesExtension
//
//  Created by Jack Albright on 7/20/22.
//

import UIKit

class VoteNavigationController: UINavigationController {
    
    var myID: String!
    var mURL: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vc = self.topViewController as? VoteViewController {
            vc.myID = self.myID
            vc.mURL = self.mURL
        }

        // Do any additional setup after loading the view.
    }
    

}
