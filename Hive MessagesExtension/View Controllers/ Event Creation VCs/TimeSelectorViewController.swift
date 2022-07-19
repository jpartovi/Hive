//
//  TimeSelectorViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/17/22.
//

// TODO: Custom Time

import UIKit
import Messages

class TimeSelectorViewController: UIViewController {
    
    static let storyboardID = String(describing: TimeSelectorViewController.self)
    
    var event: Event! = nil
    lazy var startTimes: [Time] = event.type.getStartTimes()
    var startTimesSelectionKey: [(Time, Bool)] = []
    var selectedTimes = [Time]()
    var anyStartTimeSelected: Bool = false
    lazy var durations: [Duration?] = [nil] + event.type.getDurations()
    lazy var selectedDuration: Duration? = event.duration
    
    @IBOutlet weak var promptLabel: StyleLabel!
    @IBOutlet weak var durationPicker: UIPickerView!
    @IBOutlet weak var durationView: UIStackView!
    @IBOutlet weak var includeDurationButton: UIButton!
    
    @IBAction func includeDurationButtonPressed(_ sender: Any) {
        
        showDurationPicker()
    }
    @IBOutlet weak var startTimesCollectionView: UICollectionView!
    let cellsPerRow = 2
    let rows = 3
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    @IBOutlet weak var nextButton: ContinueHexButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHexFooter()
                
        promptLabel.style(text: "What time(s) might this event start?")
        
        durationPicker.dataSource = self
        durationPicker.delegate = self
        
    
        startTimesCollectionView.contentInsetAdjustmentBehavior = .always
        startTimesCollectionView.register(StartTimeCell.self, forCellWithReuseIdentifier: StartTimeCell.reuseIdentifier)
        startTimesCollectionView.dataSource = self
        startTimesCollectionView.delegate = self
        
        updateNextButtonStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        selectedTimes = event.times
        loadStartTimeSelectionKey()
        startTimesCollectionView.reloadData()
        
        navigationController?.delegate = self
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
        
        nextPage()
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
            nextButton.color()
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
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TimeSelectorViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var (startTime, isSelected) = startTimesSelectionKey[indexPath.row]
        isSelected = !isSelected
        startTimesSelectionKey[indexPath.row] = (startTime, isSelected)
        startTimesCollectionView!.reloadData()
        if !event.daysAndTimes.isEmpty {
            for day in event.days {
                event.daysAndTimes[day]?.append(startTime)
            }
        }
        
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
        let width = Int(collectionView.frame.width - marginsAndInsets) / cellsPerRow
        let height = 50
        
        return CGSize(width: width, height: height)
    }
}

extension TimeSelectorViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if type(of: viewController) == DaySelectorViewController.self {
            updateEventObject()
            print("TimeVC sent")
            print(event.days)
            (viewController as? DaySelectorViewController)?.event = event
        }
    }
}

class StartTimeCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: StartTimeCell.self)
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = Style.lightTextColor
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

        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func showSelected() {
        // TODO: Show selected
        imageView.image = UIImage(named: "SelectedLongHex")?.size(width: self.frame.width, height: self.frame.width)
    }
    
    func showUnselected() {
        // TODO: Show unselected
        imageView.image = UIImage(named: "LongHex")?.size(width: self.frame.width, height: self.frame.width)

    }
}

