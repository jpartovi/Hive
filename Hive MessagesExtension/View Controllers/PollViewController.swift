//
//  PollViewController.swift
//  Hive MessagesExtension
//
//  Created by Jack Albright on 6/20/22.
//
/*
import UIKit
import Messages

//var mURL: URL!
//var vURL: URL!

class PollViewController: UIViewController {
    
    var delegate: MessagesViewController?
    //var conversation: MSConversation?
    static let storyboardID = "PollViewController"
    
    var pollitems: [DayTimePair]?
    
    @IBOutlet weak var scrollview: UIView!
    
    @IBOutlet weak var sendbutton: UIButton!
    //@IBOutlet var xitems: [UITextField]!
    
    var items: [UITextField]!
    
    var message: MSMessage!
    
    @IBAction func buttonPressed(_ sender: AnyObject) {
        
        if sendbutton != nil {
            if sendbutton.isEqual(sender) {
                let url = prepareURL()
                prepareMessage(url)
                
            }
        }
            
    }
    
    
    func prepareURL() -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https";
        urlComponents.host = "www.placeholder.com";
        
        urlComponents.queryItems = []
        
        
        let vcItem = URLQueryItem(name:"VC", value: "vote")
        urlComponents.queryItems?.append(vcItem)
        
        let idItem = URLQueryItem(name:"ID", value: "lpi")
        urlComponents.queryItems?.append(idItem)
        
        for (_, textfield) in items.enumerated() {
            let queryItem = URLQueryItem(name: textfield.text!, value: "0")
            urlComponents.queryItems?.append(queryItem)
        }
        
        let pollendItem = URLQueryItem(name:"END", value: "END")
        urlComponents.queryItems?.append(pollendItem)
        
        return urlComponents.url!
    }
    
    
    func prepareMessage(_ url: URL) {
        
        let session = MSSession()

        message = MSMessage(session: session)

        let layout = MSMessageTemplateLayout()
        layout.caption = "Poll Placeholder"

        message.layout = layout
        message.url = url
        
        
        // TODO : Integrate with new system
        /*
        if let createEventVC = navigationController?.viewControllers.first as? CreateEventViewController {
            
            createEventVC.pollFlag = true
            createEventVC.pollMessage = message
            
        }
        */
         
        _ = navigationController?.popToRootViewController(animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        
        items = []
        
        for (index, var pollitem) in pollitems!.enumerated() {
            
            
            let label = UITextField()
            label.text = pollitem.format()
            label.borderStyle = UITextField.BorderStyle.roundedRect
            
            label.translatesAutoresizingMaskIntoConstraints = false
            
            scrollview.addSubview(label)
            
            label.leadingAnchor.constraint(equalTo: label.superview!.leadingAnchor, constant: 16).isActive = true
            label.trailingAnchor.constraint(equalTo: label.superview!.trailingAnchor, constant: -16).isActive = true
            
            if (index == 0){
                
                label.topAnchor.constraint(equalTo: label.superview!.topAnchor, constant: 16).isActive = true
                
            } else {
                
                label.topAnchor.constraint(equalTo: items[index-1].bottomAnchor).isActive = true
                
            }
            
            if (index == pollitems!.count-1) {
                
                label.bottomAnchor.constraint(equalTo: label.superview!.bottomAnchor, constant: -16).isActive = true
                
            }
            
            
            items.append(label)
            
            
        }

        
    }
    

    // MARK: - Conversation Handling

    /*@IBAction func unwind( _ seg: UIStoryboardSegue) {
        
        prepareMessage(vURL)
        
    }*/
    
    
    /*override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        
        super.willBecomeActive(with: conversation)
        
            
            
            
        if (conversation.selectedMessage?.url) != nil {
            
            mURL = conversation.selectedMessage?.url
            let components = URLComponents(url: mURL,
                    resolvingAgainstBaseURL: false)
            
            let clickid = components?.queryItems![0].value
            
            if (components?.host == "www.placeholder.com"){
            
                if (clickid == conversation.localParticipantIdentifier.uuidString){
                    self.performSegue(withIdentifier: "Host", sender: self)
                } else {
                    self.performSegue(withIdentifier: "Voter", sender: self)
                }
                
            } else if (components?.host == "www.votemessage.com") {
                
                if (clickid != conversation.localParticipantIdentifier.uuidString){
                
                    /*let newid = components?.queryItems![0].value
                    
                    let newchoice = components?.queryItems![1].value
                    
                    vote_talleys.append((id: newid!, choice: newchoice!))*/
                    
                    self.performSegue(withIdentifier: "Host", sender: self)
                
                } else {
                    
                    self.performSegue(withIdentifier: "Voter", sender: self)
                    
                }
                
            }
            
        }
        
        
        
    }*/

}


protocol PollViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: PollViewController)
    
}
*/
