//
//  LocationsViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/6/22.
//

// TODO: Allow users to easily select previously used locations


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
    
    var isNewArray: [Bool] = []
    
    //var textFieldExpand: StyleTextField? = nil
    
    @IBOutlet weak var promptLabel: StyleLabel!
    @IBOutlet weak var addLocationButton: HexButton!
    
    @IBOutlet weak var locationsTableView: UITableView!
    
    @IBOutlet weak var continueButton: HexButton!
    
    
    @IBOutlet var compactConstraints: [NSLayoutConstraint]!
    
    @IBOutlet var expandedConstraints: [NSLayoutConstraint]!
    
    func changedConstraints(compact: Bool){
        
        if compact {
            promptLabel.font = Format.font(size: 20)
            for constraint in expandedConstraints {
                constraint.isActive = false
            }
            for constraint in compactConstraints {
                constraint.isActive = true
            }
        } else {
            promptLabel.font = Format.font(size: 30)
            for constraint in compactConstraints {
                constraint.isActive = false
            }
            for constraint in expandedConstraints {
                constraint.isActive = true
            }
        }

        locationsTableView.reloadData()
        
        /*if textFieldExpand != nil {
            textFieldExpand!.becomeFirstResponder()
            textFieldExpand = nil
        }*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHexFooter()
        
        promptLabel.style(text: "Do you know where you want to host?")
        
        //addLocationButton.style(imageTag: "LongHex", width: 150, height: 70, textColor: Style.lightTextColor, fontSize: 18)
        addLocationButton.size(size: 150, textSize: 18)
        addLocationButton.style(title: "Add Location", imageTag: "LongHex", textColor: Colors.lightTextColor)
        
        locationsTableView.dataSource = self
        locationsTableView.delegate = self
        locationsTableView.separatorStyle = .none
        locationsTableView.showsVerticalScrollIndicator = false
        locationsTableView.setBackgroundColor()
        
        updateLocations()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBOutlet weak var nextBottom: NSLayoutConstraint!
    
    @IBOutlet weak var tableBottom: NSLayoutConstraint!
    
    @IBOutlet weak var tableBottomKeyboard: NSLayoutConstraint!
    
    @objc func keyboardWillShow(notification: NSNotification) {
        /*
        let MVC = (self.parent?.parent as? MessagesViewController)!
        if MVC.presentationStyle == .compact {
            MVC.requestPresentationStyle(.expanded)
        }
         */
        self.requestPresentationStyle(.expanded)
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            tableBottom.isActive = false
            
            tableBottomKeyboard.constant = keyboardSize.height + 16
            
            tableBottomKeyboard.isActive = true
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        
        tableBottomKeyboard.isActive = false
        
        tableBottom.isActive = true
        
        /*if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }*/
        /*if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

            //nextBottom.constant -= keyboardSize.height - 90
        }*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for cell in locationsTableView.visibleCells {
            (cell as! LocationCell).titleTextField.colorStatus()
        }
    }
    
    func updateLocations() {
        locations = event.locations
        locationsTableView.reloadData()
        updateContinueButtonStatus()
    }
        
    @IBAction func addLocationButtonPressed(_ sender: Any) {
        
        locations.append(Location(title: "", place: nil, address: nil))
        isNewArray = [Bool](repeating: false, count: locations.count-1) + [true]
        locationsTableView.reloadData()
        
        DispatchQueue.main.async {
            let lastCellIndexPath = IndexPath(row: self.locations.count - 1, section: 0)
            self.locationsTableView.scrollToRow(at: lastCellIndexPath, at: .bottom, animated: false)
            let cell = self.locationsTableView.cellForRow(at: lastCellIndexPath) as! LocationCell
            cell.titleTextField.becomeFirstResponder()
            self.updateContinueButtonStatus()
        }
    }
    
    func updateContinueButtonStatus() {

        if locations.isEmpty {
            continueButton.grey(title: "Skip")
        } else {
            for location in locations {
                if location.title == "" {
                    continueButton.grey(title: "Done")
                    return
                }
            }
            continueButton.color(title: "Done")
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        
        isNewArray = [Bool](repeating: false, count: locations.count)
        locationsTableView.reloadData()
        
        for location in locations {
            if location.title == "" {
                return
            }
        }
        expandAndNextPage()
        
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
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        event?.locations = locations
        let dateSelectorVC = (storyboard?.instantiateViewController(withIdentifier: DaySelectorViewController.storyboardID) as? DaySelectorViewController)!
        dateSelectorVC.event = event
        self.navigationController?.pushViewController(dateSelectorVC, animated: true)
    }
    
    
    
    @objc func deleteLocation(sender: UIButton) {
        let cell = sender.superview?.superview as! LocationCell
        cell.titleTextField.resetColor()
        let indexPath =
        locationsTableView.indexPath(for: cell)!
        locations.remove(at: indexPath.row)
        isNewArray.remove(at: indexPath.row)
        CATransaction.begin()
        locationsTableView.beginUpdates()
        CATransaction.setCompletionBlock {
            self.locationsTableView.reloadData()
            self.updateContinueButtonStatus()
        }
        locationsTableView.deleteRows(at: [indexPath], with: .fade)
        locationsTableView.endUpdates()
        CATransaction.commit()
    }
    
    @objc func addOrRemoveAddress(sender: UIButton) {
        addressEditingIndex = sender.tag
        if locations[addressEditingIndex!].address == nil {
            let autocompleteViewController = GMSAutocompleteViewController()
            autocompleteViewController.delegate = self
            navigationController?.present(autocompleteViewController, animated: true)
        } else {
            
            locations[addressEditingIndex!].address = nil
            locationsTableView.reloadData()
        }
    }
    
    /*@objc func titleTextFieldDidBeginEditing(sender: StyleTextField) {
        let MVC = (self.parent?.parent as? MessagesViewController)!
        if MVC.presentationStyle == .compact {
            textFieldExpand = sender
            MVC.requestPresentationStyle(.expanded)
        }
        //sender.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
    }*/
    
    /*@objc func valueChanged(_ sender: StyleTextField){
        sender.tag
        
    }*/

    
    @objc func titleTextFieldDidChange(sender: StyleTextField) {
        if locations.indices.contains(sender.tag) {
            locations[sender.tag].title = sender.text ?? ""
            sender.isNew = false
            let indexPath =
            locationsTableView.indexPath(for: sender.superview?.superview as! LocationCell)!
            isNewArray[indexPath.row] = false
            sender.colorStatus()
            updateContinueButtonStatus()
        }
    }
    
    @objc func titleTextFieldDidFinishEditing(sender: StyleTextField) {
        if locations.indices.contains(sender.tag) {
            sender.colorStatus()
        }
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
        //cell.titleTextField.addTarget(self, action: #selector(titleTextFieldDidBeginEditing(sender:)), for: .editingDidBegin)
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
        cell.titleTextField.isNew = isNewArray[indexPath.row]
        cell.titleTextField.colorStatus()

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let verticalPadding: CGFloat = 8

        let maskLayer = CALayer()
        maskLayer.cornerRadius = LocationCell.cornerRadius
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
        
        (cell as? LocationCell)?.titleTextField.colorStatus()
        
    }
}

extension LocationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if locations[indexPath.row].address != nil {
            return 86
        } else {
            return 50
        }
        
    }
}

extension LocationsViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if type(of: viewController) == StartEventViewController.self {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            self.requestPresentationStyle(.expanded)
            (viewController as! StartEventViewController).expandToNext = false
        }
    }
}

extension LocationsViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        locations[addressEditingIndex!] = Location(title: locations[addressEditingIndex!].title, place: place)
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
        button.setTitleColor(Colors.greyColor, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        return button
    }()
    
    let addOrRemoveAddressButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Colors.primaryColor, for: .normal)
        return button
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
            addOrRemoveAddressButton.widthAnchor.constraint(equalToConstant: "+ address".size(withAttributes: [.font : addOrRemoveAddressButton.titleLabel!.font!]).width + 2),
            
            deleteButton.heightAnchor.constraint(equalToConstant: 26),//min(self.frame.height - (inset * 2), 30)),
            deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor),
            deleteButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        deleteButton.layer.cornerRadius = deleteButton.frame.height / 2
        titleTextField.style(placeholderText: "Name (eg. My House)")
    }
}
