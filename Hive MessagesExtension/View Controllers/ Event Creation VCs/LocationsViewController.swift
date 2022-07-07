//
//  LocationsViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/6/22.
//

import Foundation
import UIKit
import GooglePlaces
//import SwiftUI

class LocationsViewController: UIViewController {
    
    static let storyboardID = String(describing: LocationsViewController.self)
    
    var event: Event! = nil
    lazy var locations = event.locations
    
    var anyLocationSelected: Bool = false
    
    @IBOutlet weak var selectedLocationsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedLocationsTableView.dataSource = self
        selectedLocationsTableView.delegate = self
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
            //TODO: Color Next button
        } else {
            anyLocationSelected = true
            //TODO: Gray out Next button
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if anyLocationSelected {
            nextPage()
        } else {
            // TODO: Error message
        }
    }
    
    func nextPage() {
        
        event?.locations = locations
        
        let dateSelectorVC = (storyboard?.instantiateViewController(withIdentifier: DaySelectorViewController.storyboardID) as? DaySelectorViewController)!
        dateSelectorVC.event = event
        self.navigationController?.pushViewController(dateSelectorVC, animated: true)
    }
}

extension LocationsViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        locations.append(Location(title: place.name!, place: place))
        for location in locations {
            print(location.title)
        }
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
        locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = selectedLocationsTableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier, for: indexPath) as! LocationCell
        
        cell.textLabel?.text = locations[indexPath.row].title
        
        return cell
    }
}

extension LocationsViewController: UITableViewDelegate {
    
}

