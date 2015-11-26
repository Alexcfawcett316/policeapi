//
//  DetailViewController.swift
//  policeapi
//
//  Created by Alex Fawcett on 02/04/2015.
//  Copyright (c) 2015 Dosiedo. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD
import Alamofire    

class DDCrimeViewController: UIViewController, MKMapViewDelegate  {
    
    @IBOutlet weak var map: MKMapView!
    var force: NSDictionary?
    var hood: NSDictionary?
    var area: MKPolyline?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let base = PoliceBaseURI
        let forceId = force?.objectForKey("id") as! NSString
        let hoodId = hood?.objectForKey("id") as! NSString
        let forceURI = "\(PoliceBaseURI)\(forceId)/\(hoodId)/boundary"
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        Alamofire.request(.GET, forceURI)
            .responseJSON { response in
                if let JSON = response.result.value {
                    let coords = JSON as! Array<NSDictionary>
                    self.buildArea(coords)
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
        }
    }
    
    func buildArea(coords: Array<NSDictionary>){
        
        var coordsArry = [CLLocationCoordinate2D]()
        
        var polyString = ""
        for coord in coords{
            let latString = coord.objectForKey("latitude") as! NSString
            let longString = coord.objectForKey("longitude") as! NSString
            polyString += "\(latString),\(longString):"
            coordsArry.append(CLLocationCoordinate2DMake(latString.doubleValue as CLLocationDegrees, longString.doubleValue as CLLocationDegrees))
        }
        area = MKPolyline(coordinates: &coordsArry, count: coordsArry.count)
        self.map.addOverlay(area!)
        let areaRect = area?.boundingMapRect
        map.setVisibleMapRect(areaRect!, animated: false)
        requestCrimes(polyString)
    }
    
    func requestCrimes(polyString: String){
        
        let crimesURI = "\(PoliceBaseURI)crimes-street/all-crime"
        var params = ["poly" : polyString]
        
        Alamofire.request(.GET, crimesURI)
            .responseJSON { response in
                if let JSON = response.result.value {
                    self.addCrimesToMap(JSON as! Array<NSDictionary>)
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
        }

    }
    
    func addCrimesToMap(crimes: Array<NSDictionary>){
        for crime in crimes{
            let location = crime.objectForKey("location") as! NSDictionary
            let latString = location.objectForKey("latitude")as! NSString
            let longString = location.objectForKey("longitude")as! NSString
            var annot = MKPointAnnotation()
            annot.coordinate = CLLocationCoordinate2DMake(latString.doubleValue as CLLocationDegrees, longString.doubleValue as CLLocationDegrees)
            map.addAnnotation(annot)
            
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer!{
        var renderer = MKPolylineRenderer(polyline: area!)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3.0;
        return renderer
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinColor = .Red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}

