//
//  VoteViewController.swift
//  testapp1 MessagesExtension
//
//  Created by Jack Albright on 6/17/22.
//

import UIKit
import Messages

class VoteViewController: UIViewController {
    
    var delegate: MessagesViewController?
    static let storyboardID = "VoteViewController"
    
    
    var myID: String!
    var mURL: URL!
    
    var curPick = -1
    
    @IBOutlet weak var scrollview: UIView!
    
    
    var entries: [String]!
    var counts: [String]!
    
    var votelabels: [UILabel]!
    
    var countlabels: [UILabel]!
    
    var PickButtons: [UIButton]!
    
    @IBAction func pickPressed(_ sender: UIButton) {
        
        for (index, sendbutton) in (PickButtons.enumerated()) {
            
            if sendbutton.isEqual(sender) {
                
                let url = prepareVoteURL(index)
                
                prepareMessage(url)
                
            }
        }
    }
    
    
    func prepareMessage(_ url: URL) {

        let message = MSMessage()

        let layout = MSMessageTemplateLayout()
        layout.caption = "Vote Placeholder"

        message.layout = layout
        message.url = url
        
        print("Send")
        
        guard let conversation = MessagesViewController.conversation else { fatalError("Received nil conversation") }
        
        conversation.insert(message)
        
        
    }
    
    
    func prepareVoteURL(_ indexPicked: Int) -> URL {
        
        var components = URLComponents(url: mURL,
                resolvingAgainstBaseURL: false)
        
        let voteItems = components!.queryItems![(3+entries.count)...]
        
        if (curPick == -1){
            
            let newVoteItem = URLQueryItem(name:myID, value: String(indexPicked))
            components!.queryItems?.append(newVoteItem)
            
        } else {
            
            for (index, queryItem) in (voteItems.enumerated()) {
                if (queryItem.name == myID){
                      
                    components!.queryItems![3+curPick].value = String(Int(components!.queryItems![3+curPick].value!)! - 1)
                    
                    components!.queryItems![(3+entries.count+index)].value = String(indexPicked)
                    
                    break
                }
            }
            
        }
        
        components!.queryItems![2+indexPicked].value = String(Int(components!.queryItems![2+indexPicked].value!)! + 1)
        
        return (components?.url!)!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decodeURL(mURL)
        
        
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        
        votelabels = []
        countlabels = []
        PickButtons = []
        
        for (index, entry) in entries!.enumerated() {
            
            let count = counts[index]
            
            
            let optionlabel = UILabel()
            optionlabel.text = entry
            optionlabel.translatesAutoresizingMaskIntoConstraints = false
            scrollview.addSubview(optionlabel)
            
            let countlabel = UILabel()
            countlabel.text = count
            countlabel.translatesAutoresizingMaskIntoConstraints = false
            scrollview.addSubview(countlabel)
            
            let votebutton = UIButton(type: UIButton.ButtonType.system)
            votebutton.setTitle("Vote", for: UIControl.State.normal)
            votebutton.translatesAutoresizingMaskIntoConstraints = false
            scrollview.addSubview(votebutton)
            
            
            optionlabel.leadingAnchor.constraint(equalTo: optionlabel.superview!.leadingAnchor, constant: 16).isActive = true
            countlabel.centerXAnchor.constraint(equalTo: countlabel.superview!.centerXAnchor).isActive = true
            votebutton.trailingAnchor.constraint(equalTo: votebutton.superview!.trailingAnchor, constant: -16).isActive = true
            
            if (index == 0){
                
                optionlabel.topAnchor.constraint(equalTo: optionlabel.superview!.topAnchor, constant: 16).isActive = true
                
                countlabel.topAnchor.constraint(equalTo: countlabel.superview!.topAnchor, constant: 16).isActive = true
                
                votebutton.topAnchor.constraint(equalTo: votebutton.superview!.topAnchor, constant: 16).isActive = true
                
            } else {
                
                optionlabel.topAnchor.constraint(equalTo: votelabels[index-1].bottomAnchor).isActive = true
                
                countlabel.topAnchor.constraint(equalTo: countlabels[index-1].bottomAnchor).isActive = true
                
                votebutton.topAnchor.constraint(equalTo: PickButtons[index-1].bottomAnchor).isActive = true
                
            }
            
            if (index == entries!.count-1) {
                
                optionlabel.bottomAnchor.constraint(equalTo: optionlabel.superview!.bottomAnchor, constant: -16).isActive = true
                
                countlabel.bottomAnchor.constraint(equalTo: countlabel.superview!.bottomAnchor, constant: -16).isActive = true
                
                votebutton.bottomAnchor.constraint(equalTo: votebutton.superview!.bottomAnchor, constant: -16).isActive = true
                
            }
            
            votebutton.addTarget(self, action:#selector(pickPressed), for: UIControl.Event.touchUpInside)
            
            votelabels.append(optionlabel)
            countlabels.append(countlabel)
            PickButtons.append(votebutton)
            
            
        }
        
        
        
        /*for (index, entry) in (entries.enumerated()) {
            
            votelabels[index].text = entry
            countlabels[index].text = counts[index]
        }*/
    }
    
    // MARK: - Conversation Handling

    
    func decodeURL(_ url: URL) {

        let components = URLComponents(url: url,
                resolvingAgainstBaseURL: false)
        
        
        entries = []
        counts = []
        
        var lastIndex = 0

        for (index, queryItem) in (components!.queryItems![2...].enumerated()) {
            
            if (queryItem.name == "END") && (queryItem.value == "END"){
                lastIndex = index+2
                break
            }
            
            entries.append(queryItem.name)
            counts.append(queryItem.value!)
        }
        
        
        for (index, queryItem) in (components!.queryItems![(lastIndex+1)...].enumerated()) {
            if (queryItem.name == myID){
                
                curPick = Int(components!.queryItems![(lastIndex+1+index)].value!)!
                
                break
            }
        }
        
    }

    
}


protocol VoteViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: VoteViewController)
    
}
