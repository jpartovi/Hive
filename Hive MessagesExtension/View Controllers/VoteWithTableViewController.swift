//
//  VoteWithTableViewController.swift
//  Hive MessagesExtension
//
//  Created by Jack Albright on 7/13/22.
//

import UIKit
import Messages

class VoteWithTableViewController: MSMessagesAppViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: VoteWithTableViewControllerDelegate?
    static let storyboardID = "VoteWithTableViewController"
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var daysAndTimesTableView: UITableView!
    
    var daysAndTimes: [Day : [Time]] = [:]
    
    @IBOutlet weak var voteTable: UITableView!
    
    let submitButton = UIButton()
    
    let submitLabel = UILabel()
    
    var myID: String!
    var mURL: URL!
    
    var loadedEvent: Event!
    
    var voteGroups: [String] = []
    var voteItems: [[String]] = []
    var voteTallies: [[Int]] = []
    var isOpen: [Bool] = []
    var voteSelections: [[Int]] = []
    var multiSelectable: [Bool] = []
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadedEvent = Event(url: mURL)
        decodeEvent(loadedEvent)
        decodeRSVPs(url: mURL)

        voteTable.dataSource = self
        voteTable.delegate = self
        voteTable.separatorStyle = .none
        //voteTable.showsVerticalScrollIndicator = false
        voteTable.reloadData()
        
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.clipsToBounds = true
        submitButton.tintColor = Style.lightTextColor
        
        submitLabel.text = "Submit Votes"
        submitLabel.translatesAutoresizingMaskIntoConstraints = false
        submitLabel.textColor = Style.lightTextColor
        submitLabel.textAlignment = .center
        mainView.addSubview(submitButton)
        mainView.addSubview(submitLabel)
        
        
        NSLayoutConstraint.activate([ submitButton.centerXAnchor.constraint(equalTo: mainView.centerXAnchor), submitButton.topAnchor.constraint(equalTo: voteTable.bottomAnchor, constant: -30), submitButton.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -20), /*submitButton.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.8),*/ submitButton.heightAnchor.constraint(equalTo: submitButton.widthAnchor, multiplier: 0.4), submitLabel.centerXAnchor.constraint(equalTo: submitButton.centerXAnchor), submitLabel.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor), submitLabel.widthAnchor.constraint(equalTo: submitButton.widthAnchor, multiplier: 0.8), submitLabel.heightAnchor.constraint(equalTo: submitButton.heightAnchor, multiplier: 0.9)])
        
        submitButton.addTarget(self, action:#selector(pickPressed), for: UIControl.Event.touchUpInside)
        
    }
    
    func decodeEvent(_ event: Event) {
        
        if event.locations.count != 1 {
            titleLabel.text = "Poll for " + event.title
            
            if event.locations.count != 0 {
                voteGroups.append("Location")
                var allLoc: [String] = []
                for location in event.locations {
                    allLoc.append(location.title)
                }
                voteItems.append(allLoc)
                voteTallies.append([Int](repeating: 0, count: event.locations.count))
                isOpen.append(false)
                voteSelections.append([])
                multiSelectable.append(false)
            }
            
        } else {
            titleLabel.text = "Poll for " + event.title + " at " + event.locations[0].title
        }
        if event.daysAndTimes.count > 1 {
            voteGroups.append("Day/Time")
            var allDay: [String] = []
            var timeCount = 0
            for (day, dtimes) in event.daysAndTimes {
                timeCount += dtimes.count
                for time in dtimes {
                    var mutableDay = day
                    allDay.append(mutableDay.formatDate() + " @ " + time.format(duration: event.duration))
                }
            }
            voteItems.append(allDay)
            voteTallies.append([Int](repeating: 0, count: timeCount))
            isOpen.append(false)
            voteSelections.append([])
            multiSelectable.append(true)
        }
        
    }
    
    
    /*var voteGroups = ["A", "B", "C", "D (multi-select)"]
    var voteItems = [["p", "q"], ["r", "s", "t", "u"], ["x", "y", "z"], ["m", "n", "o", "p"]]
    var voteTallies = [[3, 2], [1, 0, 4, 0], [2, 1, 2], [5, 3, 1, 4]]
    var isOpen = [false, false, false, false]
    var voteSelections = [[], [], [], []] as [[Int]]
    var multiSelectable = [false, false, false, true]*/
    
    
    func decodeRSVPs(url: URL) {
        let components = URLComponents(url: url,
                resolvingAgainstBaseURL: false)
        
        var endFlag = false
        var meFlag = false
        for (_, queryItem) in (components!.queryItems!.enumerated()){
            let name = queryItem.name
            let value = queryItem.value
            
            if name == "endEvent" {
                endFlag = true
            } else if endFlag {
                
                if name == myID && value == "start" {
                    meFlag = true
                } else if name == myID && value == "end" {
                    break
                } else if meFlag {
                    voteSelections[Int(name)!].append(Int(value!)!)
                }
                
                if (value != "start") && (value != "end") {
                    voteTallies[Int(name)!][Int(value!)!] += 1
                }
                
                
            }
        }
        
        //Dummy code
        /*for (indexA, voteList) in voteItems.enumerated(){
            for _ in voteList {
                voteTallies[indexA].append(0)
            }
        }*/
        
    }
    
    
    @IBAction func pickPressed(_ sender: UIButton) {
        
        let url = prepareVoteURL()
        prepareMessage(url)
        
    }
    
    /*var voteGroups = ["A", "B", "C", "D (multi-select)"]
    var voteItems = [["p", "q"], ["r", "s", "t", "u"], ["x", "y", "z"], ["m", "n", "o", "p"]]
    var voteTallies = [[3, 2], [1, 0, 4, 0], [2, 1, 2], [5, 3, 1, 4]]
    var isOpen = [false, false, false, false]
    var voteSelections = [[], [], [], []] as [[Int]]
    var multiSelectable = [false, false, false, true]*/
    
    
    func prepareVoteURL() -> URL{
        
        var components = URLComponents(url: mURL,
                resolvingAgainstBaseURL: false)
        
        var endFlag = false
        var meFlag = false
        var startIndex = 0
        var endIndex = 0
        for (index, queryItem) in (components!.queryItems!.enumerated()){
            let name = queryItem.name
            let value = queryItem.value
            
            if name == "endEvent" {
                endFlag = true
            } else if endFlag {
                
                if name == myID && value == "start" {
                    startIndex = index
                    meFlag = true
                } else if name == myID && value == "end" {
                    endIndex = index
                    break
                }
                
            }
        }
        
        var newItems: [URLQueryItem] = []
        for (indexA, voteList) in voteSelections.enumerated(){
            for (_, oneVote) in voteList.enumerated(){
                newItems.append(URLQueryItem(name: String(indexA), value: String(oneVote)))
            }
        }
        
        
        if meFlag {
            newItems = Array((components?.queryItems!)!.prefix(through: startIndex)) + newItems + Array((components?.queryItems!)!.suffix(from: endIndex))
            components?.queryItems = newItems
        } else {
            components?.queryItems! += [URLQueryItem(name: myID, value: "start")] + newItems + [URLQueryItem(name: myID, value: "end")]
        }
        
        return (components?.url!)!
    }
    
    func prepareMessage(_ url: URL) {
        
        guard let conversation = MessagesViewController.conversation else { fatalError("Received nil conversation") }

        //let message = MSMessage(session: (conversation.selectedMessage?.session)!)
        let session = MSSession()
        let message = MSMessage(session: session)

        let layout = MSMessageTemplateLayout()

        message.layout = layout
        message.url = url
        
        conversation.insert(message)
        //conversation.insertText(url.absoluteString)
        self.requestPresentationStyle(.compact)
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        if presentationStyle == MSMessagesAppPresentationStyle.compact {
            
        } else if presentationStyle == MSMessagesAppPresentationStyle.expanded {
            
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        submitButton.setImage(UIImage(named: "SelectedLongHex")?.size(width: submitButton.frame.width, height: submitButton.frame.height), for: UIControl.State.selected)
        submitButton.setImage(UIImage(named: "LongHex")?.size(width: submitButton.frame.width, height: submitButton.frame.height), for: UIControl.State.normal)
        
        submitLabel.font = submitLabel.font.withSize(submitLabel.frame.height * 3/10)

        
        
    }
    
    
    
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return voteGroups.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isOpen[section] {
            return voteItems[section].count
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: VoteCell.reuseIdentifier, for: indexPath) as! VoteCell
        
        let cellView = UIView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height))
        
        
        cellView.backgroundColor = Style.lightGreyColor
        cell.voteCount.backgroundColor = Style.greyColor
        
        for selection in voteSelections[indexPath.section] {
            
            if selection == indexPath.row {
                cellView.backgroundColor = Style.secondaryColor
                cell.voteCount.backgroundColor = Style.primaryColor
            }
        }
        
        cell.backgroundView = cellView
        
        cell.label.text = voteItems[indexPath.section][indexPath.row]
        cell.counter.text = String(voteTallies[indexPath.section][indexPath.row])
        
        let voteMax = voteTallies.reduce(0, {x, y in max(x, y.max()!)}) + 1
        
        
        cell.voteCount.frame.size.width = CGFloat(voteTallies[indexPath.section][indexPath.row])/CGFloat(voteMax) * mainView.frame.width * 2/3
        
        cell.voteCount.frame.size.height = cell.contentView.frame.height
        cell.voteCount.layer.cornerRadius = cell.voteCount.frame.height/2
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return voteGroups[section]
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        return footerView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        headerView.layer.cornerRadius = headerView.frame.height/2
        headerView.backgroundColor = Style.lightTextColor
        headerView.tag = section
        
        headerView.layer.borderWidth = 3
        headerView.layer.borderColor = Style.tertiaryColor.cgColor
        
        let headerString = UILabel(frame: CGRect(x: 13, y: 10, width: tableView.frame.size.width-10, height: 30))
        headerString.text = voteGroups[section]
        headerView.addSubview(headerString)
        
        
        let headerSelection = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width-20, height: 30))
        
        if multiSelectable[section] {
            
            var tempText = ""
            
            var firstItem = true
            
            for (vIndex, voteItem) in
                    voteItems[section].enumerated() {
                
                if voteSelections[section].contains(vIndex) {
                    
                    if firstItem {
                        tempText = voteItem
                        firstItem = false
                    } else {
                        tempText = tempText + ", " + voteItem
                    }
                }
            }
            
            headerSelection.text = tempText
            
        } else if voteSelections[section] != [] {
            headerSelection.text = voteItems[section][voteSelections[section][0]]
        }
        
        headerSelection.textAlignment = NSTextAlignment.right
        headerView.addSubview(headerSelection)
        
        let headerTapped = UITapGestureRecognizer(target: self, action: #selector(sectionHeaderTapped))
        headerView.addGestureRecognizer(headerTapped)
        
        let headerTouchDown = UILongPressGestureRecognizer(target: self, action: #selector(sectionHeaderTouchDown))
        headerTouchDown.minimumPressDuration = 0
        headerView.addGestureRecognizer(headerTouchDown)
        
        return headerView
    }
    
    @objc func sectionHeaderTouchDown(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            
            let shadeView = UIView(frame: CGRect(x: 0, y: 0, width: recognizer.view!.frame.width, height: recognizer.view!.frame.height))
            shadeView.layer.cornerRadius = shadeView.frame.height/2
            shadeView.backgroundColor = Style.greyColor
            shadeView.layer.borderWidth = 3
            shadeView.layer.borderColor = Style.greyColor.cgColor
            shadeView.alpha = 0.5
            recognizer.view!.addSubview(shadeView)
            
        } else if recognizer.state == .ended {
            
            let indexPath = NSIndexPath(row: 0, section: recognizer.view!.tag)
            if (indexPath.row == 0) {
                
                isOpen[indexPath.section] = !isOpen[indexPath.section]
                let range = NSMakeRange(indexPath.section, 1)
                let sectionToReload = NSIndexSet(indexesIn: range)
                voteTable.reloadSections(sectionToReload as IndexSet, with:UITableView.RowAnimation.fade)
            }
        }
    }
    
    @objc func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if voteSelections[indexPath.section].contains(indexPath.row) {
            
            voteSelections[indexPath.section] = voteSelections[indexPath.section].filter {$0 != indexPath.row}
            
            voteTallies[indexPath.section][indexPath.row] = voteTallies[indexPath.section][indexPath.row] - 1
        } else {
            
            if !multiSelectable[indexPath.section] && voteSelections[indexPath.section] != [] {
                
                voteTallies[indexPath.section][voteSelections[indexPath.section][0]] = voteTallies[indexPath.section][voteSelections[indexPath.section][0]] - 1
                
                voteSelections[indexPath.section] = []
                
                
            }
            
            voteSelections[indexPath.section].append(indexPath.row)
            voteTallies[indexPath.section][indexPath.row] = voteTallies[indexPath.section][indexPath.row] + 1
        }
        
        voteTable.reloadSections(IndexSet(integersIn: 0..<voteGroups.count), with: .fade)
    }
}


protocol VoteWithTableViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: VoteWithTableViewController)
    
}
