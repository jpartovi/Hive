//
//  VoteWithTableViewController.swift
//  Hive MessagesExtension
//
//  Created by Jack Albright on 7/13/22.
//

import UIKit
import Messages

class VoteWithTableViewController: MSMessagesAppViewController {
    
    var delegate: VoteWithTableViewControllerDelegate?
    static let storyboardID = String(describing: VoteWithTableViewController.self)
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var daysAndTimesTableView: UITableView!
    
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
    
    
    var daysAndTimesMagicIndexes: [Int] = []
    var daysAndTimesGroupIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadedEvent = Event(url: mURL)
        decodeEvent(loadedEvent)
        decodeRSVPs(url: mURL)
    
        daysAndTimesTableView.dataSource = self
        daysAndTimesTableView.delegate = self
        daysAndTimesTableView.reloadData()

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
    
        
        //Hides daysAndTimesTableView, remove this view later
        daysAndTimesTableView.isHidden = true
    
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
        
        // EVERY COMBO
        /*
                        multiple times | 1 time | no times
         multiple days      *GRID       *string   *string
         1 day              string        label     label
         */
        
        // Multiple days
        if event.days.count > 1 {
            var mulDayMulTimeFlag = false
            var dayTimeCount = 0
            for day in event.days {
                let times = event.daysAndTimes[day]!
                daysAndTimesMagicIndexes.append(dayTimeCount)
                dayTimeCount += times.count
                if times.count > 1 {
                    mulDayMulTimeFlag = true
                }
            }
            
            // Multiple days multiple times
            if mulDayMulTimeFlag {
                // GRID LAYOUT
                daysAndTimesGroupIndex = voteGroups.count
                // name the voteGroups entry "daysAndTimes"
                voteGroups.append("daysAndTimes")
                voteItems.append([String](repeating: "-", count: dayTimeCount)) //not needed with grid view
                voteTallies.append([Int](repeating: 0, count: dayTimeCount))
                isOpen.append(false)
                voteSelections.append([])
                multiSelectable.append(false)
                return
            }
            
            // Multiple days no time
            if event.daysAndTimes[event.days[0]]!.isEmpty {
                for day in event.days {
                    // ADD DAY: day.formatDate()
                    
                    voteGroups.append("days")
                    var days = [String]()
                    for var day in event.days {
                        days.append(day.formatDate())
                    }
                    voteItems.append(days)
                    voteTallies.append([Int](repeating: 0, count: event.days.count))
                    isOpen.append(false)
                    voteSelections.append([])
                    multiSelectable.append(true)
                    return
                }
            } else {
                
                // Multiple days 1 time
                for (day, times) in event.daysAndTimes {
                    // ADD DAY + TIME: day.formatDate() + " @ " + times[0].format(duration: event.duration)
                    voteGroups.append("daysAndTime")
                    var daysAndTime = [String]()
                    for var day in event.days {
                        daysAndTime.append(day.formatDate() + " @ " + event.daysAndTimes[day]![0].format(duration: event.duration))
                    }
                    voteItems.append(daysAndTime)
                    voteTallies.append([Int](repeating: 0, count: event.days.count))
                    isOpen.append(false)
                    voteSelections.append([])
                    multiSelectable.append(true)
                    return
                }
            }
        }
        
        // 1 Day
        var day = event.days[0]
        
        // 1 day 0/1 time
        if event.daysAndTimes[day]!.count <= 1 {
            // Put day/day+time in a label
            return
        } else {
            // ADD DAY + TIME: day.formatDate() + " @ " + time.format(duration: event.duration)
            let times = event.daysAndTimes[day]!
            voteGroups.append("dayAndTimes")
            var dayAndTimes = [String]()
            for time in times {
                dayAndTimes.append(day.formatDate() + " @ " + time.format(duration: event.duration))
            }
            voteItems.append(dayAndTimes)
            voteTallies.append([Int](repeating: 0, count: times.count))
            isOpen.append(false)
            voteSelections.append([])
            multiSelectable.append(true)

            return
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
    
   
}

extension VoteWithTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView {
        case daysAndTimesTableView:
            return 1
        case voteTable:
            return voteGroups.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
        case daysAndTimesTableView:
            return loadedEvent.daysAndTimes.count
        case voteTable:
            if isOpen[section] {
                if voteGroups[section] == "daysAndTimes" {
                    return daysAndTimesMagicIndexes.count
                } else {
                    return voteItems[section].count
                }
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        switch tableView {
        case daysAndTimesTableView:
            let cell = daysAndTimesTableView.dequeueReusableCell(withIdentifier: VotingDayAndTimesCell.reuseIdentifier, for: indexPath) as! VotingDayAndTimesCell
            var day = loadedEvent.days[indexPath.row]
            cell.dayLabel.text = day.formatDate()
            for (index, time) in loadedEvent.daysAndTimes[day]!.enumerated() {
                let flatIndex = daysAndTimesMagicIndexes[indexPath.row] + index
                
                print(daysAndTimesMagicIndexes)
                print(voteSelections)
                print(voteTallies)
                
                cell.times.append((time, voteSelections[daysAndTimesGroupIndex].contains(flatIndex), voteTallies[daysAndTimesGroupIndex][flatIndex])) // TODO: need to laod previous votes here (replace "false" and "0")
            }
            cell.duration = loadedEvent.duration
            return cell
        case voteTable:
            if voteGroups[indexPath.section] == "daysAndTimes" {
                let cell = voteTable.dequeueReusableCell(withIdentifier: VotingDayAndTimesCell.reuseIdentifier, for: indexPath) as! VotingDayAndTimesCell
                var day = loadedEvent.days[indexPath.row]
                cell.dayLabel.text = day.formatDate()
                for (index, time) in loadedEvent.daysAndTimes[day]!.enumerated() {
                    let flatIndex = daysAndTimesMagicIndexes[indexPath.row] + index
                    cell.times.append((time, voteSelections[indexPath.section].contains(flatIndex), voteTallies[indexPath.section][flatIndex])) // TODO: need to laod previous votes here (replace "false" and "0")
                }
                cell.duration = loadedEvent.duration
                return cell
            }
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
        default:
            // TODO: This is not right, there should be some sort of error message here
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        switch tableView {
        case daysAndTimesTableView:
            let verticalPadding: CGFloat = 8
            let maskLayer = CALayer()
            maskLayer.cornerRadius = VotingDayAndTimesCell.cornerRadius
            maskLayer.backgroundColor = UIColor.black.cgColor
            maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
            cell.layer.mask = maskLayer
        case voteTable:
            break
        default:
            break
        }
        
    }
}

extension VoteWithTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case daysAndTimesTableView:
            break
        case voteTable:
            
            if voteGroups[indexPath.section] == "daysAndTimes" {
                // TODO: Maybe make it so that all of the times get selected?
                return
            }
        
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
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case daysAndTimesTableView:
            return 50
        case voteTable:
            return 50
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch tableView {
        case daysAndTimesTableView:
            return nil
        case voteTable:
            return voteGroups[section]
        default:
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch tableView {
        case daysAndTimesTableView:
            return 0
        case voteTable:
            return 50
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch tableView {
        case daysAndTimesTableView:
            return 0
        case voteTable:
            return 10
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch tableView {
        case daysAndTimesTableView:
            return nil
        case voteTable:
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
            return footerView
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch tableView {
        case daysAndTimesTableView:
            return nil
        case voteTable:
        
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
        default:
            return nil
        }
    }
}

class VotingDayAndTimesCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: VotingDayAndTimesCell.self)
    
    static let cornerRadius: CGFloat = 20
    
    var times = [(time: Time, isVoted: Bool, votes: Int)]()
    var duration: Duration? = nil
    
    let dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let timesCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 105, height: 30)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.register(VotingTimeCell.self, forCellWithReuseIdentifier: VotingTimeCell.reuseIdentifier)
        collectionView.backgroundColor = Style.lightGreyColor
        return collectionView
    }()
    
    // TODO: Add a delete button??
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        
        self.backgroundColor = Style.lightGreyColor
        
        contentView.addSubview(timesCollectionView)
        contentView.addSubview(dayLabel)
    
        timesCollectionView.dataSource = self
        timesCollectionView.delegate = self
        timesCollectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let inset: CGFloat = 10

        NSLayoutConstraint.activate([
            dayLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            dayLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            timesCollectionView.leftAnchor.constraint(equalTo: dayLabel.rightAnchor, constant: inset),
            timesCollectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            timesCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            timesCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
        
        timesCollectionView.layer.cornerRadius = 5
    }
}

extension VotingDayAndTimesCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        times.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = timesCollectionView.dequeueReusableCell(withReuseIdentifier: VotingTimeCell.reuseIdentifier, for: indexPath) as! VotingTimeCell
        cell.timeLabel.text = times[indexPath.row].time.format(duration: nil)//duration)
        cell.voteCountLabel.text = String(times[indexPath.row].votes)
        if times[indexPath.row].isVoted {
            cell.backgroundColor = Style.primaryColor
            cell.timeLabel.textColor = Style.lightTextColor
        } else {
            cell.backgroundColor = Style.greyColor
            cell.timeLabel.textColor = UIColor.white
        }
        return cell
    }
    
    
}

extension VotingDayAndTimesCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if times[indexPath.row].isVoted {
            times[indexPath.row].isVoted = false
            times[indexPath.row].votes -= 1
        } else {
            times[indexPath.row].isVoted = true
            times[indexPath.row].votes += 1
        }
        
        timesCollectionView.reloadData()
    }
}

class VotingTimeCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: VotingTimeCell.self)
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let voteCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Style.lightGreyColor
        label.textColor = Style.greyColor
        label.textAlignment = .center
        label.text = "1"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Apply rounded corners
        self.layer.cornerRadius = 5
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(voteCountLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        self.contentView.layer.cornerRadius = 5
        
        let inset: CGFloat = 5

        NSLayoutConstraint.activate([
            timeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            voteCountLabel.heightAnchor.constraint(equalToConstant: self.frame.height - (inset * 2)),
            voteCountLabel.widthAnchor.constraint(equalTo: voteCountLabel.heightAnchor),
            voteCountLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            voteCountLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        voteCountLabel.layer.masksToBounds = true
        voteCountLabel.layer.cornerRadius = voteCountLabel.frame.height / 2
    }
}


protocol VoteWithTableViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: VoteWithTableViewController)
    
}
