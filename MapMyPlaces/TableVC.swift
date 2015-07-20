//
//  TableVC.swift
//  MapMyPlaces
//
//  Created by Ashley Soucar on 11/11/14.
//  Copyright (c) 2014 asoucar. All rights reserved.
//

import UIKit
import CoreData

var activePlace = -1

var places = [NSManagedObject]()

class TableVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Fetch stored Locations from Core Data
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"Location")
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        if let results = fetchedResults {
            places = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!)  {
        //Set activePlace to ensure that the map goes to the user's current location
        //instead of finding a previously used Location
        if segue.identifier == "addPlace" {
            activePlace = -1
        }
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        activePlace = indexPath.row
        self.performSegueWithIdentifier("findPlace", sender: indexPath)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        //Label table view cells with the name of the Location
        let place = places[indexPath.row]
        cell.textLabel!.text = place.valueForKey("name")as! String?
        
        return cell
    }
}



