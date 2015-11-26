//
//  MasterViewController.swift
//  policeapi
//
//  Created by Alex Fawcett on 02/04/2015.
//  Copyright (c) 2015 Dosiedo. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class DDForcesViewController: UITableViewController {
    
    var forces: [NSDictionary] = []

   override func viewDidLoad() {
        super.viewDidLoad()
        let asd = PoliceBaseURI
        let forceURI = "\(PoliceBaseURI)forces"
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    
        Alamofire.request(.GET, forceURI)
        .responseJSON { response in
            if let JSON = response.result.value {
                let forcesArray = JSON as! NSArray
                for force in forcesArray{
                    self.forces.append(force as! NSDictionary)
                }
                self.tableView.reloadData()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            }
        }
    
    }

    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nvc = segue.destinationViewController as! DDNeighbourhoodsViewController
        nvc.force = forces[self.tableView.indexPathForSelectedRow!.row] as NSDictionary
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forces.count;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = forces[indexPath.row].objectForKey("name") as! NSString as String
        return cell
    }

}

