//
//  Location.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/20/22.
//

import Foundation
import GooglePlaces

struct Location {
    var title: String
    var place: GMSPlace?
    var address: String?
    
    func makeURLQueryItem() -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "locationTitle", value: title))
        if address != nil {
            queryItems.append(URLQueryItem(name: "locationAddress", value: address))
        }
        return queryItems
    }
    
    init(title: String, place: GMSPlace?, address: String?) {
        self.title = title
        self.place = place
        self.address = address
    }
    
    // TODO: This does NOT work - WHYYYYYY??
    static func getPlaceFromID (id: String) -> GMSPlace {
        
        let fields = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.addressComponents.rawValue) | UInt(GMSPlaceField.placeID.rawValue))
        let placesClient = GMSPlacesClient.shared()
        var placeFromId: GMSPlace?
        
        print("Trying")
        /*
        placesClient.fetchPlace(fromPlaceID: id, placeFields: fields, sessionToken: nil, callback: {
            (place: GMSPlace?, error: Error?) in
            print("======================")
            if let error = error {
                
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            print(place)
            if let place = place {
                print(place.name)
                placeFromId = place
            } else {
                fatalError("Place couldn't be loaded")
            }
        })
        */
        
        placesClient.lookUpPlaceID(id, callback: { (place, error) -> Void in
            print("=================")
            if let error = error {
                    print("lookup place id query error: \(error.localizedDescription)")
                    return
            }

            if let place = place {
                print("Place name \(place.name)")
                print("Place address \(place.formattedAddress)")
                print("Place placeID \(place.placeID)")
                print("Place attributions \(place.attributions)")
                placeFromId = place
            } else {
                print("No place details for \(id)")
            }
        })
        return placeFromId!
    }
}
