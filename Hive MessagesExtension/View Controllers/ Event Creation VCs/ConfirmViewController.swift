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
    
    var addressEditingIndex: Int? = nil
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var eventTitleTextField: StyleTextField!
    @IBOutlet weak var locationsLabel: StyleLabel!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var firstLocationButton: HexButton!
    @IBOutlet weak var locationsTableView: UITableView!
    @IBOutlet weak var locationsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dayTimePairsLabel: StyleLabel!
    @IBOutlet weak var daysAndTimesTableView: UITableView!
    @IBOutlet weak var daysAndTimesTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: HexButton!
    
    @IBOutlet weak var scrollViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet var compactConstraints: [NSLayoutConstraint]!
    @IBOutlet var expandConstraints: [NSLayoutConstraint]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationsLabel.style(text: "Location Options:", textColor: Colors.darkTextColor, fontSize: 18)
        dayTimePairsLabel.style(text: "Day/Time Options:", textColor: Colors.darkTextColor, fontSize: 18)
        
        enableTouchAwayKeyboardDismiss()
        
        addLocationButton.layer.cornerRadius = addLocationButton.frame.height / 2
        addLocationButton.backgroundColor = Colors.primaryColor
        addLocationButton.setTitle("+ Add", for: .normal)
        addLocationButton.setTitleColor(Colors.lightTextColor, for: .normal)
        
        addHexFooter()
        
        //firstLocationButton.style(imageTag: "LongHex", width: 150, height: 70, textColor: Style.lightTextColor, fontSize: 18)
        firstLocationButton.size(size: 150, textSize: 18)
        firstLocationButton.style(title: "Add Location", imageTag: "LongHex", textColor: Colors.lightTextColor)
        loadDaysAndTimes()
        fillEventDetails()
        
        postButton.size(size: 150, textSize: 25)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.keyboardExpandViewApprover))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        daysAndTimesTableView.rowHeight = UITableView.automaticDimension
        
    }
    
    func changedConstraints(compact: Bool) {
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
        formatLocations()
        updateTableViewHeights()
        updateContentView()
        locationsTableView.reloadData()
        daysAndTimesTableView.reloadData()
    }
    
    @objc func keyboardExpandViewApprover() {
        textBoxFlag = true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if textBoxFlag {
            textBoxFlag = false
            if presentationStyle == .compact {
                requestPresentationStyle(.expanded)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateContentView()
        
        navigationController?.delegate = self
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x>0 {
            scrollView.contentOffset.x = 0
        }
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
            addLocationButton.isHidden = false
        }
    }
    
    func updateTableViewHeights() {
        
        
        self.locationsTableViewHeightConstraint.constant = max(self.locationsTableView.contentSize.height, 40)
        self.locationsTableView.layoutIfNeeded()
        self.daysAndTimesTableViewHeightConstraint.constant = 0
        (self.daysAndTimesTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EditingDayAndTimesCell).layoutSubviews()
        self.daysAndTimesTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        self.daysAndTimesTableView.layoutSubviews()
        self.daysAndTimesTableViewHeightConstraint.constant = self.daysAndTimesTableView.contentSize.height
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: eventTitleTextField.frame.height + locationsLabel.frame.height + locationsTableView.frame.height + dayTimePairsLabel.frame.height + daysAndTimesTableView.frame.height + (4 * (8)))
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        DispatchQueue.main.async {
            self.setUpEventTitleTextField()
            self.updateTableViewHeights()
        }
        updatePostButtonStatus()
    }
    
    func setUpEventTitleTextField() {
        eventTitleTextField.style(placeholderText: "Title (eg. Party in the U.S.A)", color: Colors.tertiaryColor, textColor: Colors.tertiaryColor, fontSize: 30)
        eventTitleTextField.addTarget(self, action: #selector(eventTitleTextFieldDidChange(sender:)), for: .editingChanged)
        eventTitleTextField.addDoneButton()
    }
    
    func updateDaysAndTimes() {
        // Load DaysAndTimes
        for (index, day) in event.days.enumerated() {
            let cell = daysAndTimesTableView.cellForRow(at: IndexPath(item: index, section: 0)) as! EditingDayAndTimesCell
            daysAndTimes[day] = []
            for (time, isSelected) in cell.times {
                if isSelected {
                    daysAndTimes[day]!.append(time)
                }
            }
        }
    }
    
    func updateEventObject(inEvent: Event) -> Event {
        
        var outEvent = inEvent
        
        updateDaysAndTimes()
        
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
        
        // Load current conversation
        guard let conversation = MessagesViewController.conversation else { fatalError("Received nil conversation") }
        
        // Load current session or create new session
        let session = conversation.selectedMessage?.session ?? MSSession()
        
        var caption: String
        let image: UIImage
        let imageTitle: String
        let imageSubtitle: String
        let trailingCaption: String
        var subcaption: String
        let trailingSubcaption: String
        let summaryText: String = messageSummaryText
        let messageURL: URL
        
        
        if postEvent.locations.count > 1 || postEvent.days.count > 1 || postEvent.times.count > 1 {
            // TODO: POLL
            
            caption = "Poll for " + postEvent.title
            image = UIImage(named: "MessageHeader")!
            imageTitle = ""
            imageSubtitle = ""
            trailingCaption = ""
            subcaption = ""
            trailingSubcaption = ""
            //summaryText = "Poll for " + event.title
            
            messageURL = postEvent.buildVoteURL()
            
            /*conversation.insert(pollMessage) {error in
                // empty for now
            }*/
        } else {
            // RSVP invite
            
            caption = "Come to " + postEvent.title
            if postEvent.locations.isEmpty {
                caption += "!"
            } else {
                caption += " at " + postEvent.locations[0].title + "!"
            }
            image = UIImage(named: "MessageHeader")!
            imageTitle = ""
            imageSubtitle = ""
            trailingCaption = ""
            
            if postEvent.times.isEmpty {
                subcaption = postEvent.days[0].formatDate()
            } else {
                subcaption = postEvent.days[0].formatDate(time: postEvent.times[0], duration: postEvent.duration)
            }
            
            trailingSubcaption = ""
            
            // TODO: Doesn't work for some reason
            //summaryText = "Invite to " + event.title
            
            messageURL = postEvent.buildRSVPURL(ID: (MessagesViewController.conversation?.localParticipantIdentifier.uuidString)!)
        }
        
        // Construct message layout
        let messageLayout = MSMessageTemplateLayout()
        
        messageLayout.caption = caption
        messageLayout.image = image
        messageLayout.imageTitle = imageTitle
        messageLayout.imageSubtitle = imageSubtitle
        messageLayout.trailingCaption = trailingCaption
        messageLayout.subcaption = subcaption
        messageLayout.trailingSubcaption = trailingSubcaption
        
        // Construct message
        let message = MSMessage(session: session)
        message.layout = messageLayout
        message.summaryText = summaryText
        message.url = messageURL

        // Add message to conversation
        conversation.insert(message) {error in
            // empty for now
        }
        
        // Shrink app window
        self.requestPresentationStyle(.compact)
    }
    
    func updatePostButtonStatus() {
        let text = eventTitleTextField.text ?? ""
        if text.isBlank() {
            postButton.grey(title: "Post")
            return
        }
        for location in event.locations {
            if location.title == "" {
                postButton.grey(title: "Post")
                return
            }
        }
        postButton.color(title: "Post")
    }
    
    @IBAction func addLocationButtonPressed(_ sender: Any) {
        event.locations.append(Location(title: "", place: nil, address: nil))
        isNewArray = [Bool](repeating: false, count: event.locations.count-1) + [true]
        self.formatLocations()
        self.updatePostButtonStatus()
        locationsTableView.reloadData()

        DispatchQueue.main.async {
            
            self.updateTableViewHeights()
            let lastCellIndexPath = IndexPath(row: self.event.locations.count - 1, section: 0)
            self.locationsTableView.scrollToRow(at: lastCellIndexPath, at: .bottom, animated: false)
            let cell = self.locationsTableView.cellForRow(at: lastCellIndexPath) as! LocationCell
            cell.titleTextField.becomeFirstResponder()
        }
    }
    
    @objc func deleteLocation(sender: UIButton) {
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
    }
    
    @objc func addOrRemoveAddress(sender: UIButton) {
        addressEditingIndex = sender.tag
        if event.locations[addressEditingIndex!].address == nil {
            let autocompleteViewController = GMSAutocompleteViewController()
            autocompleteViewController.delegate = self
            navigationController?.present(autocompleteViewController, animated: true)
        } else {
            event.locations[addressEditingIndex!].address = nil
            locationsTableView.reloadData()
        }
        updateTableViewHeights()
    }
    
    @objc func locationTitleTextFieldDidBeginEditing(sender: StyleTextField) {
        sender.perform(
            #selector(becomeFirstResponder),
            with: nil,
            afterDelay: 0.1
        )
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
        updatePostButtonStatus()
    }
    
    func updateContentView() {
        let width = scrollView.subviews.sorted(by: { $0.frame.maxX < $1.frame.maxX }).last?.frame.maxX ?? scrollView.contentSize.width
        scrollView.contentSize.width = width
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
        }
        daysAndTimesTableView.deleteRows(at: [indexPath], with: .fade)
        daysAndTimesTableView.endUpdates()
        CATransaction.commit()
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
            // TODO: This is not right, there should be some sort of error message here
            return UITableViewCell()
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
        updateTableViewHeights()
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
            self.requestPresentationStyle(.expanded)
            event = updateEventObject(inEvent: event)
            (viewController as! TimeSelectorViewController).event = event
            (viewController as! TimeSelectorViewController).updateSelections()
        } else if type(of: viewController) == DaySelectorViewController.self {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
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
            dayLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
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
        } else {
            cell.backgroundColor = Colors.greyColor
            cell.timeLabel.textColor = UIColor.white
        }

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
    
    let deleteIcon: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Colors.lightGreyColor
        label.textColor = Colors.greyColor
        label.textAlignment = .center
        label.text = "X"
        
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
        
        if (superview?.superview?.superview as! EditingDayAndTimesCell).times[deleteIcon.tag].isSelected {
            deleteIcon.text = "X"
        } else {
            deleteIcon.text = "+"
        }
        
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
