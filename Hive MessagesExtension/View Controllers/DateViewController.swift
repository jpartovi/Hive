//
//  DateViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/20/22.
//

import UIKit
import Messages

class DateViewController: UIViewController {
    @IBAction func doneButtonPressed() {
        print("DONE")
        _ = navigationController?.popToRootViewController(animated: true)
    }
}
