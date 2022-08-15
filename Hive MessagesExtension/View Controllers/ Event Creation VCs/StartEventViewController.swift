//
//  StartEventViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/3/22.
//

import Foundation
import UIKit
import Messages

class StartEventViewController: StyleViewController {
    
    var delegate: StartEventViewControllerDelegate?
    static let storyboardID = String(describing: StartEventViewController.self)
    
    let types = EventType.allCases
    
    var expandToNext = false
    var selectedType: EventType!
    
    @IBOutlet weak var promptLabel: StyleLabel!
    @IBOutlet weak var typesCollectionView: UICollectionView!
    @IBOutlet weak var typesCollectionViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet var compactConstraints: [NSLayoutConstraint]!
    
    @IBOutlet var expandedConstraints: [NSLayoutConstraint]!
    
    
    lazy var hexLayout: HexLayout = {
        let layout = HexLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 130, height: 150)
        return layout
    }()
    
    lazy var hexBordersCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 200), collectionViewLayout: hexLayout)
        collectionView.register(HexBorderCell.self, forCellWithReuseIdentifier: HexBorderCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.setBackgroundColor()
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        promptLabel.style(text: "What are you hosting?")
        promptLabel.adjustHeight()
        
        setUpHexCollection()
        conformToPresentationStyle(presentationStyle: self.presentationStyle)
    }
    
    func conformToPresentationStyle(presentationStyle: MSMessagesAppPresentationStyle) {
        print("Conform")
        switch presentationStyle {
        case .compact:
            print("compact")
            hexLayout.scrollDirection = .horizontal
            
            hexLayout.numberOfRows = 1
            hexLayout.numberOfColumns = types.count
            hexLayout.edgeInset = self.view.frame.width/2 - 65 //50
            
            for constraint in compactConstraints {
                constraint.isActive = true
            }
            for constraint in expandedConstraints {
                constraint.isActive = false
            }
            
        case .expanded:
            hexLayout.scrollDirection = .vertical
            hexLayout.numberOfColumns = 2
            hexLayout.numberOfRows = Int((CGFloat(types.count) / CGFloat(hexLayout.numberOfColumns)).rounded(.up))
            hexLayout.edgeInset = 0
            
            for constraint in expandedConstraints {
                constraint.isActive = true
            }
            for constraint in compactConstraints {
                constraint.isActive = false
            }
            
        default:
            break
        }
        
        hexLayout.prepare()
        typesCollectionViewWidthConstraint.constant = min(hexLayout.contentWidth, view.frame.width)// - (16 * 2))
        typesCollectionView.collectionViewLayout = hexLayout
        hexBordersCollectionView.collectionViewLayout = hexLayout
        typesCollectionView.reloadData()
        typesCollectionView.layoutIfNeeded()
    }
 
    func setUpHexCollection() {
        
        typesCollectionView.dataSource = self
        typesCollectionView.delegate = self
        
        
        typesCollectionView.collectionViewLayout = hexLayout
        typesCollectionView.setBackgroundColor(color: Colors.backgroundColor.withAlphaComponent(0))
        typesCollectionView.reloadData()
        
        view.addSubview(hexBordersCollectionView)
        
        view.sendSubviewToBack(hexBordersCollectionView)
        hexBordersCollectionView.dataSource = self
        hexBordersCollectionView.delegate = self
        
        hexBordersCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSLayoutConstraint.activate([
            hexBordersCollectionView.topAnchor.constraint(equalTo: typesCollectionView.topAnchor),
            hexBordersCollectionView.bottomAnchor.constraint(equalTo: typesCollectionView.bottomAnchor),
            hexBordersCollectionView.leftAnchor.constraint(equalTo: typesCollectionView.leftAnchor),
            hexBordersCollectionView.rightAnchor.constraint(equalTo: typesCollectionView.rightAnchor),
            
        ])
    }
    
    func expandAndNextPage() {
        if presentationStyle == .compact {
            expandToNext = true
            self.requestPresentationStyle(.expanded)
            //triggers code in MessagesViewController that calls nextPage after completion
        } else {
            nextPage()
        }
    }

    func nextPage() {
        
        self.requestPresentationStyle(.expanded)
        let event = Event(title: selectedType.defaultTitle(), type: selectedType)
        let locationsVC = (storyboard?.instantiateViewController(withIdentifier: LocationsViewController.storyboardID) as? LocationsViewController)!
        locationsVC.event = event
        self.navigationController?.pushViewController(locationsVC, animated: true)
    }
    
    @objc func hexTapped(sender: UIButton) {
        selectedType = types[sender.tag]
        expandAndNextPage()
    }
}

extension StartEventViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        types.count//12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case typesCollectionView:
            let cell = typesCollectionView.dequeueReusableCell(withReuseIdentifier: EventTypeHexCell.reuseIdentifier, for: indexPath) as! EventTypeHexCell

            cell.hexButton.style(title: types[indexPath.row].label(), imageTag: "HexFill")
            cell.hexButton.tag = indexPath.row
            cell.hexButton.addTarget(nil, action: #selector(hexTapped(sender:)), for: .touchUpInside)
    
            return cell
        case hexBordersCollectionView:
            let cell = hexBordersCollectionView.dequeueReusableCell(withReuseIdentifier: HexBorderCell.reuseIdentifier, for: indexPath) as! HexBorderCell
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension StartEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //print(types[indexPath.row].defaultTitle())
        //nextPage(type: types[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
     
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = 130
        let height = 150
        
        return CGSize(width: width, height: height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        var slaveTable: UIScrollView? = nil
            
        if scrollView == typesCollectionView {
            slaveTable = hexBordersCollectionView
        } else {
            return
        }
        
        let offset: CGPoint
        
        if hexLayout.scrollDirection == .vertical {
            if scrollView.contentOffset.x != 0 {
                scrollView.contentOffset.x = 0
            }
            offset = CGPoint(x: slaveTable!.contentOffset.x, y: scrollView.contentOffset.y)
        } else {
            if scrollView.contentOffset.y != 0 {
                scrollView.contentOffset.y = 0
            }
            offset = CGPoint(x: scrollView.contentOffset.x, y: slaveTable!.contentOffset.y)
        }
        
        
        slaveTable?.setContentOffset(offset, animated: false)
        /*
        var slaveTable: UIScrollView? = nil
            
        if typesCollectionView == scrollView {
            slaveTable = hexBordersCollectionView
        } else if hexBordersCollectionView == scrollView {
            slaveTable = self.typesCollectionView
        }
        let offset: CGPoint
        if false {
            offset = CGPoint(x: slaveTable!.contentOffset.x, y: scrollView.contentOffset.y)
        } else {
            offset = CGPoint(x: scrollView.contentOffset.x, y: slaveTable!.contentOffset.y)
        }
        
        
        slaveTable?.setContentOffset(offset, animated: false)
         */
    }
}

class HexLayout: UICollectionViewFlowLayout {
    
    lazy var cellWidth = self.itemSize.width
    lazy var cellHeight = self.itemSize.height
    let xOverlap: CGFloat = 14
    let yOverlap: CGFloat = 53
    var numberOfColumns = 2
    var numberOfRows = 3
    var edgeInset: CGFloat = 16
    
    lazy var cellPadding = CGFloat(14)
    
    lazy var offset: CGFloat = (cellWidth - xOverlap) / 2

    var cache = [UICollectionViewLayoutAttributes]()
    
    var contentWidth: CGFloat!
    var contentHeight: CGFloat!
    
    override func prepare() {

        cache = []
        guard let collectionView = collectionView else {
            return
        }
        
        contentHeight = (cellHeight * CGFloat(numberOfRows)) - (yOverlap * CGFloat(numberOfRows - 1))
        contentWidth = {
            var width = (cellWidth * CGFloat(numberOfColumns)) - (xOverlap * CGFloat(numberOfColumns - 1))
            if numberOfRows > 1 {
                width += offset
            }
            width += edgeInset * 2
            return width
        }()
        
        //let numberOfRows = Int((CGFloat(collectionView.numberOfItems(inSection: 0)) / CGFloat(numberOfColumns)).rounded(.up))
        
        var xOffset = [CGFloat]()
        var yOffset = [CGFloat]()
        
        for rowIndex in 0 ..< numberOfRows {
            yOffset.append(CGFloat(rowIndex) * (cellHeight - yOverlap))
        }
        
        for rowIndex in 0 ..< numberOfRows {
            xOffset.append((rowIndex % numberOfColumns == 0) ? 0 : offset)
        }

        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexInRow = item % numberOfColumns
            let columnOffest = CGFloat(indexInRow) * (cellWidth - xOverlap)
            let row = Int((CGFloat(item) / CGFloat(numberOfColumns)).rounded(.down))

            let indexPath = IndexPath(item: item, section: 0)

            // Calculate insetFrame that can be set to the attribute
            let frame = CGRect(x: xOffset[row] + columnOffest + edgeInset, y: yOffset[row], width: cellWidth, height: cellHeight)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            // Create an instance of UICollectionViewLayoutAttribute, sets its frame using insetFrame and appends the attributes to cache.
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
        }
    }
    
    // Using contentWidth and contentHeight from previous steps, calculate collectionViewContentSize.
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}

protocol StartEventViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: StartEventViewController)
}

class EventTypeHexCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: EventTypeHexCell.self)
    
    let hexButton: HexButton = {
        let button = HexButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.size(height: 116, textSize: 20)
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.contentView.addSubview(hexButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            hexButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            hexButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

class HexBorderCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: HexBorderCell.self)
    
    let hexBorder: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "HexBorder")?.size(width: 130, height: 150)
        imageView.clipsToBounds = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        
        self.contentView.addSubview(hexBorder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            hexBorder.centerXAnchor.constraint(equalTo: centerXAnchor),
            hexBorder.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
