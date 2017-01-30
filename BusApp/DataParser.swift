//
//  DataParsing.swift
//  BusApp
//
//  Created by Hwang Lee on 1/19/17.
//  Copyright © 2017 Hwang Lee. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON
import Alamofire

class DataParser: NSObject {
    static let sharedInstance = DataParser()
    let firstVC = FirstViewController()
    
    func addRoutes() {
        print("Getting routes...")
        Alamofire.request("http://api.umd.io/v0/bus/routes").responseJSON { (response) in
            if let results = JSON(response.result.value!).array {
                for result in results {
                    BusSystem.sharedInstance.addRoute(json: result)
                }
            }
            
            print("Getting stops...")
            for route in BusSystem.sharedInstance.routes {
                Alamofire.request("http://api.umd.io/v0/bus/routes/\(route.routeId!)").responseJSON { (response) in
                    if let results = JSON(response.result.value!)["stops"].array {
                        for result in results {
                            route.addStop(json: result)
                        }
                    }
                }
            }
        }
    }
    

    
    func updateTimes(route: Route) {
        
        Alamofire.request("http://api.umd.io/v0/bus/routes/\(route.routeId!)/arrivals/\(route.nearestStop!.stopId!)").responseJSON { (response) in
            if response.result.value != nil {
                if let results = JSON(response.result.value!)["predictions"]["direction"]["prediction"].array {
                    route.times.removeAll()
                    
                    for result in results {
                        print("Getting time for \(route.routeTitle!)")
                        route.times.append(result["minutes"].intValue)
                    }
                    
                    BusSystem.sharedInstance.routesToDisplay.append(route)
                    print("Added route with time to display")
                }
            }
            
        }
        
        
    }
    
}
