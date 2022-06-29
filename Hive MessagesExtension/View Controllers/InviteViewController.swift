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
    
    var myID: String!
    var mURL: URL!
    var RSVP: Bool!
    
    
    @IBOutlet weak var yesButton: PrimaryButton!
    @IBOutlet weak var noButton: PrimaryButton!
    
    @IBOutlet weak var yesCounts: UILabel!
    @IBOutlet weak var noCounts: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decodeURL(mURL)
    }
    
    func decodeURL(_ url: URL) {
        
        yesCounts.text = "0"
        noCounts.text = "0"

        let components = URLComponents(url: url,
                resolvingAgainstBaseURL: false)
        
        for (_, queryItem) in (components!.queryItems!.enumerated()){
            
            if (queryItem.name == "type") && (queryItem.value == "invite"){
                continue
            } else {
                
                if Bool(queryItem.value!)! {
                    yesCounts.text = String(Int(yesCounts.text!)!+1)
                } else {
                    noCounts.text = String(Int(noCounts.text!)!+1)
                }
                
                if queryItem.name == myID {
                    RSVP = Bool(queryItem.value!)
                }
            }
            
        }
        
    }
    
    @IBAction func yesClick(_ sender: Any) {
        
        var components = URLComponents(url: mURL,
                resolvingAgainstBaseURL: false)
        
        if !(RSVP != nil){
            
            components!.queryItems!.append(URLQueryItem(name: myID, value: "true"))
            yesCounts.text = String(Int(yesCounts.text!)!+1)
            
        } else if (RSVP == false){
            
            yesCounts.text = String(Int(yesCounts.text!)!+1)
            noCounts.text = String(Int(noCounts.text!)!-1)
            
            for (index, queryItem) in (components!.queryItems!.enumerated()){
                
                if (queryItem.name == "type") && (queryItem.value == "invite"){
                    continue
                } else if queryItem.name == myID {
                    components!.queryItems![index].value = "true"
                }
                
            }
            
        }
        
        RSVP = true
        prepareMessage(components!.url!)
        
    }
    
    
    @IBAction func noClick(_ sender: Any) {
        
        var components = URLComponents(url: mURL,
                resolvingAgainstBaseURL: false)
        
        if !(RSVP != nil){
            
            components!.queryItems!.append(URLQueryItem(name: myID, value: "false"))
            noCounts.text = String(Int(noCounts.text!)!+1)
            
        } else if (RSVP == true){
            
            yesCounts.text = String(Int(yesCounts.text!)!-1)
            noCounts.text = String(Int(noCounts.text!)!+1)
            
            for (index, queryItem) in (components!.queryItems!.enumerated()){
                
                if (queryItem.name == "type") && (queryItem.value == "invite"){
                    continue
                } else if queryItem.name == myID {
                    components!.queryItems![index].value = "false"
                }
                
            }
            
        }
        
        RSVP = false
        prepareMessage(components!.url!)
        
    }
    
    func prepareMessage(_ url: URL) {

        let message = MSMessage()

        let layout = MSMessageTemplateLayout()
        layout.caption = "Invite Placeholder"

        message.layout = layout
        message.url = url
        
        print("Send")
        
        guard let conversation = MessagesViewController.conversation else { fatalError("Received nil conversation") }
        
        conversation.insert(message)
        
        
    }
    
    
}


protocol InviteViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: InviteViewController)
    
}
