//
//  DaySelectorViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/21/22.
//

// TODO: Highlight weekends?

import Foundation
import UIKit

class DaySelectorViewController: StyleViewController {
    
    static let storyboardID = String(describing: DaySelectorViewController.self)
    
    var event: Event! = nil
    var selectedDays = [Day]()
    
    var compactView: Bool = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var promptLabel: StyleLabel!
    @IBOutlet weak var weekDayLabels: UIStackView!
    
    @IBOutlet weak var monthLabel: StyleLabel!
    
    @IBOutlet weak var sunLabel: StyleLabel!
    @IBOutlet weak var monLabel: StyleLabel!
    @IBOutlet weak var tueLabel: StyleLabel!
    @IBOutlet weak var wedLabel: StyleLabel!
    @IBOutlet weak var thuLabel: StyleLabel!
    @IBOutlet weak var friLabel: StyleLabel!
    @IBOutlet weak var satLabel: StyleLabel!
    
    
    @IBOutlet var expandedConstraints: [NSLayoutConstraint]!
    @IBOutlet var compactConstraints: [NSLayoutConstraint]!
    
    var anyDaySelected: Bool = false
    
    var cellsPerRow = 7
    var rows = 3
    let inset: CGFloat = 0//10
    let minimumLineSpacing: CGFloat = 0 //10
    let minimumInteritemSpacing: CGFloat = 0 //10
    
    var today = Date()
    
    let line = CALayer()
    
    //let calendar = Calendar(identifier: .gregorian)
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    @IBOutlet var calendarCollectionView: UICollectionView!
    @IBOutlet weak var nextButton: HexButton!
    
    var calendarDays = [CalendarDay]()
    
    var expandToNext: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHexFooter()
        
        promptLabel.style(text: "Which day(s) might work?")
        
        underlineWeekDayLabels()
    
        calendarCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        calendarCollectionView!.contentInsetAdjustmentBehavior = .always
        calendarCollectionView!.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.reuseIdentifier)
        
        calendarCollectionView!.dataSource = self
        calendarCollectionView!.delegate = self
        calendarCollectionView.setBackgroundColor()
        
        updateSelections()
        calendarCollectionView!.reloadData()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(calendarCollectionView!)
        scrollView.delegate = self
        updateContentView()
        
        formatDayOfWeekLabels()
    }
    
    func formatDayOfWeekLabels() {
        sunLabel.style(text: "S", textColor: Colors.darkTextColor, fontSize: 18)
        monLabel.style(text: "M", textColor: Colors.darkTextColor, fontSize: 18)
        tueLabel.style(text: "T", textColor: Colors.darkTextColor, fontSize: 18)
        wedLabel.style(text: "W", textColor: Colors.darkTextColor, fontSize: 18)
        thuLabel.style(text: "T", textColor: Colors.darkTextColor, fontSize: 18)
        friLabel.style(text: "F", textColor: Colors.darkTextColor, fontSize: 18)
        satLabel.style(text: "S", textColor: Colors.darkTextColor, fontSize: 18)
    }
    
    func updateSelections() {

        selectedDays = event.days
        calendarDays = generateDays(for: today)
        calendarCollectionView?.reloadData()
        updateNextButtonStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadMonthLabel()
    }
    
    func changedConstraints(compact: Bool){
        
        compactView = compact
        
        if compact {
            promptLabel.font = Format.font(size: 20)
            cellsPerRow = 21
            rows = 1
            for constraint in expandedConstraints {
                constraint.isActive = false
            }
            for constraint in compactConstraints {
                constraint.isActive = true
            }
            
            line.isHidden = true
            weekDayLabels.isHidden = true
            monthLabel.isHidden = false
            line.removeFromSuperlayer()
        } else {
            promptLabel.font = Format.font(size: 30)
            cellsPerRow = 7
            rows = 3
            line.isHidden = false
            weekDayLabels.isHidden = false
            calendarCollectionView!.layer.addSublayer(line)
            for constraint in compactConstraints {
                constraint.isActive = false
            }
            for constraint in expandedConstraints {
                constraint.isActive = true
            }
        }
        updateContentView()
        calendarCollectionView!.reloadData()
        loadMonthLabel()
    }
    
    func updateContentView() {
        scrollView.contentSize.width = scrollView.subviews.sorted(by: { $0.frame.maxX < $1.frame.maxX }).last?.frame.maxX ?? scrollView.contentSize.width
    }
    
    func updateEventObject() {
        selectedDays = []
        
        for calendarDay in calendarDays {
            if calendarDay.isSelected {
                
                selectedDays.append(calendarDay.day)
            }
        }
        event?.days = selectedDays
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
        
        if event.type == .allDay {
            let confirmVC = (storyboard?.instantiateViewController(withIdentifier: ConfirmViewController.storyboardID) as? ConfirmViewController)!
            confirmVC.event = event
            self.navigationController?.pushViewController(confirmVC, animated: true)
        } else {
            let timeSelectorVC = (storyboard?.instantiateViewController(withIdentifier: TimeSelectorViewController.storyboardID) as? TimeSelectorViewController)!
            timeSelectorVC.event = event
            self.navigationController?.pushViewController(timeSelectorVC, animated: true)
        }
        
    }
    
    func loadMonthLabel() {
        let calendar = Calendar.current
        
        let text: String
        
        if compactView {
            
            var belowIndex: Int
            
            if let cellWidth = calendarCollectionView?.cellForItem(at: IndexPath(row: 0, section: 0))?.frame.width {
                belowIndex = Int(floor(scrollView.contentOffset.x/cellWidth + 2.5))
            } else {
                belowIndex = 0
            }
            
            let belowDate: Day
            
            if belowIndex < 0 {
                belowDate = calendarDays[0].day
            } else if belowIndex >= calendarDays.count {
                belowDate = calendarDays.last!.day
            } else {
                belowDate = calendarDays[belowIndex].day
            }
            
            let month = calendar.component(.month, from: belowDate.date)
            //let components = calendar.dateComponents([.day,.month,.year], from: belowDate.date)
            //let month = components.month!
            text = DateFormatter().monthSymbols[month - 1]
        } else {
            let month1 = calendar.component(.month, from: (calendarDays.first?.day.date)!)
            let month2 = calendar.component(.month, from: (calendarDays.last?.day.date)!)
            
            if month1 == month2 {
                text = DateFormatter().monthSymbols[month1 - 1]
            } else {
                text = DateFormatter().monthSymbols[month1 - 1] + "/" + DateFormatter().monthSymbols[month2 - 1]
            }
        }
        
        monthLabel.style(text: text, textColor: Colors.darkTextColor, fontSize: 18)
    }
    
    func underlineWeekDayLabels() {
        let lineThickness = CGFloat(2)
        line.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width - 32, height: lineThickness)
        line.backgroundColor = Colors.greyColor.cgColor
        calendarCollectionView!.layer.addSublayer(line)
    }
    
    func monthMetadata(for today: Date) throws -> MonthMetadata {

        guard
            let numberOfDaysInMonth = calendar.range(
                of: .day,
                in: .month,
                for: today)?.count,
            let firstDayOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: today))
            else {
                // 3
                fatalError("Month Metadata generation error")
            }

        let firstDayWeekday = calendar.component(.weekday, from: today)

        return MonthMetadata(
            numberOfDays: numberOfDaysInMonth,
            firstDay: firstDayOfMonth,
            firstDayWeekday: firstDayWeekday)
    }
    
    func generateDays(for today: Date) -> [CalendarDay] {
        
        guard let metadata = try? monthMetadata(for: today) else {
          preconditionFailure("An error occurred when generating the metadata for \(today)")
        }

        let numberOfDaysInMonth = metadata.numberOfDays
        let offsetInInitialRow = metadata.firstDayWeekday
        //let firstDayOfMonth = metadata.firstDay

        var days: [CalendarDay] = []
        
        //let firstDay = Int(dateFormatter.string(from: today))! - offsetInInitialRow + 1
        
        for day in (1...(cellsPerRow * rows)) {
            
            let inFuture = day >= offsetInInitialRow
            
            let dayOffset = day - offsetInInitialRow
            
            let inNextMonth = day > numberOfDaysInMonth - Int(dateFormatter.string(from: today))! + offsetInInitialRow

            days.append(generateDay(
                offsetBy: dayOffset,
                for: today,
                inFuture: inFuture,
                inNextMonth: inNextMonth))
        }
        
        days[offsetInInitialRow - 1].isToday = true

        return days
    }

    func generateDay(offsetBy dayOffset: Int, for today: Date, inFuture: Bool, inNextMonth: Bool) -> CalendarDay {
          
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today) ?? today
        
        var isSelected = false
        for day in selectedDays {
            if day.sameAs(date: date) {
                isSelected = true
                break
            }
        }
        
        return CalendarDay(
            day: Day(date: date),
            number: dateFormatter.string(from: date),
            isSelected: isSelected,
            inFuture: inFuture,
            inNextMonth: inNextMonth,
            isToday: false
        )
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        if anyDaySelected {
            updateEventObject()
            expandAndNextPage()
        }
    }
    
    func updateNextButtonStatus() {
        
        anyDaySelected = false
        
        for day in calendarDays {
            if day.isSelected {
                anyDaySelected = true
                break
            }
        }
        
        if anyDaySelected {
            nextButton.color(title: "Next")
        } else {
            nextButton.grey(title: "Next")
        }
    }
    
    
    
}

// MARK: - UICollectionViewDataSource
extension DaySelectorViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        calendarDays.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let day = calendarDays[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDayCell.reuseIdentifier, for: indexPath) as! CalendarDayCell

        cell.day = day
        
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (calendarCollectionView?.delegate as? DaySelectorViewController)!.compactView {
            if let cellWidth = calendarCollectionView?.cellForItem(at: IndexPath(row: 0, section: 0))?.frame.width {
                let belowIndex = Calendar.current.dateComponents([.day], from: calendarDays[0].day.date, to: today).day!
                scrollView.contentOffset.x = (CGFloat(belowIndex) - 2.1) * cellWidth
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DaySelectorViewController: UICollectionViewDelegateFlowLayout {
    
    // When a cell is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var day = calendarDays[indexPath.row]
        
        if day.inFuture {
            if !event.daysAndTimes.isEmpty {
                if day.isSelected {
                    event.daysAndTimes.removeValue(forKey: day.day)
                } else {
                    event.daysAndTimes[day.day] = event.times
                }
            }
            day.isSelected = !day.isSelected
            calendarDays[indexPath.row] = day
            calendarCollectionView!.reloadData()
        }
        
        updateNextButtonStatus()
    }
    
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        }*/

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let width = Int(collectionView.frame.width - marginsAndInsets) / cellsPerRow
        let height = width
        
        return CGSize(width: width, height: height)
    }
}



extension DaySelectorViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if type(of: viewController) == LocationsViewController.self {
            NotificationCenter.default.addObserver(viewController, selector: #selector((viewController as! LocationsViewController).keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(viewController, selector: #selector((viewController as! LocationsViewController).keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            self.requestPresentationStyle(.expanded)
            updateEventObject()
            (viewController as! LocationsViewController).event = event
            (viewController as! LocationsViewController).updateLocations()
            (viewController as! LocationsViewController).expandToNext = false
            (viewController as! LocationsViewController).isNewArray = [Bool](repeating: false, count: event.locations.count)
            
        }
    }
}

extension DaySelectorViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadMonthLabel()
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
    
}

struct CalendarDay {

    let day: Day
    let number: String
    var isSelected: Bool
    let inFuture: Bool
    let inNextMonth: Bool
    var isToday: Bool
}

struct MonthMetadata {
  let numberOfDays: Int
  let firstDay: Date
  let firstDayWeekday: Int
}

class CalendarDayCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: CalendarDayCell.self)
    
    private lazy var selectionBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = Colors.primaryColor
        return view
    }()
    /*
    private lazy var monthBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false//true
        view.layer.borderWidth = 2

        view.alpha = 0
        return view
    }()
    */
    var numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = Colors.darkTextColor
        return label
    }()

    var day: CalendarDay? {
        didSet {
            guard let day = day else { return }

            numberLabel.text = day.number

            style(inFuture: day.inFuture, inNextMonth: day.inNextMonth, isToday: day.isToday)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        isAccessibilityElement = true
        accessibilityTraits = .button
        
        //contentView.addSubview(monthBackgroundView)
        contentView.addSubview(selectionBackgroundView)
        contentView.addSubview(numberLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        // This allows for rotations and trait collection
        // changes (e.g. entering split view on iPad) to update constraints correctly.
        // Removing old constraints allows for new ones to be created
        // regardless of the values of the old ones
        NSLayoutConstraint.deactivate(selectionBackgroundView.constraints)

        let selectorSize = min(min(frame.width, frame.height) - 10, 60)

        
        NSLayoutConstraint.activate([
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            selectionBackgroundView.centerYAnchor.constraint(equalTo: numberLabel.centerYAnchor),
            selectionBackgroundView.centerXAnchor.constraint(equalTo: numberLabel.centerXAnchor),
            selectionBackgroundView.widthAnchor.constraint(equalToConstant: selectorSize),
            selectionBackgroundView.heightAnchor.constraint(equalTo: selectionBackgroundView.widthAnchor)//,
            
            //monthBackgroundView.centerYAnchor.constraint(equalTo: numberLabel.centerYAnchor),
            //monthBackgroundView.centerXAnchor.constraint(equalTo: numberLabel.centerXAnchor),
            //monthBackgroundView.widthAnchor.constraint(equalToConstant: frame.width + 1),
            //monthBackgroundView.heightAnchor.constraint(equalToConstant: frame.height)
        ])
         

        selectionBackgroundView.layer.cornerRadius = selectorSize / 2
    }
    
    func style(inFuture: Bool, inNextMonth: Bool, isToday: Bool) {
        
        guard let day = day else { return }
        

        if day.isSelected {
            selectionBackgroundView.isHidden = false
            numberLabel.textColor = Colors.lightTextColor
        } else {
            selectionBackgroundView.isHidden = true
            if !inFuture {
                numberLabel.textColor = Colors.greyColor
                //monthBackgroundView.backgroundColor = Style.lightTextColor
                //monthBackgroundView.layer.borderColor = Style.darkTextColor.withAlphaComponent(0).cgColor
            } else if inNextMonth {
                //monthBackgroundView.backgroundColor = Style.tertiaryColor
                //monthBackgroundView.layer.borderColor = Style.darkTextColor.withAlphaComponent(0).cgColor
                numberLabel.textColor = Colors.darkTextColor
            } else {
                //monthBackgroundView.backgroundColor = Style.secondaryColor
                if isToday {
                    //monthBackgroundView.layer.borderColor = Style.darkTextColor.withAlphaComponent(0).cgColor
                    numberLabel.textColor = Colors.primaryColor
                } else {
                    //monthBackgroundView.layer.borderColor = Style.darkTextColor.withAlphaComponent(0).cgColor
                    numberLabel.textColor = Colors.darkTextColor
                }
            }
        }
    }
}
