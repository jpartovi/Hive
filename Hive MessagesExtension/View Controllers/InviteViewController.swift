//
//  InviteViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/17/22.
//

// TODO: "Maybe" button?
// TODO: disable host RSVPing?

import UIKit
import Messages
import GooglePlaces

class InviteViewController: StyleViewController {
    
    var delegate: InviteViewControllerDelegate?
    static let storyboardID = String(describing: InviteViewController.self)
    
    var myID: String!
    var mURL: URL!
    var RSVP: Bool!
    
    var maxBarHeight: CGFloat!
    
    @IBOutlet weak var promptLabel: StyleLabel!
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
        
        yesBar.backgroundColor = Colors.greyColor
        noBar.backgroundColor = Colors.greyColor
        
        yesBar.addSubview(yesCounts)
        noBar.addSubview(noCounts)
        
        yesButton.size(height: 150, textSize: 25)
        yesButton.setDeselected()
        noButton.size(height: 150, textSize: 25)
        noButton.setDeselected()
        
        loadedEvent = Event(url: mURL)
        
        decodeEvent(loadedEvent)
        
        decodeRSVPs(url: mURL)
        
        yesCounts.style(text: String(yesNum), textColor: UIColor.white, fontSize: 25)
        noCounts.style(text: String(noNum), textColor: UIColor.white, fontSize: 25)
        
        updateMaxBarHeight()
        
        NSLayoutConstraint.activate([
            //informationText.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            //informationText.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
            
            yesCounts.topAnchor.constraint(equalTo: yesBar.topAnchor, constant: 20),
            yesCounts.centerXAnchor.constraint(equalTo: yesBar.centerXAnchor),
            noCounts.topAnchor.constraint(equalTo: noBar.topAnchor, constant: 20),
            noCounts.centerXAnchor.constraint(equalTo: noBar.centerXAnchor),
            yesBar.heightAnchor.constraint(equalToConstant: maxBarHeight * CGFloat(yesNum) / CGFloat(yesNum + noNum + 1) + 50),
            noBar.heightAnchor.constraint(equalToConstant: maxBarHeight * CGFloat(noNum) / CGFloat(yesNum + noNum + 1) + 50)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print("viewDidLayoutSubviews")
        
        
    }
    
    func decodeEvent(_ event: Event) {
        
        promptLabel.style(text: "You're invited to " + event.title + "!")
        promptLabel.adjustHeight()
        
        locationLabel.text = ""
        if event.locations.count == 1 {
            let location = event.locations[0]
            var locationInfo = "Where: "
            locationInfo += location.title
            if let address = location.address {
                locationInfo += " (" + address + ")"
            }
            locationLabel.style(text: locationInfo, textColor: Colors.darkTextColor, fontSize: 18)
        }
        locationLabel.adjustHeight()
        
        var day = event.days[0]
        let times = event.times
        
        var dayAndTimeInfo = "When: "
        if times.isEmpty {
            dayAndTimeInfo += day.formatDate()
        } else {
            dayAndTimeInfo += day.formatDate(time: times[0], duration: event.duration)
        }
        dayAndTimeLabel.style(text: dayAndTimeInfo, textColor: Colors.darkTextColor, fontSize: 18)
        dayAndTimeLabel.adjustHeight()
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
        
        if yesButton.active {return}
        
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
            
            updateBars()
            
            RSVP = true

        }
        
        for (index, queryItem) in (components!.queryItems!.enumerated()){
            if (queryItem.name == "displayType") {
                components!.queryItems![index].value = "yesRSVP"
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadedEvent.createMessage(type: .canCome, url: components!.url!)
            self.dismiss()
        }
        
    }
    
    func updateMaxBarHeight() {
        maxBarHeight = yesButton.frame.minY - locationLabel.frame.maxY - 16 //250
        
    }
    
    func updateBars() {
        //updateMaxHeight()
        
        setHeight(yesBar, h: maxBarHeight * CGFloat(yesNum) / CGFloat(yesNum + noNum + 1) + 50, animateTime: 0.5)
        setHeight(noBar, h: maxBarHeight * CGFloat(noNum) / CGFloat(yesNum + noNum + 1) + 50, animateTime: 0.5)
        yesCounts.text = String(yesNum)
        noCounts.text = String(noNum)
    }
    
    
    @IBAction func noClick(_ sender: SelectionLargeHexButton) {
        
        if noButton.active {return}
        
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
            
            updateBars()
            
            RSVP = false

        }
        
        for (index, queryItem) in (components!.queryItems!.enumerated()){
            if (queryItem.name == "displayType") {
                components!.queryItems![index].value = "noRSVP"
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadedEvent.createMessage(type: .cantCome, url: components!.url!)
            self.dismiss()
        }
        
    }
}


protocol InviteViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: InviteViewController)
    
}
