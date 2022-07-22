//
//  InputEventViewController.swift
//  Hive MessagesExtension
//
//  Created by Jack Albright on 7/20/22.
//

import UIKit
import Messages

class InputEventViewController: StyleViewController {

    var delegate: InputEventViewControllerDelegate?
    static let storyboardID = String(describing: InputEventViewController.self)
    
    @IBOutlet weak var promptLabel: StyleLabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayAndTimeLabel: UILabel!
    
    @IBOutlet weak var voteTable: UITableView!
    
    @IBOutlet weak var submitButton: HexButton!
    
    let cellInsets: CGFloat = 8
    
    var myID: String!
    var mURL: URL!
    
    var loadedEvent: Event!
    
    var voteGroups: [String]!
    var voteItems: [[String]]!
    var voteTallies: [[Int]]!
    var isOpen: [Bool]!
    var voteSelections: [Int?]!
    
    
    var daysAndTimesMagicIndexes: [Int]!
    var daysAndTimesGroupIndex: Int!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadedEvent = Event(url: mURL)
        decodeEvent(loadedEvent)

        voteTable.dataSource = self
        voteTable.delegate = self
        voteTable.separatorStyle = .none
        voteTable.showsVerticalScrollIndicator = false
        voteTable.reloadData()
                
        submitButton.size(size: 150, textSize: 25)
        submitButton.style(title: "Submit")
    }
    
    func decodeEvent(_ event: Event) {
        
        promptLabel.style(text: "Join for " + event.title + "!")
        
        if event.locations.count == 1 {
            if let address = event.locations[0].address {
                locationLabel.text = event.locations[0].title + ": " + address
            } else {
                locationLabel.text = event.locations[0].title
            }
        }
        
        // 1 Day
        var day = event.days[0]
        let times = event.daysAndTimes[day]!
        
        // 1 day 0/1 time
        if times.count == 0 {
            dayAndTimeLabel.text = day.formatDate()
        } else if times.count == 1 {
            dayAndTimeLabel.text = day.formatDate(time: times[0], duration: event.duration)
        }
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        
        //TODO: Link to ConfirmViewController
        
        var loadedEvent = loadedEvent! //makes all the changes here local
        
        if !voteSelections.contains(where: {$0 == nil}) {
            for (index, voteGroup) in voteGroups.enumerated() {
                let voteIndex = voteSelections[index]!
                if voteGroup == "Location" && loadedEvent.locations.count > 1 {
                    loadedEvent.locations = [loadedEvent.locations[voteIndex]]
                } else if voteGroup == "days" { //multiple days no time
                    loadedEvent.days = [loadedEvent.days[voteIndex]]
                } else if voteGroup == "daysAndTime" { //multiple days one time
                    loadedEvent.days = [loadedEvent.days[voteIndex]]
                    loadedEvent.times = loadedEvent.daysAndTimes[loadedEvent.days[0]]!
                    loadedEvent.daysAndTimes = [loadedEvent.days[0] : loadedEvent.times]
                } else if voteGroup == "dayAndTimes" { //one day multiple times
                    loadedEvent.times = [loadedEvent.daysAndTimes[loadedEvent.days[0]]![voteIndex]]
                    loadedEvent.daysAndTimes = [loadedEvent.days[0] : loadedEvent.times]
                } else if voteGroup == "Days and Times" { //multiple days multiple times
                    var dayIndex = daysAndTimesMagicIndexes.count - 1
                    for (mIndex, mValue) in daysAndTimesMagicIndexes.enumerated() {
                        if mValue > voteIndex {
                            dayIndex = mIndex - 1
                            break
                        }
                    }
                    let timeIndex = voteIndex - daysAndTimesMagicIndexes[dayIndex]
                    loadedEvent.days = [loadedEvent.days[dayIndex]]
                    loadedEvent.times = [loadedEvent.daysAndTimes[loadedEvent.days[0]]![timeIndex]]
                    loadedEvent.daysAndTimes = [loadedEvent.days[0] : loadedEvent.times]
                }
            }
            
            let confirmVC = (storyboard?.instantiateViewController(withIdentifier: ConfirmViewController.storyboardID) as? ConfirmViewController)!
            confirmVC.event = loadedEvent
            
            self.navigationController?.pushViewController(confirmVC, animated: true)
        }
        
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        if presentationStyle == MSMessagesAppPresentationStyle.compact {
            
        } else if presentationStyle == MSMessagesAppPresentationStyle.expanded {
            
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
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
    /*
    @objc func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
    }
    */
    override func willResignActive(with conversation: MSConversation) {
        self.view.window!.rootViewController?.dismiss(animated: false)
        super.willResignActive(with: conversation)
    }
}

extension InputEventViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        voteGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isOpen[section] {
            if voteGroups[section] == "Days and Times" {
                return daysAndTimesMagicIndexes.count
            } else {
                return voteItems[section].count
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if voteGroups[indexPath.section] == "Days and Times" {
            let cell = voteTable.dequeueReusableCell(withIdentifier: InputEventDayAndTimesCell.reuseIdentifier, for: indexPath) as! InputEventDayAndTimesCell
            cell.curView = self
            cell.curIndex = indexPath.row
            var day = loadedEvent.days[indexPath.row]
            cell.dayLabel.text = day.formatDate()
            cell.duration = loadedEvent.duration
            cell.timesCollectionView.reloadData()
            return cell
        }
        let cell = voteTable.dequeueReusableCell(withIdentifier: VoteCell.reuseIdentifier, for: indexPath) as! VoteCell
        let cellView = UIView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height))
        cellView.backgroundColor = Style.lightGreyColor
        cell.voteCount.backgroundColor = Style.greyColor
        if voteSelections[indexPath.section] == indexPath.row {
            cellView.backgroundColor = Style.secondaryColor
            cell.voteCount.backgroundColor = Style.primaryColor
        }
        cell.backgroundView = cellView
        cell.label.text = voteItems[indexPath.section][indexPath.row]
        cell.counter.text = String(voteTallies[indexPath.section][indexPath.row])
        let voteMax = voteTallies.reduce(0, {x, y in max(x, y.max()!)}) + 1
        cell.voteCount.frame.size.width = CGFloat(voteTallies[indexPath.section][indexPath.row])/CGFloat(voteMax) * self.view.frame.width * 2/3
        cell.voteCount.frame.size.height = cell.contentView.frame.height - (cellInsets)
        cell.voteCount.layer.cornerRadius = cell.voteCount.frame.height/2
        //cell.voteCount.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let verticalPadding: CGFloat = cellInsets
        let maskLayer = CALayer()
        maskLayer.cornerRadius = cell.layer.cornerRadius
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
}

extension InputEventViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if voteGroups[indexPath.section] == "Days and Times" {
            // TODO: Maybe make it so that all of the times get selected?
            return
        }
        if voteSelections[indexPath.section] == indexPath.row {
            voteSelections[indexPath.section] = nil
        } else {
            voteSelections[indexPath.section] = indexPath.row
        }
        
        voteTable.reloadSections(IndexSet(integersIn: 0..<voteGroups.count), with: .fade)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
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
    }
}

class InputEventDayAndTimesCell: UITableViewCell {
    
    var curView: InputEventViewController!
    var curIndex: Int!
    
    static let reuseIdentifier = String(describing: InputEventDayAndTimesCell.self)
    
    static let cornerRadius: CGFloat = 20
    
    //var times = [(time: Time, isVoted: Bool, votes: Int)]()
    var duration: Duration? = nil
    
    let dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
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
            dayLabel.widthAnchor.constraint(equalToConstant: 45),
            
            timesCollectionView.leftAnchor.constraint(equalTo: dayLabel.rightAnchor, constant: 5),
            timesCollectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
            timesCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            timesCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
        
        timesCollectionView.layer.cornerRadius = 5
    }
}

extension InputEventDayAndTimesCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return curView.loadedEvent.daysAndTimes[curView.loadedEvent.days[curIndex]]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let magicIndex = curView.daysAndTimesMagicIndexes[curIndex] + indexPath.row
        let cell = timesCollectionView.dequeueReusableCell(withReuseIdentifier: VotingTimeCell.reuseIdentifier, for: indexPath) as! VotingTimeCell
        cell.timeLabel.text = curView.loadedEvent.daysAndTimes[curView.loadedEvent.days[curIndex]]![indexPath.row].format(duration: nil)
        cell.voteCountLabel.text = String(curView.voteTallies[curView.daysAndTimesGroupIndex][magicIndex])
        if curView.voteSelections[curView.daysAndTimesGroupIndex] == magicIndex {
            cell.backgroundColor = Style.primaryColor
            cell.timeLabel.textColor = Style.lightTextColor
        } else {
            cell.backgroundColor = Style.greyColor
            cell.timeLabel.textColor = UIColor.white
        }
        return cell
    }
    
}


extension InputEventDayAndTimesCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let magicIndex = curView.daysAndTimesMagicIndexes[curIndex] + indexPath.row
        if curView.voteSelections[curView.daysAndTimesGroupIndex] == magicIndex {
            curView.voteSelections[curView.daysAndTimesGroupIndex] = nil
        } else {
            curView.voteSelections[curView.daysAndTimesGroupIndex] = magicIndex
        }
        
        for (index, _) in curView.daysAndTimesMagicIndexes.enumerated() {
            (curView.voteTable.cellForRow(at: IndexPath(row: index, section: curView.daysAndTimesGroupIndex)) as? InputEventDayAndTimesCell)?.timesCollectionView.reloadData()
        }
        //timesCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let timeString = curView.loadedEvent.daysAndTimes[curView.loadedEvent.days[curIndex]]![indexPath.row].format(duration: nil)
        return CGSize(width: timeString.size(withAttributes: [NSAttributedString.Key.font : Style.font(size: 18)]).width + timesCollectionView.frame.height + 5, height: timesCollectionView.frame.height)
    }
}

protocol InputEventViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: InputEventViewController)
    
}
