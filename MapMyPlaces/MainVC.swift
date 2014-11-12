//
//  ViewController.swift
//  MapMyPlaces
//
//  Created by Ashley Soucar on 11/11/14.
//  Copyright (c) 2014 asoucar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MainVC: UIViewController, CLLocationManagerDelegate {
    
    //The map used to display and create places
    @IBOutlet var myMap: MKMapView!
    
    //Find current location
    @IBAction func findMe(sender: AnyObject) {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    var manager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup location manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        /*
        If activePlace num is -1, we are adding a new place
        and should set map view to current location.
        Else we should go to the pin (lat and long position)
        of the place in that row of the table
        */
        if activePlace == -1 {
            
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            
        } else {

            //Get the position of the place from Core Data storage
            let lat = places[activePlace].valueForKey("lat") as Double
            let lon = places[activePlace].valueForKey("lon") as Double
            var latitude:CLLocationDegrees = lat
            var longitude:CLLocationDegrees = lon
            var latDelta:CLLocationDegrees = 0.01
            var lonDelta:CLLocationDegrees = 0.01
            var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            
            //Set the map region to view plact
            myMap.setRegion(region, animated: true)
            
            //Create pin annotation with the location as the title
            //and with the formatted date added as the subtitle
            var annotation = MKPointAnnotation()
            let dateAdded = places[activePlace].valueForKey("dateAdded") as NSDate
            var formatter: NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd 'at' h:mm a"
            var formattedDate = formatter.stringFromDate(dateAdded)
            annotation.coordinate = location
            annotation.title = places[activePlace].valueForKey("name") as String?
            annotation.subtitle = "Added \(formattedDate)"
            myMap.addAnnotation(annotation)
    
        }
        
        //Add a gesture recognizer for a long press to add a pin at a location
        var uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
        uilpgr.minimumPressDuration = 1.0
        myMap.addGestureRecognizer(uilpgr)
 
    }
    
    func action(gestureRecognizer:UIGestureRecognizer) {
    
        //Only add the pin if the gesture is just beginning (prevent dupliates)
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
 
            //Get location of gesture on map (first x, y then convert to latitude and longitude)
            var touchPoint = gestureRecognizer.locationInView(self.myMap)
            var newCoordinate = myMap.convertPoint(touchPoint, toCoordinateFromView: self.myMap)
            var loc = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)

            //Find the address of the location
            //Use address if available
            CLGeocoder().reverseGeocodeLocation(loc, completionHandler:{(placemarks, error) in
                if ((error) != nil)  {
                    println("Error: \(error)")
                }
                else {
                    let p = CLPlacemark(placemark: placemarks?[0] as CLPlacemark)
                    var subThoroughfare:String
                    var thoroughfare:String
                    
                    //Parse the location address if not nil
                    if ((p.subThoroughfare) != nil) {
                        subThoroughfare = p.subThoroughfare
                    } else {
                        subThoroughfare = ""
                    }

                    if ((p.thoroughfare) != nil) {
                        thoroughfare = p.thoroughfare
                    } else {
                        thoroughfare = ""
                    }
                    
                    //Create pin annotation with the location as the title
                    //and with the formatted date added as the subtitle
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = newCoordinate
                    
                    var title = "\(subThoroughfare) \(thoroughfare)"
                    var date = NSDate()
                    var formatter: NSDateFormatter = NSDateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd 'at' h:mm a"
                    var formattedDate = formatter.stringFromDate(date)
                    
                    if title == " " { title = "New Place \(date)" }
                    
                    annotation.title = title
                    annotation.subtitle = "Added \(formattedDate)"
                    println(annotation.title)
                    println(annotation.subtitle)
                    self.myMap.addAnnotation(annotation)
                    
                    
                    //Store new Location to Core Data
                    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                    let managedContext = appDelegate.managedObjectContext!
                    let entity =  NSEntityDescription.entityForName("Location", inManagedObjectContext: managedContext)
                    let newPlace = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)

                    newPlace.setValue(title, forKey: "name")
                    newPlace.setValue(loc.coordinate.latitude, forKey: "lat")
                    newPlace.setValue(loc.coordinate.longitude, forKey: "lon")
                    newPlace.setValue(date, forKey: "dateAdded")
                    
                    //Handle error in saving to Core Data
                    var error: NSError?
                    if !managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                    
                    //Add new Location to array of Locations
                    places.append(newPlace)
                   }
            })
        }
    }
    
    //Managing navigation bars
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        
        //Find current user location
        var userLocation:CLLocation = locations[0] as CLLocation
        var latitude:CLLocationDegrees = userLocation.coordinate.latitude
        var longitude:CLLocationDegrees = userLocation.coordinate.longitude
        var latDelta:CLLocationDegrees = 0.01
        var lonDelta:CLLocationDegrees = 0.01
        var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        //Set view in map to user location then stop updating
        myMap.setRegion(region, animated: true)
        manager.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
