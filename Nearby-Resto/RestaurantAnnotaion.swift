//
//  RestaurantAnnotaion.swift
//  Nearby-Resto
//
//  Created by John Bariquit on 12/04/2017.
//  Copyright © 2017 John Bariquit. All rights reserved.
//

import MapKit
import YelpAPI

class RestaurantAnnotaion: NSObject,  MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D
    public var restaurant: YLPBusiness
    
    init(restaurant: YLPBusiness) {
        self.restaurant = restaurant
        self.coordinate = CLLocationCoordinate2DMake((restaurant.location.coordinate?.latitude)!, (restaurant.location.coordinate?.longitude)!)
    }
    
}
