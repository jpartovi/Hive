//
//  StartEventViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/3/22.
//

import Foundation
import UIKit
import Messages

class StartEventViewController: MSMessagesAppViewController {
    
    var delegate: StartEventViewControllerDelegate?
    static let storyboardID = String(describing: StartEventViewController.self)
    
    let types = EventType.allCases
    
    @IBOutlet weak var typesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTypesCollectionView()
        /*
        print("Subviews:")
        printSubviews(view: self.view)
        print("Done")
         */
    }
    
    func printSubviews(view: UIView, indentation: Int = 0) {
        for subview in view.subviews {
            print(String(repeating: "=", count: (3 * indentation)))
            print(type(of: subview))
            if !subview.subviews.isEmpty {
                printSubviews(view: subview, indentation: indentation + 1)
            }
        }
    }
    
    func setUpTypesCollectionView() {
        typesCollectionView.dataSource = self
        typesCollectionView.delegate = self
        let layout = HexLayout()
        
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = -30
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 130, height: 150)
        typesCollectionView.collectionViewLayout = layout
        typesCollectionView.reloadData()
    }
    
    func nextPage(type: EventType) {
        
        let event = Event(title: type.defaultTitle(), type: type)
        
        let locationsVC = (storyboard?.instantiateViewController(withIdentifier: LocationsViewController.storyboardID) as? LocationsViewController)!
        locationsVC.event = event
        self.navigationController?.pushViewController(locationsVC, animated: true)
        self.requestPresentationStyle(.expanded)
    }
    
    @objc func hexTapped(sender: UIButton) {
        print(types[sender.tag].defaultTitle())
        
        //typesCollectionView.bringSubviewToFront(typesCollectionView.cellForItem(at: IndexPath(index: sender.tag))!)
        nextPage(type: types[sender.tag])
    }
}

extension StartEventViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        types.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = typesCollectionView.dequeueReusableCell(withReuseIdentifier: EventTypeCell.reuseIdentifier, for: indexPath) as! EventTypeCell
        
        cell.hexButton.setTitle(types[indexPath.row].defaultTitle(), for: .normal)
        cell.hexButton.tag = indexPath.row
        cell.hexButton.addTarget(nil, action: #selector(hexTapped(sender:)), for: .touchUpInside)
        
        //typesCollectionView.bringSubviewToFront(typesCollectionView.cellForItem(at: IndexPath(index: sender.tag))!)
        typesCollectionView.sendSubviewToBack(cell)
        /*
        let hexBorder: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(named: "HexBorder")?.size(width: 130, height: 150)
            return imageView
        }()
        
        cell.sub.addSubview(hexBorder)
        
        NSLahexBorder    UIImageView    0x00007fc068214b40youtConstraint.activate([
            hexBorder.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
            hexBorder.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
        ])
        */
        return cell
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
}

class HexLayout: UICollectionViewFlowLayout {
    
    let cellWidth = CGFloat(130)
    let cellHeight = CGFloat(150)
    let xOverlap = CGFloat(14)
    let yOverlap = CGFloat(53)
    
    lazy var offset: CGFloat = (cellWidth - xOverlap) / 2

    var cellPadding: CGFloat = 0

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

