//
//  NearbyViewController.swift
//  Nearby-Resto
//
//  Created by John Bariquit on 11/04/2017.
//  Copyright © 2017 John Bariquit. All rights reserved.
//

import UIKit
import YelpAPI
import MapKit

class NearbyViewController: UIViewController, LocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchButton: UIButton!
    
    var client: YLPClient? = nil;
    var locationManager = LocationManager.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.autoUpdate      = true
        searchButton.isEnabled          = false
        
        locationManager.delegate        = self
        locationManager.startUpdatingLocation()
        
        self.checkClient()
    }
    
    func checkClient() {
        
        if client == nil {
            
            self.authorizeClient(callback: { (client) in
                
                self.client                 = client
                self.searchButton.isEnabled = true
                print(client)
                
            })
            
        }
    }

    
    @IBAction func didTapSearchButton(_ sender: UIButton) {
        
        locationManager.delegate        = self
        locationManager.startUpdatingLocation()
        
//        if client == nil {
//    
//            self.authorizeClient(callback: { (client) in
//    
//                self.client                 = client
//                self.searchButton.isEnabled = true
//                print(client)
//                
//            })
//            
//        }


    }
    
    
    func removeAllPlacemarkFromMap(_ shouldRemoveUserLocation:Bool) {
        
        if let mapView = self.mapView {
            
            for annotation in mapView.annotations{
                
                if shouldRemoveUserLocation {
                    
                    if annotation as? MKUserLocation !=  mapView.userLocation {
                        mapView.removeAnnotation(annotation )
                    }
                    
                }
                
            }
            
        }
    }
    
    func plotAllRestaurants(_ restaurants:[YLPBusiness]) {
       
        self.removeAllPlacemarkFromMap(true)
        
        if self.locationManager.isRunning {
            self.locationManager.stopUpdatingLocation()
        }
        
        
        
        for object in restaurants {
            self.plotAnnotationCoordinate(coordinate: object.location.coordinate!, restaurant: object)
        }
        
    }
    
    func plotAnnotationCoordinate(coordinate: YLPCoordinate, restaurant: YLPBusiness) {

        (DispatchQueue.main).async(execute: { () -> Void in
            
            let annotation                  = MKPointAnnotation()
            annotation.coordinate           = CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                                     longitude: coordinate.longitude)
            annotation.title                = restaurant.name
            annotation.subtitle             = restaurant.phone
            self.mapView.addAnnotation(annotation)
            
        })
        
    }
    

    internal func locationFound(_ latitude: Double, longitude: Double) {
        print("curren location: \(latitude) \(longitude)")
        
        if self.locationManager.isRunning {
            self.locationManager.stopUpdatingLocation()
            
            let latitudinalMeters           = 500.0
            let longitudinalMeters          = 500.0
            
            
            let region: MKCoordinateRegion  = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(latitude, longitude),
                                                                                 latitudinalMeters,
                                                                                 longitudinalMeters)
            
            self.mapView.showsUserLocation       = true
            self.mapView?.setRegion(region, animated: true)

        
        }
        
        if client != nil {
            
            let coordinate      = YLPCoordinate.init(latitude: latitude, longitude: longitude)
            let query           = YLPQuery.init(coordinate: coordinate)
            query.term          = "restaurant"
            query.radiusFilter  = 500.0
            
            client?.search(with: query, completionHandler: { (search, error) in
                
                if error != nil {
                    
                    print("error \(error)")
                    
                } else {
                    
                    print("count: \(search?.businesses.count)")
                    self.plotAllRestaurants((search?.businesses)!)
                }
            })
        }

    }

    func locationManagerStatus(_ status:NSString) {
        print(status)
    }
    
    func locationManagerReceivedError(_ error:NSString) {
        print(error)
    }

    func authorizeClient(callback:@escaping (YLPClient) -> ()) {

        YLPClient.authorize(withAppId   : "r9i6zTQNhyC2AWaDv7ANxQ",
                            secret      : "AL7Ez0812kaDt6QSzSGbhwbC9LsZTG6vzDEYn1t8doU62IUD3GvQtFnPbGxKFiuN")
        { (client, error) in
            
            if error != nil {
                print("error \(error?.localizedDescription)")
            } else {
                callback(client!)
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
