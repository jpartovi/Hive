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

class LocationsViewController: UIViewController {
    
    static let storyboardID = String(describing: LocationsViewController.self)
    
    var event: Event! = nil
    lazy var locations = event.locations
    
    //var anyLocationSelected: Bool = false
    
    var addressEditingIndex: Int? = nil
    
    var locationNamesFilled: Bool = false
    
    @IBOutlet weak var addLocationButton: HexButton!
    
    @IBOutlet weak var locationsTableView: UITableView!
    
    @IBOutlet weak var continueButton: ContinueHexButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLocationButton.style(imageTag: "LongHex", width: 150, height: 70, textColor: Style.lightTextColor, font: .systemFont(ofSize: 18))
        
        locationsTableView.dataSource = self
        locationsTableView.delegate = self
        locationsTableView.separatorStyle = .none
        locationsTableView.showsVerticalScrollIndicator = false
        locationsTableView.reloadData()
        
        updateContinueButtonStatus()
    }
        
    @IBAction func addLocationButtonPressed(_ sender: Any) {
        
        locations.append(Location(title: "", place: nil))
        locationsTableView.reloadData()
        
        let lastCellIndexPath = IndexPath(row: 0, section: locations.count - 1)
        locationsTableView.scrollToRow(at: lastCellIndexPath, at: .bottom, animated: false)
        let cell = locationsTableView.cellForRow(at: lastCellIndexPath) as! LocationCell
        cell.titleTextField.becomeFirstResponder()
        updateContinueButtonStatus()
        
        // TODO: make it so that the users cursor gets automatically put into the newest text field and keyboard opens
    }
    
    func updateContinueButtonStatus() {
        
        locationNamesFilled = true
        for location in locations {
            if location.title == "" {
                locationNamesFilled = false
            }
        }
        
        if locations.isEmpty {
            //anyLocationSelected = false
            continueButton.grey(title: "Skip")
        } else {
            //anyLocationSelected = true
            if locationNamesFilled {
                continueButton.color()
            } else {
                continueButton.grey()
            }
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        
        if locationNamesFilled {
            nextPage()
        } else {
            // TODO: Error???
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
        locationsTableView.deleteSections(IndexSet(integer: index), with: .fade)
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
    
    @objc func titleTextFieldDidChange(sender: UITextField) {
        if locations.indices.contains(sender.tag) {
            locations[sender.tag].title = sender.text ?? ""
            updateContinueButtonStatus()
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

extension LocationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = locationsTableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier, for: indexPath) as! LocationCell
        
        let location = locations[indexPath.section]
        
        cell.titleTextField.text = location.title
        cell.titleTextField.tag = indexPath.section
        cell.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(sender:)), for: .editingChanged)
        cell.deleteButton.tag = indexPath.section
        cell.deleteButton.addTarget(nil, action: #selector(deleteLocation(sender:)), for: .touchUpInside)
        cell.addOrRemoveAddressButton.tag = indexPath.section
        cell.addOrRemoveAddressButton.addTarget(nil, action: #selector(addOrRemoveAddress(sender:)), for: .touchUpInside)
        if let address = location.place?.formattedAddress {
            cell.addOrRemoveAddressButton.setTitle("- address", for: .normal)
            cell.changeAddressButton.isHidden = false
            cell.changeAddressButton.setTitle(address, for: .normal)
        } else {
            cell.addOrRemoveAddressButton.setTitle("+ address", for: .normal)
            cell.changeAddressButton.isHidden = true
        }
        
        return cell
    }
}

extension LocationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if locations[indexPath.section].place != nil {
            return 86
        } else {
            return 50
        }
        
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
     
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}

