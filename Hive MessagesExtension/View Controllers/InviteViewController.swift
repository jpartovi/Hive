//
//  InviteViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/17/22.
//

import UIKit
import Messages
import GooglePlaces

class InviteViewController: MSMessagesAppViewController {
    
    var delegate: InviteViewControllerDelegate?
    static let storyboardID = "InviteViewController"
    
    var myID: String!
    var mURL: URL!
    var RSVP: Bool!
    
    @IBOutlet weak var titleLabel: UILabel!
    //@IBOutlet weak var descriptionLabel: UILabel!
    //@IBOutlet weak var addressLabel: UILabel!
    
    
    @IBOutlet weak var yesButton: SelectionLargeHexButton!
    @IBOutlet weak var noButton: SelectionLargeHexButton!
    
    @IBOutlet weak var yesBar: UIView!
    @IBOutlet weak var noBar: UIView!
    
    var yesNum: Int!
    var noNum: Int!
    
    var yesCounts = UILabel()
    var noCounts = UILabel()
    
    var informationText = UILabel()
    
    var loadedEvent: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadedEvent = Event(url: mURL)
        //loadedEvent = Event(title: "Lunch", type: .lunch, locations: [Location(title: "Subway", place: nil)], days: [Day(date: Date())], times: [Time(hour: 11, minute: 30, period: .am)], daysAndTimes: [Day(date: Date()) : [Time(hour: 11, minute: 30, period: .am)]], duration: Duration(minutes: 30))
        
        decodeEvent(loadedEvent)
        
        decodeRSVPs(url: mURL)
        
        self.view.addSubview(informationText)
        
        yesCounts.translatesAutoresizingMaskIntoConstraints = false
        noCounts.translatesAutoresizingMaskIntoConstraints = false
        informationText.translatesAutoresizingMaskIntoConstraints = false
        
        yesBar.layer.cornerRadius = yesBar.frame.width/2
        noBar.layer.cornerRadius = noBar.frame.width/2
        
        yesBar.backgroundColor = Style.greyColor
        noBar.backgroundColor = Style.greyColor
        
        yesBar.addSubview(yesCounts)
        noBar.addSubview(noCounts)
        
        yesCounts.text = String(yesNum)
        noCounts.text = String(noNum)
        yesCounts.textColor = Style.lightTextColor
        noCounts.textColor = Style.lightTextColor
        
        
        NSLayoutConstraint.activate([
            informationText.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            informationText.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
            
            yesCounts.topAnchor.constraint(equalTo: yesBar.topAnchor, constant: 20),
            yesCounts.centerXAnchor.constraint(equalTo: yesBar.centerXAnchor),
            noCounts.topAnchor.constraint(equalTo: noBar.topAnchor, constant: 20),
            noCounts.centerXAnchor.constraint(equalTo: noBar.centerXAnchor),
            yesBar.heightAnchor.constraint(equalToConstant: 250 * CGFloat(yesNum) / CGFloat(yesNum + noNum + 1) + 50),
            noBar.heightAnchor.constraint(equalToConstant: 250 * CGFloat(noNum) / CGFloat(yesNum + noNum + 1) + 50)
        ])
        
    }
    
    func decodeEvent(_ event: Event) {
        
        if event.locations.count == 0 {
            titleLabel.text = event.title
        } else {
            titleLabel.text = event.title + " at " + event.locations[0].title
        }
        
        informationText.textColor = Style.greyColor
        informationText.numberOfLines = 0;
        
        var informationTextObject = ""
        
        if let address = event.locations[0].address {
            informationTextObject = informationTextObject + address + "\n"
        }
        
        var day = event.days[0]
        
        informationTextObject = informationTextObject + day.formatDate() + "\n"
        
        if !event.times.isEmpty {
            informationTextObject = informationTextObject + event.times[0].format(duration: event.duration)
        }
        
        informationText.text = informationTextObject
        
        
    }
    
    func decodeRSVPs(url: URL) {
        
        yesNum = 0
        noNum = 0
        
        let components = URLComponents(url: url,
                resolvingAgainstBaseURL: false)
        
        var endFlag = false
        for (_, queryItem) in (components!.queryItems!.enumerated()){
            let name = queryItem.name
            let value = queryItem.value
            
            if name == "endEvent" {
                endFlag = true
            } else if endFlag {
                if value == "No" {
                    noNum = noNum + 1
                    
                    if name == myID {
                        RSVP = false
                        noButton.changeSelectionStatus()
                    }
                } else if value == "Yes" {
                    yesNum = yesNum + 1
                    
                    if name == myID {
                        RSVP = true
                        yesButton.changeSelectionStatus()
                    }
                }
                
            }
        }
    }
    
    func setHeight(_ view:UIView, h:CGFloat, animateTime:TimeInterval) {
        
        if let c = view.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal }) {
            c.constant = CGFloat(h)

            UIView.animate(withDuration: animateTime, animations:{view.superview?.layoutIfNeeded()})
            
            //view.superview?.layoutIfNeeded()
        }
        
    }
    
    @IBAction func yesClick(_ sender: SelectionLargeHexButton) {
        
        var components = URLComponents(url: mURL,
                resolvingAgainstBaseURL: false)
        
        if RSVP != true {
            
            yesButton.changeSelectionStatus()
            yesNum = yesNum + 1
            if RSVP == false {
                noButton.changeSelectionStatus()
                noNum = noNum - 1
                
                for (index, queryItem) in (components!.queryItems!.enumerated()){
                    if (queryItem.name == myID) && (queryItem.value == "No") {
                        components!.queryItems![index].value = "Yes"
                    }
                }
                
            } else {
                components!.queryItems!.append(URLQueryItem(name: myID, value: "Yes"))
            }
            
            setHeight(yesBar, h: 250 * CGFloat(yesNum) / CGFloat(yesNum + noNum), animateTime: 0.5)
            setHeight(noBar, h: 250 * CGFloat(noNum) / CGFloat(yesNum + noNum), animateTime: 0.5)
            yesCounts.text = String(yesNum)
            noCounts.text = String(noNum)
            
            RSVP = true

        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.prepareMessage(components!.url!, summaryText: "I can come to " + self.loadedEvent.title + "!")
            self.dismiss()
        }
        
    }
    
    
    @IBAction func noClick(_ sender: SelectionLargeHexButton) {
        
        var components = URLComponents(url: mURL,
                resolvingAgainstBaseURL: false)
        
        if RSVP != false {
            
            noButton.changeSelectionStatus()
            noNum = noNum + 1
            if RSVP == true {
                yesButton.changeSelectionStatus()
                yesNum = yesNum - 1
                
                for (index, queryItem) in (components!.queryItems!.enumerated()){
                    if (queryItem.name == myID) && (queryItem.value == "Yes") {
                        components!.queryItems![index].value = "No"
                    }
                }
                
            } else {
                components!.queryItems!.append(URLQueryItem(name: myID, value: "No"))
            }
            
            setHeight(yesBar, h: 250 * CGFloat(yesNum) / CGFloat(yesNum + noNum), animateTime: 0.5)
            setHeight(noBar, h: 250 * CGFloat(noNum) / CGFloat(yesNum + noNum), animateTime: 0.5)
            yesCounts.text = String(yesNum)
            noCounts.text = String(noNum)
            
            RSVP = false

        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.prepareMessage(components!.url!, summaryText: "I can't come to " + self.loadedEvent.title)
            self.dismiss()
        }
        
    }
    
    func prepareMessage(_ url: URL, summaryText: String) {
        
        guard let conversation = MessagesViewController.conversation else { fatalError("Received nil conversation") }

        let message = MSMessage(session: (conversation.selectedMessage?.session)!)

        let layout = conversation.selectedMessage?.layout as! MSMessageTemplateLayout
        
        layout.image = UIImage(named: "MessageHeader")
        
        message.layout = layout
        message.url = url
        message.summaryText = ""
        
        print("Send")
        
        guard let conversation = MessagesViewController.conversation else { fatalError("Received nil conversation") }
        
        conversation.send(message)
        
        self.requestPresentationStyle(.compact)
    }
    
    
}


protocol InviteViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: InviteViewController)
    
}
