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

class BusSystem {
    static let sharedInstance = BusSystem()
    var routes = [Route]()
    var routesToDisplay = [RouteToDisplay]()
    
    func addRoute(json: JSON) {
        routes.append(Route(json: json))
    }
    
    func addRouteToDisplay(route: Route, stop: Stop) {
        routesToDisplay.append(RouteToDisplay(route: route, nearestStop: stop, times: []))
    }
    
    func addTimesToDisplay(pos: Int, json: JSON) {
        routesToDisplay[pos].times.append(json["minutes"].intValue)
    }
}

class Route {
    var routeId: String?
    var routeTitle: String?
    var stops = [Stop]()
    
    init(json: JSON) {
        routeId = json["route_id"].stringValue
        routeTitle = json["title"].stringValue
    }
    
    init() {
        
    }
    
    func addStop(json: JSON) {
        stops.append(Stop(json: json))
    }
    
}

class Stop {
    var stopId: String?
    var stopTitle: String?
    var coordinates: CLLocation?
    
    init(json: JSON) {
        stopId = json["stop_id"].stringValue
        stopTitle = json["title"].stringValue
        coordinates = CLLocation(latitude: json["lat"].doubleValue, longitude: json["lon"].doubleValue)
    }
    
    init() {
        
    }
    
}

struct RouteToDisplay {
    var route = Route()
    var nearestStop = Stop()
    var times = [Int?]()
}
