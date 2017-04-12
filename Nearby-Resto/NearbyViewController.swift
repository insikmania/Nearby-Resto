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

        let annotation                  = MKPointAnnotation()
        annotation.coordinate           = CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                                 longitude: coordinate.longitude)
        annotation.title                = restaurant.name
        annotation.subtitle             = restaurant.phone
        mapView.addAnnotation(annotation)
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
            query.radiusFilter  = 2000.0
            
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
    
    
////    let locationManager = CLLocationManager();
////    var client: YLPClient? = nil;
////    let query = YLPQuery.init(coordinate: YLPCoordinate.init(latitude: 37.33020389, longitude: -122.02635116));
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Do any additional setup after loading the view, typically from a nib.
//        YLPClient.authorize(withAppId: "r9i6zTQNhyC2AWaDv7ANxQ", secret: "AL7Ez0812kaDt6QSzSGbhwbC9LsZTG6vzDEYn1t8doU62IUD3GvQtFnPbGxKFiuN") { (client, error) in
//            
//            print("error: \(error)");
//            self.client = client;
//            print("client: \(self.client)");
//            
//            //            self.initializeLocationManager();
//            
//            self.query.term = "restaurant";
//            self.client?.search(with: self.query, completionHandler: { (search, error) in
//                print("search \(search)");
//                
//                for object in (search?.businesses)! as [YLPBusiness] {
//                    print("object \(object.name)");
//                }
//            });
//        }
//        
//    }
//
//   
//    
////    func initializeLocationManager() {
////        
////        
////        self.locationManager.requestWhenInUseAuthorization()
////        
////        if (CLLocationManager.locationServicesEnabled()) {
////            self.locationManager.delegate = self;
////            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
////            self.locationManager.startUpdatingLocation();
////        }
////    }
////    
////    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
////        manager.stopUpdatingHeading();
////        print("locations = \(manager.location?.coordinate.latitude) \(manager.location?.coordinate.longitude)")
////        
////    }
    
}
