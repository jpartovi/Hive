//
//  ConfirmViewSelector.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/3/22.
//

import Foundation
import UIKit
import Messages
import GooglePlaces

class ConfirmViewController: StyleViewController {
    
    static let storyboardID = String(describing: ConfirmViewController.self)
    
    var event: Event! = nil
    
    lazy var daysAndTimes: [Day : [Time]] = event.daysAndTimes
    
    var pollFlag = false
    var pollMessage: MSMessage!
    var textBoxFlag = false
    
    var isNewArray: [Bool] = []
    
    var locationTitleEditingIndex: Int? = nil
    var addressEditingIndex: Int? = nil
    
    var needLayoutSubviews1 = true
    var needLayoutSubviews2 = true
    
    var fromVoteResults = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var eventTitleTextField: StyleTextField!
    @IBOutlet weak var locationsLabel: StyleLabel!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var firstLocationButton: HexButton!
    @IBOutlet weak var locationsTableView: UITableView!
    @IBOutlet weak var locationsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var daysAndTimesLabel: StyleLabel!
    @IBOutlet weak var daysAndTimesTableView: UITableView!
    @IBOutlet weak var daysAndTimesTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: HexButton!
    
    @IBOutlet weak var scrollViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet var compactConstraints: [NSLayoutConstraint]!
    @IBOutlet var expandConstraints: [NSLayoutConstraint]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.needLayoutSubviews2 = true

        updateTableLabels()
        
        enableTouchAwayKeyboardDismiss()
        
        addLocationButton.layer.cornerRadius = addLocationButton.frame.height / 2
        addLocationButton.backgroundColor = Colors.primaryColor
        addLocationButton.setTitle("+ Add", for: .normal)
        addLocationButton.setTitleColor(Colors.lightTextColor, for: .normal)
        
        addHexFooter()
        
        //firstLocationButton.style(imageTag: "LongHex", width: 150, height: 70, textColor: Style.lightTextColor, fontSize: 18)

        firstLocationButton.size(width: 150, textSize: 18)
        firstLocationButton.style(title: "Add Location", imageTag: "LongHex", textColor: Colors.lightTextColor)
        loadDaysAndTimes()
        fillEventDetails()
      
        postButton.size(height: 150, textSize: 25)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.keyboardExpandViewApprover))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        scrollView.delegate = self
        
        
    }
    
    func updateTableLabels() {
        let locationLabelText: String
        let daysAndTimesLabelText: String
        if event.locations.count <= 1 {
            locationLabelText = "Location:"
        } else {
            locationLabelText = "Location Options:"
        }
        if event.days.count == 1 {
            if event.times.isEmpty {
                daysAndTimesLabelText = "Day:"
            } else if event.times.count == 1 {
                daysAndTimesLabelText = "Day/Time:"
            } else {
                daysAndTimesLabelText = "Time Options:"
            }
        } else {
            if event.times.isEmpty {
                daysAndTimesLabelText = "Day Options:"
            } else {
                daysAndTimesLabelText = "Day/Time Options:"
            }
        }
        
        locationsLabel.style(text: locationLabelText, textColor: Colors.darkTextColor, fontSize: 18)
        daysAndTimesLabel.style(text: daysAndTimesLabelText, textColor: Colors.darkTextColor, fontSize: 18)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.delegate = self
    
        // sometimes glitchy and doesn't fully show
        scrollAnimation()
    }
    
    func scrollAnimation() {
        scrollView.scrollToBottom(animated: false)
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func changedConstraints(compact: Bool) {
        
        self.needLayoutSubviews2 = true
        print("Number 1", needLayoutSubviews1)
        print("Number 2", needLayoutSubviews2)
        
        if compact {
            scrollViewTrailingConstraint.constant = 160
            for constraint in expandConstraints {
                constraint.isActive = false
            }
            for constraint in compactConstraints {
                constraint.isActive = true
            }
        } else {
            scrollViewTrailingConstraint.constant = 16
            for constraint in compactConstraints {
                constraint.isActive = false
            }
            for constraint in expandConstraints {
                constraint.isActive = true
            }
        }
        daysAndTimesTableView.reloadData()
        formatLocations()
        viewDidLayoutSubviews()
    }
    
    @objc func keyboardExpandViewApprover() {
        textBoxFlag = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        locationTitleEditingIndex = nil
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if textBoxFlag {
            textBoxFlag = false
            if presentationStyle == .compact {
                requestPresentationStyle(.expanded)
            }
        }
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if locationTitleEditingIndex != nil {
                scrollView.contentOffset.y = max((self.locationsTableView.cellForRow(at: IndexPath(row: locationTitleEditingIndex!, section: 0)) as! LocationCell).frame.maxY + self.locationsTableView.frame.minY + scrollView.frame.minY - keyboardSize.minY + 120, 0)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView!) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
        self.needLayoutSubviews2 = true
        //daysAndTimesTableView.reloadData()
        daysAndTimesTableView.layoutIfNeeded()
        self.daysAndTimesTableViewHeightConstraint.constant = self.daysAndTimesTableView.contentSize.height
        scrollView.contentSize.height = eventTitleTextField.frame.height + locationsLabel.frame.height + locationsTableView.frame.height + daysAndTimesLabel.frame.height + daysAndTimesTableView.frame.height + (4 * (8))
    }
    
    func loadDaysAndTimes() {
        if event.daysAndTimes.isEmpty {
            for day in event.days {
                daysAndTimes[day] = (event.times)
            }
        }
    }
    
    func fillEventDetails() {
        
        eventTitleTextField.text = event.title
        setUpLocationsTableView()
        setUpDayTimePairsTableView()
    }
    
    func setUpDayTimePairsTableView() {
    
        daysAndTimesTableView.dataSource = self
        daysAndTimesTableView.delegate = self
        daysAndTimesTableView.rowHeight = UITableView.automaticDimension
        daysAndTimesTableView.setBackgroundColor()
    }
    
    func setUpLocationsTableView() {
        locationsTableView.dataSource = self
        locationsTableView.delegate = self
        locationsTableView.setBackgroundColor()
        formatLocations()
        isNewArray = [Bool](repeating: true, count: event.locations.count)
    }
    
    func formatLocations() {
      
        if event.locations.isEmpty {
            //locationsLabel.isHidden = true
            firstLocationButton.isHidden = false
            addLocationButton.isHidden = true
        } else {
            //locationsLabel.isHidden = false
            firstLocationButton.isHidden = true
            addLocationButton.isHidden = fromVoteResults //false
        }
    }
    
    override func viewDidLayoutSubviews() {
        print("Attempted", self.presentationStyle == .compact)
        
        if !(self.needLayoutSubviews1 && self.needLayoutSubviews2) {
            print("Fail")
            return
        }
        print("Success")
        print("LAYOUT")
        
        super.viewDidLayoutSubviews()
        
        daysAndTimesTableView.reloadData()
        locationsTableView.reloadData()
        self.locationsTableView.setNeedsLayout()
        self.locationsTableView.layoutIfNeeded()
        self.daysAndTimesTableView.setNeedsLayout()
        self.daysAndTimesTableView.layoutIfNeeded()
        
                
        DispatchQueue.main.async {
            self.locationsTableViewHeightConstraint.constant = max(self.locationsTableView.contentSize.height, 40)
            self.daysAndTimesTableViewHeightConstraint.constant = self.daysAndTimesTableView.contentSize.height
            
            self.needLayoutSubviews1 = false
            self.updatePostButtonStatus()
            
            DispatchQueue.main.async {
                self.needLayoutSubviews1 = true
                
                self.setUpEventTitleTextField()
                self.locationsTableViewHeightConstraint.constant = max(self.locationsTableView.contentSize.height, 40)
                self.daysAndTimesTableViewHeightConstraint.constant = self.daysAndTimesTableView.contentSize.height
                for cell in self.daysAndTimesTableView.visibleCells {
                    (cell as! EditingDayAndTimesCell).layoutSubviews()
                }
                self.needLayoutSubviews2 = false
                self.daysAndTimesTableView.reloadRows(at: self.daysAndTimesTableView.indexPathsForVisibleRows!, with: .none)
                
                DispatchQueue.main.async {
                    self.daysAndTimesTableView.layoutSubviews()
                    self.daysAndTimesTableViewHeightConstraint.constant = self.daysAndTimesTableView.contentSize.height
                    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.eventTitleTextField.frame.height + self.locationsLabel.frame.height + self.locationsTableView.frame.height + self.daysAndTimesLabel.frame.height + self.daysAndTimesTableView.frame.height + (4 * 8))
                }
            }
        }
        print("Yolo")
        daysAndTimesTableView.reloadData()
        //self.daysAndTimesTableView.layoutSubviews()
        self.daysAndTimesTableViewHeightConstraint.constant = self.daysAndTimesTableView.contentSize.height
        scrollView.contentSize.height = eventTitleTextField.frame.height + locationsLabel.frame.height + locationsTableView.frame.height + daysAndTimesLabel.frame.height + daysAndTimesTableView.frame.height + (4 * (8))
        print("Yolo")
    }
    
    func setUpEventTitleTextField() {
        eventTitleTextField.style(placeholderText: "Title (eg. Party in the U.S.A)", color: Colors.tertiaryColor, textColor: Colors.tertiaryColor, fontSize: 30)
        eventTitleTextField.addTarget(self, action: #selector(eventTitleTextFieldDidChange(sender:)), for: .editingChanged)
        eventTitleTextField.addDoneButton()
        eventTitleTextField.delegate = self
    }
    
    func updateDaysAndTimes() {
        // Load DaysAndTimes
        print("FLAG", scrollView.contentSize)
        print("FLAG", daysAndTimesTableView.visibleCells.count)
        print("FLAG", self.event.days.count)
        
        DispatchQueue.main.async {
            for (index, day) in self.event.days.enumerated() {
                let cell = self.daysAndTimesTableView.cellForRow(at: IndexPath(item: index, section: 0)) as! EditingDayAndTimesCell
                self.daysAndTimes[day] = []
                for (time, isSelected) in cell.times {
                    if isSelected {
                        self.daysAndTimes[day]!.append(time)
                    }
                }
            }
        }
    }
        
    func updateEventObject(inEvent: Event) -> Event {
        
        var outEvent = inEvent
        
        //updateDaysAndTimes()
        
        // Remove any times that aren't selected anywhere
        for time in outEvent.times {
            var timeIncluded = false
            for day in outEvent.days {
                if daysAndTimes[day]!.contains(where: { $0.sameAs(time: time) }) {
                    timeIncluded = true
                    continue
                }
            }
            if !timeIncluded {
                outEvent.times.remove(at: outEvent.times.firstIndex(where: { $0.sameAs(time: time) })!)
            }
        }
        outEvent.daysAndTimes = daysAndTimes
        
        // Remove blank locations
        outEvent.locations.removeAll(where: { $0.address == nil && $0.title.isBlank() })
        
        return outEvent
    }
    
    // When the post button is pressed
    @IBAction func postButtonPressed(_ sender: UIButton!) {
        
        viewDidLayoutSubviews()
        
        isNewArray = [Bool](repeating: false, count: event.locations.count)
        locationsTableView.reloadData()
        
        // Make sure all text fields are full
        for location in event.locations {
            if location.title.isBlank() {
                // ERROR
                return
            }
        }
        if !eventTitleTextField.getStatus(withDisplay: true) {
            // ERROR
            return
        }
        
        var postEvent = updateEventObject(inEvent: event)
        
        textBoxFlag = false
    
        if postEvent.locations.count > 1 || postEvent.days.count > 1 || postEvent.times.count > 1 {
            postEvent.createMessage(type: .poll, url: postEvent.buildVoteURL())
        } else {
            postEvent.createMessage(type: .invite, url: postEvent.buildRSVPURL(ID: (MessagesAppViewController.conversation?.localParticipantIdentifier.uuidString)!))
        }

        // Shrink app window
        self.requestPresentationStyle(.compact)
         
         
    }
    
    func updatePostButtonStatus() {
        
        let buttonTitle: String
        
        let testEvent = updateEventObject(inEvent: event)
        
        if testEvent.locations.count > 1 || testEvent.days.count > 1 || testEvent.times.count > 1 {
            buttonTitle = "Send\nPoll"
        } else {
            buttonTitle = "Send\nInvite"
        }
        
        postButton.color(title: buttonTitle)
        
        let text = eventTitleTextField.text ?? ""
        if text.isBlank() {
            postButton.grey(title: buttonTitle)
        } else {
            for location in event.locations {
                if location.title == "" {
                    postButton.grey(title: buttonTitle)
                }
            }
        }
    }
    
    @IBAction func addLocationButtonPressed(_ sender: Any) {
        self.needLayoutSubviews2 = true
        event.locations.append(Location(title: "", place: nil, address: nil))
        isNewArray = [Bool](repeating: false, count: event.locations.count-1) + [true]
        locationsTableView.reloadData()

        DispatchQueue.main.async {
            
            self.locationsTableViewHeightConstraint.constant = max(self.locationsTableView.contentSize.height, 40)
            self.locationsTableView.setNeedsLayout()
            self.locationsTableView.layoutIfNeeded()
            let lastCellIndexPath = IndexPath(row: self.event.locations.count - 1, section: 0)
            //self.locationsTableView.scrollToRow(at: lastCellIndexPath, at: .bottom, animated: false)
            let cell = self.locationsTableView.cellForRow(at: lastCellIndexPath) as! LocationCell
            cell.titleTextField.becomeFirstResponder()
        }
        formatLocations()
        updatePostButtonStatus()
        updateTableLabels()
    }
    
    @objc func deleteLocation(sender: UIButton) {
        self.needLayoutSubviews2 = true
        let cell = sender.superview?.superview as! LocationCell
        cell.titleTextField.resetColor()
        let indexPath =
        locationsTableView.indexPath(for: cell)!
        event.locations.remove(at: indexPath.row)
        isNewArray.remove(at: indexPath.row)
        
        CATransaction.begin()
        locationsTableView.beginUpdates()
        CATransaction.setCompletionBlock {
            self.locationsTableView.reloadData()
            self.formatLocations()
            self.updatePostButtonStatus()
        }
        locationsTableView.deleteRows(at: [indexPath], with: .fade)
        locationsTableView.endUpdates()
        CATransaction.commit()
        
        updateTableLabels()
    }
    
    @objc func addOrRemoveAddress(sender: UIButton) {
        self.needLayoutSubviews2 = true
        addressEditingIndex = sender.tag
        if event.locations[addressEditingIndex!].address == nil {
            view.endEditing(true)
            let autocompleteViewController = GMSAutocompleteViewController()
            autocompleteViewController.delegate = self
            navigationController?.present(autocompleteViewController, animated: true)
        } else {
            event.locations[addressEditingIndex!].address = nil
            locationsTableView.reloadData()
        }
        
        self.locationsTableView.setNeedsLayout()
        self.locationsTableView.layoutIfNeeded()
        self.locationsTableViewHeightConstraint.constant = max(self.locationsTableView.contentSize.height, 40)
        
        DispatchQueue.main.async {
            self.daysAndTimesTableView.layoutSubviews()
            self.daysAndTimesTableViewHeightConstraint.constant = self.daysAndTimesTableView.contentSize.height
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.eventTitleTextField.frame.height + self.locationsLabel.frame.height + self.locationsTableView.frame.height + self.daysAndTimesLabel.frame.height + self.daysAndTimesTableView.frame.height + (4 * (8)))
        }
    }
    
    @objc func locationTitleTextFieldDidBeginEditing(sender: StyleTextField) {
        sender.perform(
            #selector(becomeFirstResponder),
            with: nil,
            afterDelay: 0.1
        )
        locationTitleEditingIndex = sender.tag
    }
    
    @objc func locationTitleTextFieldDidChange(sender: StyleTextField) {
        
        if event.locations.indices.contains(sender.tag) {
            event.locations[sender.tag].title = sender.text ?? ""
            sender.isNew = false
            let indexPath =
            locationsTableView.indexPath(for: sender.superview?.superview as! LocationCell)!
            isNewArray[indexPath.row] = false
            sender.colorStatus()
            updatePostButtonStatus()
        }
    }
    
    @objc func eventTitleTextFieldDidChange(sender: StyleTextField) {
        
        event.title = sender.text ?? ""
        sender.isNew = false
        sender.colorStatus()
        locationTitleEditingIndex = nil
        updatePostButtonStatus()
    }
    
    @objc func deleteDay(sender: UIButton) {
        
        let cell = sender.superview?.superview as! EditingDayAndTimesCell
        let indexPath = daysAndTimesTableView.indexPath(for: cell)!
        let day = event.days.remove(at: indexPath.row)
        daysAndTimes.removeValue(forKey: day)
        
        CATransaction.begin()
        daysAndTimesTableView.beginUpdates()
        CATransaction.setCompletionBlock {
            self.daysAndTimesTableView.reloadData()
            self.updateDaysAndTimes()
            
            self.daysAndTimesTableViewHeightConstraint.constant = self.daysAndTimesTableView.contentSize.height
            DispatchQueue.main.async {
                self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.eventTitleTextField.frame.height + self.locationsLabel.frame.height + self.locationsTableView.frame.height + self.daysAndTimesLabel.frame.height + self.daysAndTimesTableView.frame.height + (4 * (8)))
            }
            
        }
        daysAndTimesTableView.deleteRows(at: [indexPath], with: .fade)
        daysAndTimesTableView.endUpdates()
        CATransaction.commit()
        
        needLayoutSubviews1 = true
        updatePostButtonStatus()
        
        updateTableLabels()
    }

}

extension ConfirmViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
        case daysAndTimesTableView:
            return event.days.count
        case locationsTableView:
            return event.locations.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch tableView {
        case daysAndTimesTableView:
            
            let cell = daysAndTimesTableView.dequeueReusableCell(withIdentifier: EditingDayAndTimesCell.reuseIdentifier, for: indexPath) as! EditingDayAndTimesCell
            cell.CVC = self
            var day = event.days[indexPath.row]
            if daysAndTimes.count == 1 {
                cell.deleteButton.isHidden = true
                cell.timesCollectionView.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -10).isActive = true
            } else {
                cell.deleteButton.isHidden = false
                cell.deleteButton.tag = indexPath.row
                cell.deleteButton.addTarget(nil, action: #selector(deleteDay(sender:)), for: .touchUpInside)
            }
            
            cell.times = []
            for time in event.times {
                let isSelected: Bool
                if daysAndTimes[day]!.contains(where: {$0.sameAs(time: time)}) {
                    isSelected = true
                } else {
                    isSelected = false
                }
                cell.times.append((time, isSelected))
            }
            
            if event.times.count <= 1 {
                
                cell.dayLabel.isHidden = true
                cell.timesCollectionView.isHidden = true
                cell.dayAndTimeLabel.isHidden = false
                let text: String
                if event.times.count == 1 {
                    text = day.formatDate(time: event.times[0], duration: event.duration)
                } else {
                    text = day.formatDate()
                }
                cell.dayAndTimeLabel.style(text: text, textColor: Colors.darkTextColor, fontSize: 18)
            } else {
                
                cell.dayLabel.isHidden = false
                cell.timesCollectionView.isHidden = false
                cell.dayAndTimeLabel.isHidden = true
                cell.dayLabel.style(text: day.formatDate(), textColor: Colors.darkTextColor, fontSize: 18)
                cell.duration = event.duration
                cell.timesCollectionView.reloadData()
            }
            return cell
        case locationsTableView:
            let cell = locationsTableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier, for: indexPath) as! LocationCell
            let location = event.locations[indexPath.row]
            cell.titleTextField.text = location.title
            cell.titleTextField.tag = indexPath.row
            cell.titleTextField.addTarget(self, action: #selector(locationTitleTextFieldDidBeginEditing(sender:)), for: .editingDidBegin)
            cell.titleTextField.addTarget(self, action: #selector(locationTitleTextFieldDidChange(sender:)), for: .editingChanged)
            cell.titleTextField.delegate = self
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(nil, action: #selector(deleteLocation(sender:)), for: .touchUpInside)
            cell.addOrRemoveAddressButton.tag = indexPath.row
            cell.addOrRemoveAddressButton.addTarget(nil, action: #selector(addOrRemoveAddress(sender:)), for: .touchUpInside)
            if let address = location.address {
                cell.addOrRemoveAddressButton.setTitle("- address", for: .normal)
                cell.changeAddressButton.isHidden = false
                cell.changeAddressButton.setTitle(address, for: .normal)
            } else {
                cell.addOrRemoveAddressButton.setTitle("+ address", for: .normal)
                cell.changeAddressButton.isHidden = true
            }
            cell.titleTextField.isNew = isNewArray[indexPath.row]
            cell.titleTextField.colorStatus()
            return cell
        default:
            fatalError("Unrecognized UITableView")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        switch tableView {
        case locationsTableView:
            let verticalPadding: CGFloat = 8
            let maskLayer = CALayer()
            maskLayer.cornerRadius = LocationCell.cornerRadius
            maskLayer.backgroundColor = UIColor.black.cgColor
            maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
            cell.layer.mask = maskLayer
        case daysAndTimesTableView:
            let verticalPadding: CGFloat = 8
            let maskLayer = CALayer()
            maskLayer.cornerRadius = EditingDayAndTimesCell.cornerRadius
            maskLayer.backgroundColor = UIColor.black.cgColor
            maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
            cell.layer.mask = maskLayer
        default:
            break
        }
    }
}

extension ConfirmViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case locationsTableView:
            if event.locations[indexPath.row].address != nil {
                return 86
            } else {
                return 50
            }
        case daysAndTimesTableView:
            return tableView.rowHeight
        default:
            return 0
        }
    }
}

extension ConfirmViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        event.locations[addressEditingIndex!] = Location(title: event.locations[addressEditingIndex!].title, place: place)
        locationsTableView.reloadData()
        navigationController?.dismiss(animated: true)
        locationsTableView.layoutSubviews()
        
        self.locationsTableView.setNeedsLayout()
        self.locationsTableView.layoutIfNeeded()
        self.locationsTableViewHeightConstraint.constant = max(self.locationsTableView.contentSize.height, 40)
        
        DispatchQueue.main.async {
            self.daysAndTimesTableView.layoutSubviews()
            self.daysAndTimesTableViewHeightConstraint.constant = self.daysAndTimesTableView.contentSize.height
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.eventTitleTextField.frame.height + self.locationsLabel.frame.height + self.locationsTableView.frame.height + self.daysAndTimesLabel.frame.height + self.daysAndTimesTableView.frame.height + (4 * (8)))
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        navigationController?.dismiss(animated: true)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        navigationController?.dismiss(animated: true)
    }
}

extension ConfirmViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if type(of: viewController) == TimeSelectorViewController.self {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            self.requestPresentationStyle(.expanded)
            event = updateEventObject(inEvent: event)
            (viewController as! TimeSelectorViewController).event = event
            (viewController as! TimeSelectorViewController).updateSelections()
        } else if type(of: viewController) == DaySelectorViewController.self {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            self.requestPresentationStyle(.expanded)
            event = updateEventObject(inEvent: event)
            (viewController as! DaySelectorViewController).event = event
            (viewController as! DaySelectorViewController).updateSelections()
            (viewController as! DaySelectorViewController).expandToNext = false
        }
    }
}

class TimesCollectionViewLayout: UICollectionViewFlowLayout {
    
    required override init() {super.init(); common()}
    required init?(coder aDecoder: NSCoder) {super.init(coder: aDecoder); common()}
    
    private func common() {
        minimumLineSpacing = 10
        minimumInteritemSpacing = 10
    }
    
    override func layoutAttributesForElements(
                    in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let att = super.layoutAttributesForElements(in:rect) else {return []}
        var x: CGFloat = sectionInset.left
        var y: CGFloat = -1.0
        
        for a in att {
            if a.representedElementCategory != .cell { continue }
            
            if a.frame.origin.y >= y { x = sectionInset.left }
            a.frame.origin.x = x
            x += a.frame.width + minimumInteritemSpacing
            y = a.frame.maxY
        }
        return att
    }
}

class EditingDayAndTimesCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: EditingDayAndTimesCell.self)
    
    static let cornerRadius: CGFloat = 20
    
    var times = [(time: Time, isSelected: Bool)]()
    var duration: Duration? = nil
    var CVC: ConfirmViewController!
    var goodHeight: CGFloat!
    
    let dayAndTimeLabel: StyleLabel = {
        let label = StyleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    let dayLabel: StyleLabel = {
        let label = StyleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    let timesCollectionView: UICollectionView = {
        let layout = TimesCollectionViewLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(EditingTimeCell.self, forCellWithReuseIdentifier: EditingTimeCell.reuseIdentifier)
        collectionView.backgroundColor = Colors.lightGreyColor
        return collectionView
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("X", for: .normal)
        
        button.backgroundColor = Colors.greyColor
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = Colors.lightGreyColor
        
        contentView.addSubview(timesCollectionView)
        contentView.addSubview(dayLabel)
        contentView.addSubview(dayAndTimeLabel)
        contentView.addSubview(deleteButton)
    
        timesCollectionView.dataSource = self
        timesCollectionView.delegate = self
        timesCollectionView.reloadData()

        let inset: CGFloat = 10

        NSLayoutConstraint.activate([
            dayLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            //dayLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: topAnchor, constant: inset + 15),
            dayLabel.widthAnchor.constraint(equalToConstant: 90),
            
            dayAndTimeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            dayAndTimeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            deleteButton.heightAnchor.constraint(equalToConstant: 26),
            deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor),
            deleteButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            timesCollectionView.leftAnchor.constraint(equalTo: dayLabel.rightAnchor, constant: 5),
            timesCollectionView.rightAnchor.constraint(equalTo: deleteButton.leftAnchor, constant: -5),
            timesCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            timesCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        timesCollectionView.layer.cornerRadius = 5
        deleteButton.layer.cornerRadius = deleteButton.frame.height / 2
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        self.contentView.frame = self.bounds
        self.contentView.layoutIfNeeded()
        
        var tCVcontentSize = self.timesCollectionView.contentSize
        tCVcontentSize.height += 20
        tCVcontentSize.height = max(tCVcontentSize.height, 50)
        goodHeight = tCVcontentSize.height
        return tCVcontentSize
    }
}

extension EditingDayAndTimesCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        times.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = timesCollectionView.dequeueReusableCell(withReuseIdentifier: EditingTimeCell.reuseIdentifier, for: indexPath) as! EditingTimeCell
        cell.timeLabel.text = times[indexPath.row].time.format(duration: nil)
        cell.deleteIcon.tag = indexPath.row
        if times[indexPath.row].isSelected {
            cell.backgroundColor = Colors.primaryColor
            cell.timeLabel.textColor = Colors.lightTextColor
            cell.deleteIcon.text = "X"
        } else {
            cell.backgroundColor = Colors.greyColor
            cell.timeLabel.textColor = UIColor.white
            cell.deleteIcon.text = "+"
        }
        cell.deleteIcon.adjustHeight()

        return cell
    }
}

extension EditingDayAndTimesCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for (index, (time, isSelected)) in times.enumerated() {
            if isSelected && index != indexPath.row {
                times[indexPath.row].isSelected = !times[indexPath.row].isSelected
                collectionView.reloadData()
                collectionView.layoutSubviews()
                CVC.updateDaysAndTimes()
                CVC.updatePostButtonStatus()
                return
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let timeString = times[indexPath.row].time.format(duration: nil)
        return CGSize(width: timeString.size(withAttributes: [NSAttributedString.Key.font : Format.font(size: 18)]).width + 35, height: 30)
    }
}

class EditingTimeCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: EditingTimeCell.self)
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Format.font(size: 18)
        return label
    }()
    
    let deleteIcon: StyleLabel = {
        let label = StyleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Colors.lightGreyColor
        label.textColor = Colors.greyColor
        label.textAlignment = .center
        label.text = "X"
        label.adjustHeight()
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Apply rounded corners
        self.layer.cornerRadius = 5
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(deleteIcon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        /*
        if (superview?.superview?.superview as! EditingDayAndTimesCell).times[deleteIcon.tag].isSelected {
            deleteIcon.text = "X"
            
        } else {
            deleteIcon.text = "+"
        }
        deleteIcon.adjustHeight()
        */
        let inset: CGFloat = 5

        NSLayoutConstraint.activate([
            timeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            deleteIcon.heightAnchor.constraint(equalToConstant: self.frame.height - (inset * 2)),
            deleteIcon.widthAnchor.constraint(equalTo: deleteIcon.heightAnchor),
            deleteIcon.leftAnchor.constraint(equalTo: timeLabel.rightAnchor, constant: inset),
            deleteIcon.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        deleteIcon.layer.masksToBounds = true
        deleteIcon.layer.cornerRadius = self.frame.height/2 - inset
    }
}
