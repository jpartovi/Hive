//
//  LocationsViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/6/22.
//

// TODO: List
/*
 - Allow users to easily select previously used locations
 - Don't allow nil titles
 */

import Foundation
import UIKit
import GooglePlaces
import Messages

class LocationsViewController: StyleViewController {
    
    static let storyboardID = String(describing: LocationsViewController.self)
    
    var event: Event! = nil
    var locations = [Location]()
    
    var addressEditingIndex: Int? = nil
    
    var expandToNext: Bool = false
    
    @IBOutlet weak var promptLabel: StyleLabel!
    @IBOutlet weak var addLocationButton: HexButton!
    
    @IBOutlet weak var locationsTableView: UITableView!
    
    @IBOutlet weak var continueButton: HexButton!
    
    
    @IBOutlet var compactConstraints: [NSLayoutConstraint]!
    
    @IBOutlet var expandedConstraints: [NSLayoutConstraint]!
    
    var textFields = [StyleTextField]()
    
    func changedConstraints(compact: Bool){
        print("changed")
        
        if compact {
            promptLabel.font = Style.font(size: 20)
            for constraint in expandedConstraints {
                constraint.isActive = false
            }
            for constraint in compactConstraints {
                constraint.isActive = true
            }
        } else {
            promptLabel.font = Style.font(size: 30)
            for constraint in compactConstraints {
                constraint.isActive = false
            }
            for constraint in expandedConstraints {
                constraint.isActive = true
            }
        }

        locationsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableTouchAwayKeyboardDismiss()
        
        addHexFooter()
        
        promptLabel.style(text: "Do you know where you want to host?")
        
        //addLocationButton.style(imageTag: "LongHex", width: 150, height: 70, textColor: Style.lightTextColor, fontSize: 18)
        addLocationButton.size(size: 150, textSize: 18)
        addLocationButton.style(title: "Add Location", imageTag: "LongHex", textColor: Style.lightTextColor)
        
        locationsTableView.dataSource = self
        locationsTableView.delegate = self
        locationsTableView.separatorStyle = .none
        locationsTableView.showsVerticalScrollIndicator = false
        
        updateLocations()
        updateTextFieldList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.delegate = self
    }
    
    func updateLocations() {
        locations = event.locations
        locationsTableView.reloadData()
        updateContinueButtonStatus()
    }
        
    @IBAction func addLocationButtonPressed(_ sender: Any) {
        
        locations.append(Location(title: "", place: nil, address: nil))
        locationsTableView.reloadData()
        
        let lastCellIndexPath = IndexPath(row: locations.count - 1, section: 0)
        locationsTableView.scrollToRow(at: lastCellIndexPath, at: .bottom, animated: false)
        let cell = locationsTableView.cellForRow(at: lastCellIndexPath) as! LocationCell
        cell.titleTextField.becomeFirstResponder()
        updateContinueButtonStatus()
        
        // TODO: make it so that the users cursor gets automatically put into the newest text field and keyboard opens
    }
    
    func updateTextFieldList() {
        textFields = []
        for (index, _) in locations.enumerated() {
            let cell = locationsTableView.cellForRow(at: IndexPath(item: index, section: 0)) as! LocationCell
            textFields.append(cell.titleTextField)
        }
    }
    
    func updateContinueButtonStatus() {

        updateTextFieldList()
        
        if locations.isEmpty {
            continueButton.grey(title: "Skip")
        } else {
            if textFieldsFull(textFields: textFields, withDisplay: false) {
                continueButton.color(title: "Next")
            } else {
                continueButton.grey(title: "Next")
            }
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        
        updateTextFieldList()
        
        if textFieldsFull(textFields: textFields, withDisplay: true) {
            expandAndNextPage()
        } else {
            // TODO: Error???
        }
        
    }
    
    func expandAndNextPage() {
        let MVC = (self.parent?.parent as? MessagesViewController)!
        if MVC.presentationStyle == .compact {
            expandToNext = true
            MVC.requestPresentationStyle(.expanded)
            //triggers code in MessagesViewController that calls nextPage after completion
        } else {
            nextPage()
        }
    }
    
    func nextPage() {
        
        event?.locations = locations
        let dateSelectorVC = (storyboard?.instantiateViewController(withIdentifier: DaySelectorViewController.storyboardID) as? DaySelectorViewController)!
        dateSelectorVC.event = event
        self.navigationController?.pushViewController(dateSelectorVC, animated: true)
    }
    
    
    
    @objc func deleteLocation(sender: UIButton) {
        locationsTableView.reloadData()
        let index = sender.tag
        locations.remove(at: index)
        locationsTableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .fade)
        updateContinueButtonStatus()
    }
    
    @objc func addOrRemoveAddress(sender: UIButton) {
        addressEditingIndex = sender.tag
        if locations[addressEditingIndex!].place == nil {
            let autocompleteViewController = GMSAutocompleteViewController()
            autocompleteViewController.delegate = self
            navigationController?.present(autocompleteViewController, animated: true)
        } else {
            locations[addressEditingIndex!].place = nil
            locationsTableView.reloadData()
        }
    }
    
    @objc func titleTextFieldDidChange(sender: StyleTextField) {
        if locations.indices.contains(sender.tag) {
            locations[sender.tag].title = sender.text ?? ""
            sender.getStatus(withDisplay: true)
            updateContinueButtonStatus()
        }
    }
    
    @objc func titleTextFieldDidFinishEditing(sender: StyleTextField) {
        if locations.indices.contains(sender.tag) {
            //sender.getStatus()
        }
    }
}

extension LocationsViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        //print(Location(title: locations[addressEditingIndex!].title, place: Location.getPlaceFromID(id: place.placeID!)))
        
        locations[addressEditingIndex!] = Location(title: locations[addressEditingIndex!].title, place: place, address: place.formattedAddress!)
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

extension LocationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = locationsTableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier, for: indexPath) as! LocationCell
        
        let location = locations[indexPath.row]
        
        cell.titleTextField.text = location.title
        cell.titleTextField.tag = indexPath.row
        cell.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(sender:)), for: .editingChanged)
        cell.titleTextField.addTarget(self, action: #selector(titleTextFieldDidFinishEditing(sender:)), for: .editingDidEnd)
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
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let verticalPadding: CGFloat = 8

        let maskLayer = CALayer()
        maskLayer.cornerRadius = LocationCell.cornerRadius
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
}

extension LocationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if locations[indexPath.row].place != nil {
            return 86
        } else {
            return 50
        }
        
    }
}

extension LocationsViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if type(of: viewController) == StartEventViewController.self {
            self.requestPresentationStyle(.expanded)
        }
    }
}

// TODO: In compact view, the text field doesn't shrink

class LocationCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: LocationCell.self)
    
    static let cornerRadius: CGFloat = 20
    
    let titleTextField: StyleTextField = {
        let textField = StyleTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addDoneButton()
        return textField
    }()
    
    let changeAddressButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Style.greyColor, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        return button
    }()
    
    let addOrRemoveAddressButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Style.primaryColor, for: .normal)
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("X", for: .normal)
        
        button.backgroundColor = Style.greyColor
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = Style.lightGreyColor
        
        self.contentView.addSubview(titleTextField)
        self.contentView.addSubview(changeAddressButton)
        self.contentView.addSubview(addOrRemoveAddressButton)
        self.contentView.addSubview(deleteButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let inset: CGFloat = 10

        NSLayoutConstraint.activate([
            titleTextField.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            titleTextField.rightAnchor.constraint(equalTo: addOrRemoveAddressButton.leftAnchor, constant: -inset),
            titleTextField.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleTextField.heightAnchor.constraint(equalToConstant: 26),
        
            changeAddressButton.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            changeAddressButton.rightAnchor.constraint(equalTo: deleteButton.leftAnchor, constant: -inset),
            changeAddressButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            changeAddressButton.heightAnchor.constraint(equalToConstant: 26),
            
            addOrRemoveAddressButton.rightAnchor.constraint(equalTo: deleteButton.leftAnchor, constant: -inset),
            addOrRemoveAddressButton.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            addOrRemoveAddressButton.heightAnchor.constraint(equalToConstant: 26),
            addOrRemoveAddressButton.widthAnchor.constraint(equalToConstant: 80),
            
            deleteButton.heightAnchor.constraint(equalToConstant: 26),//min(self.frame.height - (inset * 2), 30)),
            deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor),
            deleteButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        deleteButton.layer.cornerRadius = deleteButton.frame.height / 2
        titleTextField.style(placeholderText: "Name (eg. My House)")
    }
}
