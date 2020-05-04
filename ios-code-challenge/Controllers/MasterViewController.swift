//
//  MasterViewControllerS.swift
//  ios-code-challenge
//
//  Created by Joe Rocca on 5/31/19.
//  Copyright © 2019 Dustin Lange. All rights reserved.
//

import UIKit
import CoreLocation


class MasterViewController: UITableViewController,
                            CLLocationManagerDelegate
{
    
    var detailViewController: DetailViewController?

    let locationManager = CLLocationManager()
    var lastReverseGeocodedAddress: String!
    var businesses: [YLPBusiness]!

    lazy private var dataSource: NXTDataSource? = {
        guard let dataSource = NXTDataSource(objects: nil) else { return nil }
        dataSource.tableViewDidReceiveData = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.tableView.reloadData()
        }
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLocationManager()
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController?.isCollapsed ?? false
        super.viewDidAppear(animated)
    }

    func updateBusinessList(userLocationAddress: String) {
        let query = YLPSearchQuery(location: userLocationAddress)
        AFYelpAPIClient.shared().search(with: query, completionHandler: { [weak self] (searchResult, error) in
            guard let strongSelf = self,
                let dataSource = strongSelf.dataSource,
                let businesses = searchResult?.businesses else {
                    print("MasterViewController::viewDidLoad() -- Failed search.")
                    print("Error: \(error.debugDescription)")
                    return
            }
            print("MasterViewController::viewDidLoad() -- Successful search.")
            dataSource.setObjects(businesses)
            strongSelf.tableView.reloadData()

            // Super-hacky attempt to load detail view
            strongSelf.businesses = businesses
            strongSelf.performSegue(withIdentifier: "showDetail", sender: "hack")
        })
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      print("Segue called")
      if segue.identifier == "showDetail" {
          if let indexPath = tableView.indexPathForSelectedRow {
              let business = businesses[indexPath.row]
              let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
              controller.detailItem = business
              controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
              controller.navigationItem.leftItemsSupplementBackButton = true
              detailViewController = controller
          } else {
            print("Hack path")
            let business = businesses[0]
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.detailItem = business
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            detailViewController = controller
          }
      }
    }

    // MARK: Geolocation methods

    func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        handleChangeInLocationAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleChangeInLocationAuthorization()
    }

    func handleChangeInLocationAuthorization() {
        print("Change in location authorization:")
        if CLLocationManager.authorizationStatus() == .notDetermined {
            print("Not determined")
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .denied {
            locationManager.stopUpdatingLocation()
            showDeniedLocationUseAlertAndExit()
        } else {
            locationManager.stopUpdatingLocation()
            showDeniedLocationUseAlertAndExit()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation

        print("latitude: \(userLocation.coordinate.latitude) / " +
              "longitude = \(userLocation.coordinate.longitude)")

        var address = ""
        lookUpCurrentLocation { placemark in
            if let currentPlacemark = placemark {
                if let number = currentPlacemark.subThoroughfare {
                    address.append("\(number) ")
                }
                if let street = currentPlacemark.thoroughfare {
                    address.append("\(street), ")
                }
                if let city = currentPlacemark.locality {
                    address.append("\(city) ")
                }
                if let state = currentPlacemark.administrativeArea {
                    address.append("\(state) ")
                }

                if address != self.lastReverseGeocodedAddress {
                    print("New address: \(address)")
                    self.lastReverseGeocodedAddress = address
                    self.updateBusinessList(userLocationAddress: address)
                }
            }
        }
    }

    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
                    -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()

            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                }
                else {
                 // An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }

    func showDeniedLocationUseAlertAndExit() {
        let message = """
        You denied permission for the app to use location services.

        If you want to use this app, please open “Settings” and give this app permission to use location services.
        """
        let alertController = UIAlertController(title: "Location services denied",
                                                message: message,
                                                preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default) { _ in
            exit(0)
        }
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func showRestrictedLocationUseAlertAndExit() {
        let message = """
        For some reason, this app is restricted from using location services.

        This is weird. Have a word with the developer about this one. Cite this error code:
        “RESTRICTED LOCATION USE”
        """
        let alertController = UIAlertController(title: "Please contact developer",
                                                message: message,
                                                preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default) { _ in
            exit(0)
        }
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
