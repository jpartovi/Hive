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
    
    @IBOutlet weak var promptLabel: StyleLabel!
    @IBOutlet weak var typesCollectionView: UICollectionView!
    
    let hexBordersCollectionView: UICollectionView = {
        let layout = HexLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = -30
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 130, height: 150)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 200), collectionViewLayout: layout)
        collectionView.register(HexBorderCell.self, forCellWithReuseIdentifier: HexBorderCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        DispatchQueue.main.async {
            var frame = self.typesCollectionView.frame
            frame.size.height = self.typesCollectionView.contentSize.height
            self.typesCollectionView.frame = frame
        }
        */
        promptLabel.style(text: "What kind of event are you hosting?")
        
        setUpHexCollection()
    }
 
    func setUpHexCollection() {
        typesCollectionView.dataSource = self
        typesCollectionView.delegate = self
        
        let layout = HexLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = -30
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 130, height: 150)
        typesCollectionView.collectionViewLayout = layout
        typesCollectionView.backgroundColor = UIColor.clear.withAlphaComponent(0)
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

    
    func nextPage(type: EventType) {
        
        self.requestPresentationStyle(.expanded)
        let event = Event(title: type.defaultTitle(), type: type)
        let locationsVC = (storyboard?.instantiateViewController(withIdentifier: LocationsViewController.storyboardID) as? LocationsViewController)!
        locationsVC.event = event
        self.navigationController?.pushViewController(locationsVC, animated: true)
    }
    
    @objc func hexTapped(sender: UIButton) {
        
        nextPage(type: types[sender.tag])
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
            
        if typesCollectionView == scrollView {
            slaveTable = hexBordersCollectionView;
        } else if hexBordersCollectionView == scrollView {
            slaveTable = self.typesCollectionView;
        }
        
        let offset: CGPoint = CGPoint(x: slaveTable!.contentOffset.x, y: scrollView.contentOffset.y)
        
        slaveTable?.setContentOffset(offset, animated: false)
    }
}

class HexLayout: UICollectionViewFlowLayout {
    
    lazy var cellWidth = self.itemSize.width
    lazy var cellHeight = self.itemSize.height
    let xOverlap = CGFloat(14)
    let yOverlap = CGFloat(53)
    let insets = CGFloat(14)
    
    lazy var cellPadding = insets
    
    lazy var offset: CGFloat = (cellWidth - xOverlap) / 2 //+ insets

    var cache = [UICollectionViewLayoutAttributes]()

    var contentHeight: CGFloat = 400
    var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override func prepare() {
        // If cache is empty and the collection view exists – calculate the layout attributes
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        
        let numberOfColumns = 2
        let numberOfRows = Int((CGFloat(collectionView.numberOfItems(inSection: 0)) / CGFloat(numberOfColumns)).rounded(.up))
        
        var xOffset = [CGFloat]()
        var yOffset = [CGFloat]()
        
        for rowIndex in 0 ..< numberOfRows {
            yOffset.append(CGFloat(rowIndex) * (cellHeight - yOverlap))
        }
        
        for rowIndex in 0 ..< numberOfRows {
            xOffset.append((rowIndex % 2 == 0) ? 0 : offset)
        }

        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexInRow = item % 2
            let columnOffest = CGFloat(indexInRow) * (cellWidth - xOverlap)
            let row = Int((CGFloat(item) / 2).rounded(.down))

            let indexPath = IndexPath(item: item, section: 0)

            // Calculate insetFrame that can be set to the attribute
            let frame = CGRect(x: xOffset[row] + columnOffest, y: yOffset[row], width: cellWidth, height: cellHeight)
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
        button.size(size: 116, textSize: 20)
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
