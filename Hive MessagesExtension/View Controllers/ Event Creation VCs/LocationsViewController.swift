//
//  LocationsViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/6/22.
//

import Foundation
import UIKit
import GooglePlaces

class LocationsViewController: UIViewController {
    
    static let storyboardID = String(describing: LocationsViewController.self)
    
    var event: Event! = nil
    lazy var locations = event.locations
    
    var anyLocationSelected: Bool = false
    
    @IBOutlet weak var selectedLocationsTableView: UITableView!
    
    @IBOutlet weak var nextButton: ContinueHexButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedLocationsTableView.dataSource = self
        selectedLocationsTableView.delegate = self
        selectedLocationsTableView.separatorStyle = .none
        selectedLocationsTableView.showsVerticalScrollIndicator = false
        selectedLocationsTableView.reloadData()
        
        updateNextButtonStatus()
    }
        
    @IBAction func addLocationButtonPressed(_ sender: Any) {
        let autocompleteViewController = GMSAutocompleteViewController()
        autocompleteViewController.delegate = self
        navigationController?.present(autocompleteViewController, animated: true)
    }
    
    func updateNextButtonStatus() {
        
        if locations.isEmpty {
            anyLocationSelected = false
            nextButton.grey(title: "Skip")
        } else {
            anyLocationSelected = true
            nextButton.color()
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        nextPage()
    }
    
    func nextPage() {
        
        event?.locations = locations
        
        let dateSelectorVC = (storyboard?.instantiateViewController(withIdentifier: DaySelectorViewController.storyboardID) as? DaySelectorViewController)!
        dateSelectorVC.event = event
        self.navigationController?.pushViewController(dateSelectorVC, animated: true)
    }
    
    @objc func deleteLocation(sender: UIButton) {
        locations.remove(at: sender.tag)
        selectedLocationsTableView.reloadData()
        updateNextButtonStatus()
    }
}

extension LocationsViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        locations.append(Location(title: place.name!, place: place))
        selectedLocationsTableView.reloadData()
        updateNextButtonStatus()
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
        
        let cell = selectedLocationsTableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier, for: indexPath) as! LocationCell
        
        cell.textField.text = locations[indexPath.section].title
        cell.addressLabel.text = locations[indexPath.section].place.formattedAddress
        cell.deleteButton.tag = indexPath.section
        cell.deleteButton.addTarget(nil, action: #selector(deleteLocation(sender:)), for: .touchUpInside)
        
        return cell
    }
}

extension LocationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
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

