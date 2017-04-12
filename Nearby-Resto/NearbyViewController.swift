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
import AFNetworking

class NearbyViewController: UIViewController, LocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchButton: UIButton!
    
    var client: YLPClient? = nil;
    var locationManager = LocationManager.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.autoUpdate      = true
        searchButton.isEnabled          = false
        
        mapView.delegate                = self
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
            
            let annotation = RestaurantAnnotaion(restaurant: restaurant)
//            annotation.coordinate           = CLLocationCoordinate2D(latitude: coordinate.latitude,
//                                                                     longitude: coordinate.longitude)
//            annotation.title                = restaurant.name
//            annotation.subtitle             = restaurant.phone
            self.mapView.addAnnotation(annotation)
            
        })
        
    }
    
    
    
    //........................Annotation
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation
        {
            return nil
        }
        
        
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil {
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin") as AnnotationView
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "icon")
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    
        if view.annotation is MKUserLocation {
            return
        }
        
        let restaurantAnnotation = view.annotation as! RestaurantAnnotaion
        let categories = restaurantAnnotation.restaurant.categories as Array
        let option = categories[0] as YLPCategory
        
        let views = Bundle.main.loadNibNamed("CalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! CalloutView
        calloutView.restaurantNameLabel.text = restaurantAnnotation.restaurant.name
        calloutView.categoryLabel.text = option.alias
        calloutView.phoneLabel.text = restaurantAnnotation.restaurant.phone
        calloutView.ratingLabel.text = "ratings: \(restaurantAnnotation.restaurant.rating)"
        calloutView.reviewLabel.text = "reviews: \(restaurantAnnotation.restaurant.reviewCount)"
        calloutView.imageView.setImageWith(restaurantAnnotation.restaurant.imageURL!)
    
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        if view.isKind(of: AnnotationView.self) {
            for subview in view.subviews {
                subview.removeFromSuperview()
            }
        }
    }


    
    //........................Location Manager
    
    
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
//            query.radiusFilter  = 500.0
            
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

class AnnotationView: MKAnnotationView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if (hitView != nil)
        {
            self.superview?.bringSubview(toFront: self)
        }
        return hitView
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds;
        var isInside: Bool = rect.contains(point);
        if(!isInside)
        {
            for view in self.subviews
            {
                isInside = view.frame.contains(point);
                if isInside
                {
                    break;
                }
            }
        }
        return isInside;
    }
}

