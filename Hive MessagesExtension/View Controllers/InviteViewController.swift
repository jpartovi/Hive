//
//  InviteViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/17/22.
//

import UIKit
import Messages
import GooglePlaces

class InviteViewController: StyleViewController {
    
    var delegate: InviteViewControllerDelegate?
    static let storyboardID = "InviteViewController"
    
    var myID: String!
    var mURL: URL!
    var RSVP: Bool!
    
    @IBOutlet weak var titleLabel: StyleLabel!
    //@IBOutlet weak var descriptionLabel: UILabel!
    //@IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dayAndTimeLabel: StyleLabel!
    @IBOutlet weak var locationLabel: StyleLabel!
    
    
    @IBOutlet weak var yesButton: SelectionLargeHexButton!
    @IBOutlet weak var noButton: SelectionLargeHexButton!
    
    @IBOutlet weak var yesBar: UIView!
    @IBOutlet weak var noBar: UIView!
    
    var yesNum: Int!
    var noNum: Int!
    
    var yesCounts = StyleLabel()
    var noCounts = StyleLabel()
    
    //var informationText = UILabel()
    
    var loadedEvent: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yesCounts.translatesAutoresizingMaskIntoConstraints = false
        noCounts.translatesAutoresizingMaskIntoConstraints = false
        //informationText.translatesAutoresizingMaskIntoConstraints = false
        
        yesBar.layer.cornerRadius = yesBar.frame.width/2
        noBar.layer.cornerRadius = noBar.frame.width/2
        
        yesBar.backgroundColor = Style.greyColor
        noBar.backgroundColor = Style.greyColor
        
        yesBar.addSubview(yesCounts)
        noBar.addSubview(noCounts)
        
        yesButton.size(size: 150, textSize: 25)
        yesButton.setDeselected()
        noButton.size(size: 150, textSize: 25)
        noButton.setDeselected()
        
        loadedEvent = Event(url: mURL)
        
        decodeEvent(loadedEvent)
        
        decodeRSVPs(url: mURL)
        
        yesCounts.style(text: String(yesNum), textColor: UIColor.white, fontSize: 25)
        noCounts.style(text: String(noNum), textColor: UIColor.white, fontSize: 25)
        
        
        NSLayoutConstraint.activate([
            //informationText.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            //informationText.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
            
            yesCounts.topAnchor.constraint(equalTo: yesBar.topAnchor, constant: 20),
            yesCounts.centerXAnchor.constraint(equalTo: yesBar.centerXAnchor),
            noCounts.topAnchor.constraint(equalTo: noBar.topAnchor, constant: 20),
            noCounts.centerXAnchor.constraint(equalTo: noBar.centerXAnchor),
            yesBar.heightAnchor.constraint(equalToConstant: 250 * CGFloat(yesNum) / CGFloat(yesNum + noNum + 1) + 50),
            noBar.heightAnchor.constraint(equalToConstant: 250 * CGFloat(noNum) / CGFloat(yesNum + noNum + 1) + 50)
        ])
        
    }
    
    func decodeEvent(_ event: Event) {
        
        titleLabel.style(text: "You're invited to " + event.title + "!")
        
        var day = event.days[0]
        
        var dayAndTimeInfo = "When: "
        if !event.times.isEmpty {
            dayAndTimeInfo += day.formatDate(time: event.times[0], duration: event.duration)
            //informationTextObject = informationTextObject + event.times[0].format(duration: event.duration)
        } else {
            dayAndTimeInfo += day.formatDate()
        }
        dayAndTimeLabel.style(text: dayAndTimeInfo, textColor: Style.darkTextColor, fontSize: 18)
        
        if event.locations.isEmpty {
            // Hide location label
            locationLabel.isHidden = true
        } else {
            var locationInfo = "Where: " + event.locations[0].title
            if let address = event.locations[0].address {
                locationInfo += ", " + address
            }
            locationLabel.isHidden = false
            locationLabel.style(text: locationInfo, textColor: Style.darkTextColor, fontSize: 18)
        }
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
            yesNum += 1
            if RSVP == false {
                noButton.changeSelectionStatus()
                noNum -= 1
                
                for (index, queryItem) in (components!.queryItems!.enumerated()){
                    if (queryItem.name == myID) && (queryItem.value == "No") {
                        components!.queryItems![index].value = "Yes"
                    }
                }
                
            } else {
                components!.queryItems!.append(URLQueryItem(name: myID, value: "Yes"))
            }
            
            setHeight(yesBar, h: 250 * CGFloat(yesNum) / CGFloat(yesNum + noNum + 1) + 50, animateTime: 0.5)
            setHeight(noBar, h: 250 * CGFloat(noNum) / CGFloat(yesNum + noNum + 1) + 50, animateTime: 0.5)
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
            
            setHeight(yesBar, h: 250 * CGFloat(yesNum) / CGFloat(yesNum + noNum + 1) + 50, animateTime: 0.5)
            setHeight(noBar, h: 250 * CGFloat(noNum) / CGFloat(yesNum + noNum + 1) + 50, animateTime: 0.5)
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
        message.summaryText = messageSummaryText
        
        print("Send")
        
        conversation.send(message)
        
        
        self.requestPresentationStyle(.compact)
    }
    
    
}


protocol InviteViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: InviteViewController)
    
}
