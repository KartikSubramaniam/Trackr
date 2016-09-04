//
//  ViewController.swift
//  location
//
//  Created by Kartik Subramaniam on 28/08/16.
//  Copyright © 2016 Kartik Subramaniam. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapController: UIViewController,CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var totalDistanceTravelled: UILabel!
    
    var selectedPin:MKPlacemark? = nil
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var lastLocation:CLLocation? = nil
    var searchLocation : MKPlacemark?
    var travelledDistance = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //adding location
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.distanceFilter = 100
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
        //Search Table
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("SearchController") as! SearchController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        //Search Bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK location - delegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locations = locations.last
        if (lastLocation != nil && searchLocation != nil) {
            let last = CLLocation(latitude: lastLocation!.coordinate.latitude, longitude: lastLocation!.coordinate.longitude)
            let current = CLLocation(latitude: locations!.coordinate.latitude, longitude: locations!.coordinate.longitude)
             travelledDistance += current.distanceFromLocation(last)
            let x = (travelledDistance)/1000
            let showDestination : Double = Double(round(1000*x)/1000)
            
            totalDistanceTravelled.text = String(showDestination) + " KM "
           
        }
        
        
        lastLocation = locations
        
        let first = CLLocation(latitude: locations!.coordinate.latitude, longitude: locations!.coordinate.longitude)
    
        let center = CLLocationCoordinate2D(latitude: (locations?.coordinate.latitude)!, longitude:(locations?.coordinate.longitude)!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05 ))
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        self.mapView.setRegion(region, animated: true)
        
        if searchLocation != nil {
        
            let search  = CLLocation(latitude: searchLocation!.coordinate.latitude, longitude:searchLocation!.coordinate.longitude)
            let destinationDistance :Double = search.distanceFromLocation(first)
            if(destinationDistance <= 500){
                let alert = UIAlertController(title: "Location", message: "You are 100 m near your location ", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.locationManager.stopUpdatingLocation()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }
    }
}

extension MapController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        travelledDistance = 0.0
        searchLocation = placemark
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = city + " " + state
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        self.locationManager.startUpdatingLocation()
    }
}

extension MapController : MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orangeColor()
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), forState: .Normal)
        button.addTarget(self, action: "getDirections", forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}

extension CLLocationCoordinate2D {
    func distanceTo(coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let thisLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let otherLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        return thisLocation.distanceFromLocation(otherLocation)
    }
}

