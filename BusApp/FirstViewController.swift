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
        
        DataParser.sharedInstance.addRoutes()
        
        let deadlineTime = DispatchTime.now() + .milliseconds(500)
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
        DataParser.sharedInstance.updateNearestStopsToDisplay(currentLocation: userLocation)
        
        
        let time = DispatchTime.now() + .milliseconds(1500)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            
            for route in BusSystem.sharedInstance.routesToDisplay {
                print(route.nearestStop!.stopTitle!)
            }
            
            if BusSystem.sharedInstance.routesToDisplay.count > 0 {
                self.tableView.reloadData()
            }
        })
        
    }
    
    
    
    
    // MARK: TableView stuff ==========================================================================================================
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(BusSystem.sharedInstance.routesToDisplay.count)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        let route = BusSystem.sharedInstance.routesToDisplay[indexPath.row]
        
        
        cell.routeName.text = route.routeTitle!
        cell.nearestStopName.text = route.nearestStop!.stopTitle!
        
        if route.times.count > 2 {
            cell.times.text = "\(route.times[0]), \(route.times[1])"
        }
            
        else {
            cell.times.text = "\(route.times[0])"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BusSystem.sharedInstance.routesToDisplay.count
    }
    
    
    // Swipe action for cells
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let addFavorite = UITableViewRowAction(style: .normal, title: "Add Favorite") { action, index in
            print("Added")
            tableView.setEditing(false, animated: true)
            
        }
        
        addFavorite.backgroundColor = UIColor.orange
        
        return[addFavorite]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
}

