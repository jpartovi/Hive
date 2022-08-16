//
//  TimeSelectorViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/17/22.
//

import UIKit
import Messages

class TimeSelectorViewController: StyleViewController {
    
    static let storyboardID = String(describing: TimeSelectorViewController.self)
    
    var event: Event! = nil
    lazy var startTimes: [Time] = event.type.getStartTimes()
    var startTimesSelectionKey: [(Time, Bool)] = []
    var selectedTimes = [Time]()
    var anyStartTimeSelected: Bool = false
    lazy var durations: [Duration?] = [nil] + event.type.getDurations()
    lazy var selectedDuration: Duration? = event.duration
    
    @IBOutlet weak var promptLabel: StyleLabel!
    @IBOutlet weak var durationLabel: StyleLabel!
    @IBOutlet weak var durationPicker: UIPickerView!
    @IBOutlet weak var durationView: UIStackView!
    @IBOutlet weak var includeDurationButton: UIButton!
    @IBOutlet weak var instructionsLabel: StyleLabel!
    
    @IBAction func includeDurationButtonPressed(_ sender: Any) {
        
        showDurationPicker()
    }
    @IBOutlet weak var startTimesCollectionView: UICollectionView!
    var cellsPerRow = 2
    var rows = 3
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 5
    let minimumInteritemSpacing: CGFloat = 10
    @IBOutlet weak var nextButton: HexButton!
    
    var compactView: Bool = false
    var expandToNext: Bool = false
    
    @IBOutlet var expandConstraints: [NSLayoutConstraint]!
    @IBOutlet var compactConstraints: [NSLayoutConstraint]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHexFooter()
        
        durationLabel.style(text: "Duration:", textColor: Colors.darkTextColor, fontSize: 20)
                
        promptLabel.style(text: "When are you hosting?")
        promptLabel.adjustHeight()
        
        instructionsLabel.style(text: "Add multiple start times to create a poll", textColor: Colors.darkTextColor, fontSize: 18)
        instructionsLabel.adjustHeight()
        
        durationPicker.dataSource = self
        durationPicker.delegate = self
        
    
        startTimesCollectionView.contentInsetAdjustmentBehavior = .always
        startTimesCollectionView.register(StartTimeCell.self, forCellWithReuseIdentifier: StartTimeCell.reuseIdentifier)
        startTimesCollectionView.dataSource = self
        startTimesCollectionView.delegate = self
        startTimesCollectionView.setBackgroundColor()
        
        updateSelections()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.delegate = self
        
        // sometimes glitchy and doesn't fully show
        scrollAnimation()
    }
    
    func scrollAnimation() {
        startTimesCollectionView.scrollToBottom(animated: false)
        startTimesCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func updateSelections() {
        selectedTimes = event.times
        loadStartTimeSelectionKey()
        startTimesCollectionView.reloadData()
        updateNextButtonStatus()
    }
    
    func changedConstraints(compact: Bool){
        
        compactView = compact
        
        if compact {
            promptLabel.font = Format.font(size: 20)
            instructionsLabel.isHidden = true
            durationLabel.font = Format.font(size: 15)
            cellsPerRow = 1
            rows = 6
            for constraint in expandConstraints {
                constraint.isActive = false
            }
            for constraint in compactConstraints {
                constraint.isActive = true
            }
            durationView.axis = .vertical
        } else {
            promptLabel.font = Format.font(size: 30)
            instructionsLabel.isHidden = false
            durationLabel.font = Format.font(size: 23)
            cellsPerRow = 2
            rows = 3
            for constraint in compactConstraints {
                constraint.isActive = false
            }
            for constraint in expandConstraints {
                constraint.isActive = true
            }
            durationView.axis = .horizontal
        }
        startTimesCollectionView.reloadData()
        startTimesCollectionView.setNeedsLayout()
        startTimesCollectionView.layoutIfNeeded()
        startTimesCollectionView.layoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        formatDurationView()
    }
    
    func formatDurationView() {
        if selectedDuration == nil {
            hideDurationPicker()
        } else {
            showDurationPicker()
        }
    }
    
    func hideDurationPicker() {
        includeDurationButton.isHidden = false
        durationView.isHidden = true
    }
    
    func showDurationPicker() {
        if selectedDuration == nil {
            selectedDuration = event.type.getDefaultDuration()
        }
        
        let durationIndex = durations.firstIndex(where: {$0?.minutes == selectedDuration?.minutes})!
        durationPicker.selectRow(durationIndex, inComponent: 0, animated: true)
        
        includeDurationButton.isHidden = true
        durationView.isHidden = false
    }
    
    func loadStartTimeSelectionKey() {
        startTimesSelectionKey = []
        for time in startTimes {
            let isSelected: Bool
            if selectedTimes.contains(where: { $0.sameAs(time: time) } ) {
                isSelected = true
            } else {
                isSelected = false
            }
            startTimesSelectionKey.append((time, isSelected))
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        updateEventObject()
        
        expandAndNextPage()
    }
    
    func updateEventObject() {
        selectedTimes = []
        for (startTime, isSelected) in startTimesSelectionKey {
            if isSelected {
                selectedTimes.append(startTime)
            }
        }
        
        event.times = selectedTimes
        event.duration = selectedDuration
    }
    
    func expandAndNextPage() {
        let MVC = (self.parent?.parent as? MessagesAppViewController)!
        if MVC.presentationStyle == .compact {
            expandToNext = true
            MVC.requestPresentationStyle(.expanded)
            //triggers code in MessagesViewController that calls nextPage after completion
        } else {
            nextPage()
        }
    }
    
    func nextPage() {
        
        let confirmVC = (storyboard?.instantiateViewController(withIdentifier: ConfirmViewController.storyboardID) as? ConfirmViewController)!
        confirmVC.event = event
        self.navigationController?.pushViewController(confirmVC, animated: true)
    }
    
    func updateNextButtonStatus() {
        
        anyStartTimeSelected = false
        for (_ , isSelected) in startTimesSelectionKey {
            
            if isSelected {
                anyStartTimeSelected = true
                break
            }
        }
        
        if anyStartTimeSelected {
            nextButton.color(title: "Next")
        } else {
            nextButton.grey(title: "Skip")
        }
    }
}

extension TimeSelectorViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        durations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let label: String
        if let duration: Duration = durations[row] {
            label = duration.format()
        } else {
            label = "None"
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = StyleLabel()
        if let v = view {
            label = v as! StyleLabel
        }
        let fontSize: CGFloat
        if compactView {
            fontSize = 15
            
        } else {
            fontSize = 20
        }
        if let duration: Duration = durations[row] {
            
            label.style(text: duration.format(), textColor: Colors.darkTextColor, fontSize: fontSize)
        } else {
            label.style(text: "None", textColor: Colors.darkTextColor, fontSize: fontSize)
        }
        return label
    }
    
}

extension TimeSelectorViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDuration = durations[row]
        //pickerView.subviews[0].subviews[0].subviews[2].bounds = pickerView.subviews[0].subviews[0].subviews[2].frame.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        //pickerView.subviews[0].subviews[0].subviews[2].layer.cornerRadius = 10
        //pickerView.subviews[0].subviews[0].subviews[2].backgroundColor = Style.primaryColor
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //this will trigger attributedTitleForRow-method to be called
        pickerView.reloadAllComponents()
    }
}

// MARK: - UICollectionViewDataSource
extension TimeSelectorViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        startTimesSelectionKey.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let (startTime, isSelected) = startTimesSelectionKey[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StartTimeCell.reuseIdentifier, for: indexPath) as! StartTimeCell

        cell.time = startTime
        if isSelected {
            cell.showSelected()
        } else {
            cell.showUnselected()
        }
        
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let newSize = min(CGFloat(Int(collectionView.frame.width - marginsAndInsets)*18 / (cellsPerRow*250)), 28.8)
        
        
        //cell.timeLabel.font = cell.timeLabel.font.withSize(newSize)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TimeSelectorViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var (startTime, isSelected) = startTimesSelectionKey[indexPath.row]
        if !event.daysAndTimes.isEmpty {
            if isSelected {
                for day in event.days {
                    event.daysAndTimes[day]?.removeAll(where: { $0.sameAs(time: startTime) })
                }
            } else {
                for day in event.days {
                    event.daysAndTimes[day]?.append(startTime)
                }
            }
        }
        isSelected = !isSelected
        startTimesSelectionKey[indexPath.row] = (startTime, isSelected)
        startTimesCollectionView!.reloadData()
        updateNextButtonStatus()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
     
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let width = min(Int(collectionView.frame.width - marginsAndInsets) / cellsPerRow, 400)
        let height = min(Int(collectionView.frame.width - marginsAndInsets) / (cellsPerRow*4), 100) //50
        
        return CGSize(width: width, height: height)
    }
}

extension TimeSelectorViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if type(of: viewController) == DaySelectorViewController.self {
            self.requestPresentationStyle(.expanded)
            updateEventObject()
            (viewController as! DaySelectorViewController).event = event
            (viewController as! DaySelectorViewController).updateSelections()
            (viewController as! DaySelectorViewController).expandToNext = false
            
        }
    }
}

class StartTimeCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: StartTimeCell.self)
    
    var timeLabel: StyleLabel = {
        let label = StyleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.style(text: "", textColor: Colors.lightTextColor, fontSize: 18)
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var time: Time? {
        didSet {
            guard let time = time else {
                print("Error loading start time")
                return
            }
            
            timeLabel.text = time.format(duration: nil)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(timeLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()

        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.2)
        ])
    }
    
    func showSelected() {
        imageView.image = UIImage(named: "SelectedLongHex")
    }
    
    func showUnselected() {
        imageView.image = UIImage(named: "LongHex")
    }
}

