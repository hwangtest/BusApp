//
//  BusSystem.swift
//  BusApp
//
//  Created by Hwang Lee on 11/29/16.
//  Copyright © 2016 Hwang Lee. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON
import PKHUD

class BusSystem: NSObject {
    static let sharedInstance = BusSystem()
    var routes = [Route]()
    var routesToDisplay = [Route]()
    var favorites = [Route]()
    
    func addRoute(json: JSON) {
        routes.append(Route(json: json))
    }
    
    func addRouteToFavorite(route: Route) {
        favorites.append(route)
    }
    
}

class Route: NSObject {
    var routeId: String?
    var routeTitle: String?
    var nearestStop: Stop?
    var stops = [Stop]()
    var times = [Int]()
    
    // Constructors
    init(json: JSON) {
        routeId = json["route_id"].stringValue
        routeTitle = json["title"].stringValue
    }

    // Add methods
    func addStop(json: JSON) {
        stops.append(Stop(json: json))
    }
    
    func addTimes(json: JSON) {
        times.append(json["minutes"].intValue)
    }
    
    func addNearestStop(stop: Stop) {
        nearestStop = stop
    }
    
}

class Stop: NSObject {
    var stopId: String?
    var stopTitle: String?
    var coordinates: CLLocation?
    
    init(json: JSON) {
        stopId = json["stop_id"].stringValue
        stopTitle = json["title"].stringValue
        coordinates = CLLocation(latitude: json["lat"].doubleValue, longitude: json["lon"].doubleValue)
    }

}
