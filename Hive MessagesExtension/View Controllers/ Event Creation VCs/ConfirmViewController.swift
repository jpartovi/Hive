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

class ConfirmViewController: MSMessagesAppViewController {
    
    static let storyboardID = String(describing: ConfirmViewController.self)
    
    var event: Event! = nil
    
    var daysAndTimes: [Day : [Time]] = [:]
    
    var pollFlag = false
    var pollMessage: MSMessage!
    
    
    var addressEditingIndex: Int? = nil
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var eventTitleTextField: UITextField!
    @IBOutlet weak var locationsLabel: UILabel!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var firstLocationButton: HexButton!
    @IBOutlet weak var locationsTableView: UITableView!
    @IBOutlet weak var locationsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dayTimePairsLabel: UILabel!
    @IBOutlet weak var daysAndTimesTableView: UITableView!
    @IBOutlet weak var daysAndTimesTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: HexButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHexFooter()
        
        styleEventTitleTextField()
        
        firstLocationButton.style(imageTag: "LongHex", width: 150, height: 70, textColor: Style.lightTextColor, fontSize: 18)
        loadDaysAndTimes()
        fillEventDetails()
        
        postButton.style(width: 130, height: 150, fontSize: 25)
    }
    
    func styleEventTitleTextField() {
        
        eventTitleTextField.borderStyle = .none
        eventTitleTextField.font = Style.font(size: 30)
        eventTitleTextField.textColor = Style.tertiaryColor
        let underlineThickness = CGFloat(2)
        let underline = CALayer()
        underline.frame = CGRect(x: 0.0, y: eventTitleTextField.frame.height - underlineThickness, width: view.frame.width - 32, height: underlineThickness)
        underline.backgroundColor = Style.tertiaryColor.cgColor
        eventTitleTextField.layer.addSublayer(underline)
        eventTitleTextField.placeholder = "Event Title"
    }
    
    func loadDaysAndTimes() {
        for day in event.days {
            daysAndTimes[day] = (event.times)
        }
    }
    func fillEventDetails() {
        
        eventTitleTextField.text = event.title
        locationsTableView.dataSource = self
        locationsTableView.delegate = self
        formatLocations()
        setUpDayTimePairsTableView()
    }
    
    func setUpDayTimePairsTableView() {
        daysAndTimesTableView.dataSource = self
        daysAndTimesTableView.delegate = self
    }
    
    func formatLocations() {
      
        if event.locations.isEmpty {
            firstLocationButton.isHidden = false
            addLocationButton.isHidden = true
        } else {
            firstLocationButton.isHidden = true
            addLocationButton.isHidden = false
        }
    }
    
    func updateTableViewHeights() {
        
        self.locationsTableViewHeightConstraint.constant = self.locationsTableView.contentSize.height
        self.locationsTableView.layoutIfNeeded()
        self.daysAndTimesTableViewHeightConstraint.constant = self.daysAndTimesTableView.contentSize.height
        self.daysAndTimesTableView.layoutIfNeeded()
        scrollView.contentSize = CGSize(width: self.view.frame.width - (2 * 16), height: 1200)
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        
        updateTableViewHeights()
    }
    
    // When the post button is pressed
    @IBAction func postButtonPressed(_ sender: UIButton!) {
        
        // TODO: Data to encode
        /*
         - Event title
         - Event type (key)?
         - Location options
            - Location name
            - GMSPlace ID
         - Days and times
            - Day in string form
            - Followed by times in string form
         - Duration
         
         */
        
        // TODO: Make sure all text fields have contents (eventTitle + locationTitles)
        event.title = eventTitleTextField.text!
        
        // LoadDaysAndTimes
        for (index, day) in event.days.enumerated() {
            
            // TODO: can't load cells out of the view!
            let cell = daysAndTimesTableView.cellForRow(at: IndexPath(item: index, section: 0)) as! EditingDayAndTimesCell
            daysAndTimes[day] = []
            for (time, isSelected) in cell.times {
                if isSelected {
                    daysAndTimes[day]!.append(time)
                }
            }
        }
        event.daysAndTimes = daysAndTimes
        
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
        let summaryText: String
        let messageURL: URL
        
        
        if event.locations.count > 1 || event.days.count > 1 || event.times.count > 1 {
            // TODO: POLL
            
            caption = "Poll for " + event.title
            image = UIImage(named: "MessageHeader")!
            imageTitle = ""
            imageSubtitle = ""
            trailingCaption = ""
            subcaption = ""
            trailingSubcaption = ""
            summaryText = ""
            
            messageURL = event.buildVoteURL()
            
            /*conversation.insert(pollMessage) {error in
                // empty for now
            }*/
        } else {
            // RSVP invite
            
            caption = "Come to " + event.title
            if event.locations.isEmpty {
                caption += "!"
            } else {
                caption += " at " + event.locations[0].title + "!"
            }
            image = UIImage(named: "MessageHeader")!
            imageTitle = ""
            imageSubtitle = ""
            trailingCaption = ""
            subcaption = event.days[0].formatDate()
            if !event.times.isEmpty {
                subcaption += " @ " + event.times[0].format(duration: event.duration)
            }
            
            trailingSubcaption = ""
            
            // TODO: Doesn't work for some reason
            summaryText = "Invite to " + event.title
            
            messageURL = event.buildRSVPURL()
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
    
    @IBAction func addLocationButtonPressed(_ sender: Any) {
        event.locations.append(Location(title: "", place: nil, address: nil))
        locationsTableView.reloadData()
        updateTableViewHeights()
        
        let lastCellIndexPath = IndexPath(row: event.locations.count - 1, section: 0)
        locationsTableView.scrollToRow(at: lastCellIndexPath, at: .bottom, animated: false)
        let cell = locationsTableView.cellForRow(at: lastCellIndexPath) as! LocationCell
        cell.titleTextField.becomeFirstResponder()
        formatLocations()
        
        // TODO: make it so that the users cursor gets automatically put into the newest text field and keyboard opens
    }
    
    @objc func deleteLocation(sender: UIButton) {
        locationsTableView.reloadData()
        let index = sender.tag
        event.locations.remove(at: index)
        locationsTableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .fade)
        formatLocations()
        updateTableViewHeights()
    }
    
    @objc func addOrRemoveAddress(sender: UIButton) {
        addressEditingIndex = sender.tag
        if event.locations[addressEditingIndex!].place == nil {
            let autocompleteViewController = GMSAutocompleteViewController()
            autocompleteViewController.delegate = self
            navigationController?.present(autocompleteViewController, animated: true)
        } else {
            event.locations[addressEditingIndex!].place = nil
            locationsTableView.reloadData()
        }
        updateTableViewHeights()
    }
    
    @objc func locationTitleTextFieldDidChange(sender: UITextField) {
        print(sender.tag)
        
        // TODO: Better way to do this?? "try"?
        if event.locations.indices.contains(sender.tag) {
            event.locations[sender.tag].title = sender.text ?? ""
        }
    }
}

extension ConfirmViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
        case daysAndTimesTableView:
            return daysAndTimes.count
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
            var day = event.days[indexPath.row]
            cell.dayLabel.text = day.formatDate()
            for time in daysAndTimes[day]! {
                cell.times.append((time, true))
            }
            cell.duration = event.duration
            return cell
        case locationsTableView:
            let cell = locationsTableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier, for: indexPath) as! LocationCell
            let location = event.locations[indexPath.row]
            cell.titleTextField.text = location.title
            cell.titleTextField.tag = indexPath.row
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
            if event.locations[indexPath.row].place != nil {
                return 86
            } else {
                return 50
            }
        case daysAndTimesTableView:
            return 50
        default:
            return 0
        }
    }
}

extension ConfirmViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        event.locations[addressEditingIndex!] = Location(title: event.locations[addressEditingIndex!].title, place: place, address: place.formattedAddress!)
        locationsTableView.reloadData()
        navigationController?.dismiss(animated: true)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        navigationController?.dismiss(animated: true)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        navigationController?.dismiss(animated: true)
    }
}

class EditingDayAndTimesCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: EditingDayAndTimesCell.self)
    
    static let cornerRadius: CGFloat = 20
    
    var times = [(time: Time, isSelected: Bool)]()
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
        collectionView.register(EditingTimeCell.self, forCellWithReuseIdentifier: EditingTimeCell.reuseIdentifier)
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
            dayLabel.widthAnchor.constraint(equalToConstant: 40),
            
            timesCollectionView.leftAnchor.constraint(equalTo: dayLabel.rightAnchor, constant: inset),
            timesCollectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            timesCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            timesCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
        
        timesCollectionView.layer.cornerRadius = 5
    }
}

extension EditingDayAndTimesCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        times.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = timesCollectionView.dequeueReusableCell(withReuseIdentifier: EditingTimeCell.reuseIdentifier, for: indexPath) as! EditingTimeCell
        cell.timeLabel.text = times[indexPath.row].time.format(duration: nil)//duration)
        cell.deleteIcon.tag = indexPath.row
        if times[indexPath.row].isSelected {
            cell.backgroundColor = Style.primaryColor
            cell.timeLabel.textColor = Style.lightTextColor
        } else {
            cell.backgroundColor = Style.greyColor
            cell.timeLabel.textColor = UIColor.white
        }
        return cell
    }
    
    
}

extension EditingDayAndTimesCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        times[indexPath.row].isSelected = !times[indexPath.row].isSelected
        timesCollectionView.reloadData()
    }
}

class EditingTimeCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: EditingTimeCell.self)
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let deleteIcon: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Style.lightGreyColor
        label.textColor = Style.greyColor
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
        
        
        self.contentView.layer.cornerRadius = 5
        
        let inset: CGFloat = 5

        NSLayoutConstraint.activate([
            timeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            deleteIcon.heightAnchor.constraint(equalToConstant: self.frame.height - (inset * 2)),
            deleteIcon.widthAnchor.constraint(equalTo: deleteIcon.heightAnchor),
            deleteIcon.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            deleteIcon.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        deleteIcon.layer.masksToBounds = true
        deleteIcon.layer.cornerRadius = deleteIcon.frame.height / 2
    }
}

