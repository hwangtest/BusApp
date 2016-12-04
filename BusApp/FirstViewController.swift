//
//  FirstViewController.swift
//  BusApp
//
//  Created by Hwang Lee on 11/29/16.
//  Copyright © 2016 Hwang Lee. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import CoreLocation

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "Hello"
        
        // Set up TableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set up Location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        
        addRoutes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        manager.stopUpdatingLocation()
        
        self.navigationItem.title = "\(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)"
        updateInfoToDisplay(currentLocation: userLocation)
    }
    
    func addRoutes() {
        
        Alamofire.request("http://api.umd.io/v0/bus/routes").responseJSON { (response) in
            if let results = JSON(response.result.value!).array {
                for result in results {
                    BusSystem.sharedInstance.addRoute(json: result)
                }
            }
            
            self.addStops()
        }
    }
    
    func addStops() {
        
        for route in BusSystem.sharedInstance.routes {
            Alamofire.request("http://api.umd.io/v0/bus/routes/\(route.routeId!)").responseJSON(completionHandler: { (response) in
                if let results = JSON(response.result.value!)["stops"].array {
                    for result in results {
                        route.addStop(json: result)
                    }
                }
                
                self.locationManager.startUpdatingLocation()
            })
        }
        
    }
    
    func updateInfoToDisplay(currentLocation: CLLocation) {
        var smallestDistance: CLLocationDistance?
        var closestStop: Stop?
        
        for route in BusSystem.sharedInstance.routes {
            
            smallestDistance = nil
            
            for stop in route.stops {
                let distance = currentLocation.distance(from: stop.coordinates!)
                
                if smallestDistance == nil || distance < smallestDistance! {
                    smallestDistance = distance
                    closestStop = stop
                }
            }
            
            BusSystem.sharedInstance.addRouteToDisplay(route: route, stop: closestStop!)
            updateTimes(route: route, stop: closestStop!)
        }
        
    }
    
    func updateTimes(route: Route, stop: Stop) {
        var i = 0;
        
        for route in BusSystem.sharedInstance.routesToDisplay {
            Alamofire.request("http://api.umd.io/v0/bus/routes/\(route.route.routeId!)/arrivals/\(route.nearestStop.stopId!)").responseJSON { (response) in
                print("http://api.umd.io/v0/bus/routes/\(route.route.routeId!)/arrivals/\(route.nearestStop.stopId!)")
                if let results = JSON(response.result.value!)["predictions"].array {
                    for result in results {
                        BusSystem.sharedInstance.addTimesToDisplay(pos: i, json: result)
                    }
                }
                
            }
            i += 1
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        let route = BusSystem.sharedInstance.routesToDisplay[indexPath.row]
        
        cell.routeName.text = route.route.routeTitle
        
        cell.nearestStopName.text = route.nearestStop.stopTitle
        
        if route.times.count > 0 {
            cell.times.text = String(route.times[0]!)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BusSystem.sharedInstance.routes.count
    }
    
}

