//
//  DDNeighbourhoods.swift
//  policeapi
//
//  Created by Alex Fawcett on 02/04/2015.
//  Copyright (c) 2015 Dosiedo. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class DDNeighbourhoodsViewController: UITableViewController {
    var force: NSDictionary?
    var hoods: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = force?.objectForKey("name") as! NSString as String
        let forceID = force?.objectForKey("id") as! NSString
        self.navigationItem.leftBarButtonItem?.title = "Forces"
        let forceURI = "\(PoliceBaseURI)/\(forceID)/neighbourhoods"
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        Alamofire.request(.GET, forceURI)
            .responseJSON { response in
                if let JSON = response.result.value {
                    print(JSON)
                    let hoodsArray = JSON as! NSArray
                    for hood in hoodsArray{
                        self.hoods.append(hood as! NSDictionary)
                    }
                    self.tableView.reloadData()
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
        }
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cvc = segue.destinationViewController as! DDCrimeViewController
        cvc.force = force
        cvc.hood = hoods[self.tableView.indexPathForSelectedRow!.row] as! NSDictionary
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hoods.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HoodCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = hoods[indexPath.row].objectForKey("name") as! NSString as String
        return cell
    }

}
