//
//  VoteResultsViewController.swift
//  Hive MessagesExtension
//
//  Created by Jack Albright on 7/20/22.
//

import UIKit
import Messages

class VoteResultsViewController: StyleViewController {

    static let storyboardID = String(describing: VoteResultsViewController.self)
    var delegate: VoteResultsViewControllerDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var promptLabel: StyleLabel!
    @IBOutlet weak var locationLabel: StyleLabel!
    @IBOutlet weak var dayAndTimeLabel: StyleLabel!
    
    @IBOutlet weak var voteTableView: UITableView!
    @IBOutlet weak var voteTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var instructionsLabel: StyleLabel!
    @IBOutlet weak var submitButton: HexButton!
    
    let cellInsets: CGFloat = 8
    
    var myID: String!
    var mURL: URL!
    var isHost: Bool = false
    
    var loadedEvent: Event!
    
    var voteGroups: [String] = []
    var voteItems: [[String]] = []
    var voteTallies: [[Int]] = []
    var isOpen: [Bool] = []
    var voteSelections: [Int?] = []
    var multiSelectable: [Bool] = []
    
    var votesChanged = false
    
    var daysAndTimesMagicIndexes: [Int] = []
    var daysAndTimesGroupIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instructionsLabel.style(text: "Create your invite from poll results", textColor: Colors.darkTextColor, fontSize: 18)
        instructionsLabel.adjustHeight()
        
        loadedEvent = Event(url: mURL)
        decodeEvent(loadedEvent)
        decodeRSVPs(url: mURL)

        voteTableView.dataSource = self
        voteTableView.delegate = self
        voteTableView.separatorStyle = .none
        voteTableView.showsVerticalScrollIndicator = false
        voteTableView.reloadData()
        voteTableView.setBackgroundColor()
        
        voteTableView.rowHeight = UITableView.automaticDimension
                
        submitButton.size(height: 150, textSize: 25)
        submitButton.grey(title: "Create\nInvite")
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateTableViewHeight()
        //addHexFooter()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        self.voteTableView.reloadRows(at: self.voteTableView.indexPathsForVisibleRows!, with: .none)
        self.voteTableView.layoutSubviews()
        self.updateTableViewHeight()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // sometimes glitchy and doesn't fully show
        scrollAnimation()
    }
    
    func scrollAnimation() {
        scrollView.scrollToBottom(animated: false)
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func updateTableViewHeight() {
        
        self.voteTableViewHeightConstraint.constant = self.voteTableView.contentSize.height
        var height: CGFloat = 0
        for subview in scrollView.subviews {
            height += subview.frame.height
            height += 8
        }
        height -= 8
        scrollView.contentSize = CGSize(width: scrollView.frame.width/*self.view.frame.width - (2 * 16)*/, height: height)
    }
    
    func decodeEvent(_ event: Event) {
        
        promptLabel.style(text: "Finalize Event")
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
        } else if event.locations.count > 1 {
            voteGroups.append("locations")
            var allLoc: [String] = []
            for location in event.locations {
                allLoc.append(location.title)
            }
            voteItems.append(allLoc)
            voteTallies.append([Int](repeating: 0, count: event.locations.count))
            isOpen.append(true)
            //voteSelections.append([])
            multiSelectable.append(false)
        }
        
        dayAndTimeLabel.text = ""
        
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
                voteGroups.append("daysAndTimes")
                voteItems.append([String](repeating: "", count: dayTimeCount)) //not needed with grid view
                voteTallies.append([Int](repeating: 0, count: dayTimeCount))
                isOpen.append(true)
                //voteSelections.append([])
                multiSelectable.append(false)
                return
            }
            
            // Multiple days no time
            if event.daysAndTimes[event.days[0]]!.isEmpty {
                // ADD DAY: day.formatDate()
                
                voteGroups.append("days")
                var days = [String]()
                for var day in event.days {
                    days.append(day.formatDate())
                }
                voteItems.append(days)
                voteTallies.append([Int](repeating: 0, count: event.days.count))
                isOpen.append(true)
                //voteSelections.append([])
                multiSelectable.append(true)
                return
            } else {
                
                // Multiple days 1 time
                voteGroups.append("daysAndTime")
                var daysAndTime = [String]()
                for var day in event.days {
                    daysAndTime.append(day.formatDate(time: event.daysAndTimes[day]![0], duration: event.duration))
                }
                voteItems.append(daysAndTime)
                voteTallies.append([Int](repeating: 0, count: event.days.count))
                isOpen.append(true)
                //voteSelections.append([])
                multiSelectable.append(true)
                return
            }
        }
        
        // 1 Day
        var day = event.days[0]
        let times = event.daysAndTimes[day]!
        
        // 1 day 0/1 time
        if times.count <= 1 {
        
        } else {
            // 1 day multiple times
            voteGroups.append("dayAndTimes")
            var dayAndTimes = [String]()
            for time in times {
                dayAndTimes.append(day.formatDate(time: time, duration: event.duration))
            }
            voteItems.append(dayAndTimes)
            voteTallies.append([Int](repeating: 0, count: times.count))
            isOpen.append(true)
            //voteSelections.append([])
            multiSelectable.append(true)
        }
        
        locationLabel.adjustHeight()
        dayAndTimeLabel.adjustHeight()
    }
    
    func decodeRSVPs(url: URL) {
        let components = URLComponents(url: url,
                resolvingAgainstBaseURL: false)
        
        var endFlag = false
        var meFlag = false
        for (_, queryItem) in (components!.queryItems!.enumerated()){
            let name = queryItem.name
            let value = queryItem.value
            
            if name == "hostID" && value == myID {
                isHost = true
            } else if name == "endEvent" {
                endFlag = true
            } else if endFlag {
                
                if name == myID && value == "start" {
                    meFlag = true
                } else if name == myID && value == "end" {
                    break
                } else if meFlag {
                    //voteSelections[Int(name)!].append(Int(value!)!)
                }
                
                if (value != "start") && (value != "end") {
                    voteTallies[Int(name)!][Int(value!)!] += 1
                }
            }
        }
        voteSelections = [Int?](repeating: nil, count: voteGroups.count)
    }
    
    func updateSubmitButton() {
        /*
        if initialVoteTallies == voteTallies {
            submitButton.grey(title: "Add Votes")
            votesChanged = false
        } else {
            submitButton.color(title: "Add Votes")
            votesChanged = true
        }
         */
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        if presentationStyle == MSMessagesAppPresentationStyle.compact {
            
        } else if presentationStyle == MSMessagesAppPresentationStyle.expanded {
            
        }
    }
    
    @objc func sectionHeaderTouchDown(recognizer: UILongPressGestureRecognizer) {
        // This disables the opening and closing of vote groups
        return
        
        if recognizer.state == .began {
            
            let shadeView = UIView(frame: CGRect(x: 0, y: 0, width: recognizer.view!.frame.width, height: recognizer.view!.frame.height))
            shadeView.layer.cornerRadius = shadeView.frame.height/2
            shadeView.backgroundColor = Colors.greyColor
            shadeView.layer.borderWidth = 3
            shadeView.layer.borderColor = Colors.greyColor.cgColor
            shadeView.alpha = 0.5
            recognizer.view!.addSubview(shadeView)
            
        } else if recognizer.state == .ended {
            
            let indexPath = NSIndexPath(row: 0, section: recognizer.view!.tag)
            if (indexPath.row == 0) {
                
                isOpen[indexPath.section] = !isOpen[indexPath.section]
                let range = NSMakeRange(indexPath.section, 1)
                let sectionToReload = NSIndexSet(indexesIn: range)
                voteTableView.reloadSections(sectionToReload as IndexSet, with:UITableView.RowAnimation.fade)
                if indexPath.section == daysAndTimesGroupIndex {
                    for (index, _) in daysAndTimesMagicIndexes.enumerated() {
                        (voteTableView.cellForRow(at: IndexPath(row: index, section: daysAndTimesGroupIndex)) as? VotingDayAndTimesCell)?.timesCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    override func willResignActive(with conversation: MSConversation) {
        self.view.window!.rootViewController?.dismiss(animated: false)
        super.willResignActive(with: conversation)
    }
    
    func updateSubmitButtonStatus() {
        if voteSelections.contains(where: {$0 == nil}) {
            submitButton.grey(title: "Done")
        } else {
            submitButton.color(title: "Done")
        }
        
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        
        var loadedEvent = loadedEvent! //makes all the changes here local
        
        if !voteSelections.contains(where: {$0 == nil}) {
            var eventForInvite = loadedEvent
            for (index, voteGroup) in voteGroups.enumerated() {
                let voteIndex = voteSelections[index]!
                switch voteGroup {
                case "locations":
                    if loadedEvent.locations.count > 1 {
                        eventForInvite.locations = [loadedEvent.locations[voteIndex]]
                    }
                case "days":
                    eventForInvite.days = [loadedEvent.days[voteIndex]]
                case "daysAndTime":
                    eventForInvite.days = [loadedEvent.days[voteIndex]]
                    eventForInvite.times = loadedEvent.daysAndTimes[eventForInvite.days[0]]!
                    eventForInvite.daysAndTimes = [eventForInvite.days[0] : eventForInvite.times]
                case "dayAndTimes":
                    eventForInvite.times = [loadedEvent.daysAndTimes[eventForInvite.days[0]]![voteIndex]]
                    eventForInvite.daysAndTimes = [loadedEvent.days[0] : eventForInvite.times]
                case "daysAndTimes":
                    var dayIndex = daysAndTimesMagicIndexes.count - 1
                    for (mIndex, mValue) in daysAndTimesMagicIndexes.enumerated() {
                        if mValue > voteIndex {
                            dayIndex = mIndex - 1
                            break
                        }
                    }
                    let timeIndex = voteIndex - daysAndTimesMagicIndexes[dayIndex]
                    eventForInvite.days = [loadedEvent.days[dayIndex]]
                    eventForInvite.times = [loadedEvent.daysAndTimes[eventForInvite.days[0]]![timeIndex]]
                    eventForInvite.daysAndTimes = [eventForInvite.days[0] : eventForInvite.times]
                default:
                    continue
                }
            }
            
            let confirmVC = (storyboard?.instantiateViewController(withIdentifier: ConfirmViewController.storyboardID) as? ConfirmViewController)!
            confirmVC.event = eventForInvite
            confirmVC.fromVoteResults = true
            
            self.navigationController?.pushViewController(confirmVC, animated: true)
        }
    }
}

extension VoteResultsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        voteGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isOpen[section] {
            if voteGroups[section] == "daysAndTimes" {
                return daysAndTimesMagicIndexes.count
            } else {
                return voteItems[section].count
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if voteGroups[indexPath.section] == "daysAndTimes" {
            let cell = voteTableView.dequeueReusableCell(withIdentifier: VoteResultsDayAndTimesCell.reuseIdentifier, for: indexPath) as! VoteResultsDayAndTimesCell
            cell.curView = self
            cell.curIndex = indexPath.row
            var day = loadedEvent.days[indexPath.row]
            cell.dayLabel.style(text: day.formatDate(), textColor: Colors.darkTextColor, fontSize: 18)
            cell.duration = loadedEvent.duration
            cell.timesCollectionView.reloadData()
            return cell
        }
        let cell = voteTableView.dequeueReusableCell(withIdentifier: VoteCell.reuseIdentifier, for: indexPath) as! VoteCell
        let cellView = UIView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height))
        cellView.backgroundColor = Colors.lightGreyColor
        cell.voteCount.backgroundColor = Colors.greyColor
        if voteSelections[indexPath.section] == indexPath.row {
            cellView.backgroundColor = Colors.secondaryColor
            cell.voteCount.backgroundColor = Colors.primaryColor
        }
        cell.backgroundView = cellView
        cell.label.text = voteItems[indexPath.section][indexPath.row]
        cell.counter.text = String(voteTallies[indexPath.section][indexPath.row])
        let voteMax = voteTallies.reduce(0, {x, y in max(x, y.max()!)}) + 1
        //cell.voteCount.frame.size.width = CGFloat(voteTallies[indexPath.section][indexPath.row])/CGFloat(voteMax) * self.view.frame.width * 2/3
        //cell.voteCount.frame.size.height = cell.contentView.frame.height - (cellInsets)
        
        let width = CGFloat(voteTallies[indexPath.section][indexPath.row])/CGFloat(voteMax) * self.view.frame.width * 2/3
        let height = cell.contentView.frame.height - cellInsets
        cell.voteCount.frame = CGRect(x: 0, y: cellInsets, width: width, height: height)
        cell.voteCount.layer.cornerRadius = cell.voteCount.frame.height/2
        //cell.voteCount.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let verticalPadding: CGFloat = cellInsets
        let maskLayer = CALayer()
        maskLayer.cornerRadius = cell.layer.cornerRadius
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).inset(by: UIEdgeInsets(top: verticalPadding, left: 0, bottom: 0, right: 0))
        cell.layer.mask = maskLayer
    }
}

extension VoteResultsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if voteGroups[indexPath.section] == "daysAndTimes" {
            return
        }
        if voteSelections[indexPath.section] == indexPath.row {
            voteSelections[indexPath.section] = nil
        } else {
            voteSelections[indexPath.section] = indexPath.row
        }
        
        voteTableView.reloadSections(IndexSet(integersIn: 0..<voteGroups.count), with: .fade)
        
        updateSubmitButtonStatus()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        voteGroups[section]
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        return footerView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        /*
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        headerView.layer.cornerRadius = headerView.frame.height/2
        headerView.backgroundColor = Style.primaryColor
        headerView.tag = section
        
        headerView.layer.borderWidth = 3
        headerView.layer.borderColor = Style.secondaryColor.cgColor
        
        let headerString = UILabel(frame: CGRect(x: 13, y: 10, width: tableView.frame.size.width-10, height: 30))
        headerString.text = voteGroups[section]
        headerString.textColor = Style.lightTextColor
        headerView.addSubview(headerString)
        
        
        let headerSelection = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width-20, height: 30))
        
        var selectedItems = [String]()
        for (index, voteItem) in voteItems[section].enumerated() {
            if voteSelections[section] == index {
                selectedItems.append(voteItem)
            }
        }
        headerSelection.text = Style.commaList(items: selectedItems)//tempText
        
        headerSelection.textAlignment = NSTextAlignment.right
        headerView.addSubview(headerSelection)
        
        //let headerTapped = UITapGestureRecognizer(target: self, action: #selector(sectionHeaderTapped))
        //headerView.addGestureRecognizer(headerTapped)
        
        let headerTouchDown = UILongPressGestureRecognizer(target: self, action: #selector(sectionHeaderTouchDown))
        headerTouchDown.minimumPressDuration = 0
        headerView.addGestureRecognizer(headerTouchDown)
        
        return headerView
         */
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        headerView.layer.cornerRadius = headerView.frame.height/2
        headerView.backgroundColor = Colors.tertiaryColor
        headerView.tag = section
        
        headerView.layer.borderWidth = 3
        headerView.layer.borderColor = Colors.tertiaryColor.cgColor
        
        let headerTitle = UILabel(frame: CGRect(x: 13, y: 10, width: tableView.frame.size.width-10, height: 30))
        
        let headerString: String
        switch voteGroups[section] {
        case "daysAndTimes":
            headerString = "Choose the final time"
        case "daysAndTime":
            headerString = "Choose the final time"
        case "dayAndTimes":
            headerString = "Choose the final time"
        case "days":
            headerString = "Choose the final day"
        case "locations":
            headerString = "Choose the final location"
        default:
            headerString = "Choose the winner"
        }
        headerTitle.text = headerString
        headerTitle.textColor = UIColor.white
        headerView.addSubview(headerTitle)
        
        
        let headerSelection = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width-20, height: 30))
        /*
        if voteSelections[section] != [] {
            headerSelection.text = voteItems[section][voteSelections[section][0]]
        }
        */
        headerSelection.textAlignment = NSTextAlignment.right
        headerSelection.textColor = Colors.lightTextColor
        headerView.addSubview(headerSelection)
        
        //let headerTapped = UITapGestureRecognizer(target: self, action: #selector(sectionHeaderTapped))
        //headerView.addGestureRecognizer(headerTapped)
        
        let headerTouchDown = UILongPressGestureRecognizer(target: self, action: #selector(sectionHeaderTouchDown))
        headerTouchDown.minimumPressDuration = 0
        headerView.addGestureRecognizer(headerTouchDown)
        
        return headerView
    }
}

class VoteResultsDayAndTimesCell: UITableViewCell {
    
    var curView: VoteResultsViewController!
    var curIndex: Int!
    
    static let reuseIdentifier = String(describing: VoteResultsDayAndTimesCell.self)
    
    static let cornerRadius: CGFloat = 20
    
    //var times = [(time: Time, isVoted: Bool, votes: Int)]()
    var duration: Duration? = nil
    
    let dayLabel: StyleLabel = {
        let label = StyleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
     
    let timesCollectionView: UICollectionView = {
        let layout = TimesCollectionViewLayout()
        //layout.itemSize = CGSize(width: 105, height: 30)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.showsHorizontalScrollIndicator = false
        //collectionView.isPagingEnabled = true
        collectionView.register(VotingTimeCell.self, forCellWithReuseIdentifier: VotingTimeCell.reuseIdentifier)
        collectionView.backgroundColor = Colors.lightGreyColor
        return collectionView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = self.frame.height / 2
        
        self.backgroundColor = Colors.lightGreyColor
        
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
            dayLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 4),
            dayLabel.widthAnchor.constraint(equalToConstant: 90),
            
            timesCollectionView.leftAnchor.constraint(equalTo: dayLabel.rightAnchor, constant: 5),
            timesCollectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            timesCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 6 + 8),
            timesCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
        
        timesCollectionView.layer.cornerRadius = 5
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        self.contentView.frame = self.bounds
        self.contentView.layoutIfNeeded()
        self.contentView.layoutSubviews()
        var tCVcontentSize = self.timesCollectionView.contentSize
        tCVcontentSize.height += 20
        tCVcontentSize.height = max(tCVcontentSize.height, 50)
        return tCVcontentSize
    }
    
}

extension VoteResultsDayAndTimesCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return curView.loadedEvent.daysAndTimes[curView.loadedEvent.days[curIndex]]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let magicIndex = curView.daysAndTimesMagicIndexes[curIndex] + indexPath.row
        let cell = timesCollectionView.dequeueReusableCell(withReuseIdentifier: VotingTimeCell.reuseIdentifier, for: indexPath) as! VotingTimeCell
        cell.timeLabel.text = curView.loadedEvent.daysAndTimes[curView.loadedEvent.days[curIndex]]![indexPath.row].format(duration: nil)
        cell.voteCountLabel.text = String(curView.voteTallies[curView.daysAndTimesGroupIndex][magicIndex])
        if curView.voteSelections[curView.daysAndTimesGroupIndex] == magicIndex {
            cell.backgroundColor = Colors.primaryColor
            cell.timeLabel.textColor = Colors.lightTextColor
        } else {
            cell.backgroundColor = Colors.greyColor
            cell.timeLabel.textColor = UIColor.white
        }
        return cell
    }
    
}


extension VoteResultsDayAndTimesCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let magicIndex = curView.daysAndTimesMagicIndexes[curIndex] + indexPath.row
        if curView.voteSelections[curView.daysAndTimesGroupIndex] == magicIndex {
            curView.voteSelections[curView.daysAndTimesGroupIndex] = nil
        } else {
            curView.voteSelections[curView.daysAndTimesGroupIndex] = magicIndex
        }
        
        for (index, _) in curView.daysAndTimesMagicIndexes.enumerated() {
            (curView.voteTableView.cellForRow(at: IndexPath(row: index, section: curView.daysAndTimesGroupIndex)) as? VoteResultsDayAndTimesCell)?.timesCollectionView.reloadData()
        }
        curView.updateSubmitButtonStatus()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let timeString = curView.loadedEvent.daysAndTimes[curView.loadedEvent.days[curIndex]]![indexPath.row].format(duration: nil)
        return CGSize(width: timeString.size(withAttributes: [NSAttributedString.Key.font : Format.font(size: 18)]).width + 35, height: 30)
    }
}

protocol VoteResultsViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: VoteResultsViewController)
    
}
