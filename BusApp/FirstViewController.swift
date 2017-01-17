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
    var refreshManager: UIRefreshControl!
    var dispatch = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set up TableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set up pull to refresh
        refreshManager = UIRefreshControl()
        refreshManager.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshManager)
        
        // Set up Location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        
        addRoutes()
        
        let deadlineTime = DispatchTime.now() + .milliseconds(610)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.locationManager.startUpdatingLocation()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender: AnyObject) {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        refreshManager.endRefreshing()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        print("Updating location...")
        manager.stopUpdatingLocation()
        
        locationManager.delegate = nil
        self.navigationItem.title = "\(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)"
        updateNearestStopsToDisplay(currentLocation: userLocation)
    }
    
    func addRoutes() {
        Alamofire.request("http://api.umd.io/v0/bus/routes").responseJSON { (response) in
            if let results = JSON(response.result.value!).array {
                for result in results {
                    BusSystem.sharedInstance.addRoute(json: result)
                    print("Getting route...")
                }
            }
            
            for route in BusSystem.sharedInstance.routes {
                Alamofire.request("http://api.umd.io/v0/bus/routes/\(route.routeId!)").responseJSON { (response) in
                    if let results = JSON(response.result.value!)["stops"].array {
                        print("Getting routes for \(route.routeId!):")
                        for result in results {
                            route.addStop(json: result)
                        }
                    }
                }
            }
        }
    }
    
    func updateNearestStopsToDisplay(currentLocation: CLLocation) {
        var smallestDistance: CLLocationDistance?
        var closestStop: Stop?
        BusSystem.sharedInstance.routesToDisplay = []
        
        for route in BusSystem.sharedInstance.routes {
            print("Updating nearest stop: \(route.routeTitle!)")
            smallestDistance = nil
            
            for stop in route.stops {
                let distance = currentLocation.distance(from: stop.coordinates!)
                
                if smallestDistance == nil || distance < smallestDistance! {
                    smallestDistance = distance
                    closestStop = stop
                }
            }
            
            if closestStop != nil {
                BusSystem.sharedInstance.addRouteToDisplay(route: Route(route: route, stop: closestStop!, times: []))
            }
        }
        
        updateTimes()
    }
    
    func updateTimes() {
        for route in BusSystem.sharedInstance.routesToDisplay {
            Alamofire.request("http://api.umd.io/v0/bus/routes/\(route.routeId!)/arrivals/\(route.stops[0].stopId!)").responseJSON { (response) in
                if response.result.value != nil {
                    if let results = JSON(response.result.value!)["predictions"]["direction"]["prediction"].array {
                        for result in results {
                            print(result)
                            route.times.append(result["minutes"].intValue)
                        }
                    }
                }
            }
            
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        let route = BusSystem.sharedInstance.routesToDisplay[indexPath.row]
        
        
        cell.routeName.text = route.routeTitle!
        cell.nearestStopName.text = route.stops[0].stopTitle!
        
        if route.times.count > 0 {
            cell.times.text = String(route.times[0])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BusSystem.sharedInstance.routesToDisplay.count
    }
    
}

