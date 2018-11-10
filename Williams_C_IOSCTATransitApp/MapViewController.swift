//
//  MapViewController.swift
//  Williams_C_IOSCTATransitApp
//
//  Created by CWILL on 5/29/18.
//  Copyright © 2018 DePaul. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
 
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var notice: UILabel!
    
    @IBOutlet weak var theTrainComing: UILabel!
    var _currentStop = ""
    var regions = [CLCircularRegion]()
    let locationManager = CLLocationManager()
    let points = [
        (lat: 41.9655, lon: -87.6579, name: "Wilson/Red Line Stop"),
        (lat: 41.9539, lon: -87.6550, name: "Sheridan/Red Line Stop"),
        (lat: 41.9475, lon: -87.6537, name: "Addison/Red Line Stop"),
        (lat: 41.9398, lon: -87.6533, name: "Belmont/Red Line Stop"),
        (lat: 41.9252, lon: -87.6528, name: "Fullerton/Red Line Stop"),
    ]
   
    
    var trainTimes2 = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.theTrainComing.text = "Please Wait.\n Gathering Train information!"
        // Do any additional setup after loading the view, typically from a nib.
        let status = CLLocationManager.authorizationStatus()
        if status == .denied || status == .restricted {
            message.text = "Location service not authorized"
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 1 // meter
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            
            mapView.mapType = .standard
            mapView.mapType = .satellite
            mapView.mapType = .hybrid
            mapView.mapType = .satelliteFlyover
            mapView.mapType = .hybridFlyover
            mapView.showsUserLocation = true
            mapView.showsBuildings = true
            
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                for p in points {
                    let center = CLLocationCoordinate2D(latitude: p.lat, longitude: p.lon)
                    let region = CLCircularRegion(center: center, radius: 10, identifier: p.name)
                    region.notifyOnEntry = true
                    region.notifyOnExit = true
                    regions.append(region)
                }
            } else {
                showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            }
        }
    }
    func getTrainsAndTimes(_ currentStop:String){
     
      var stpidHoward = ""
      var stpid95th = ""
        _currentStop = currentStop
        switch(currentStop){
            case "Wilson/Red Line Stop": stpidHoward = "30105"; stpid95th = "30106";
            case "Sheridan/Red Line Stop": stpidHoward = "30016"; stpid95th = "30017";
            case "Addison/Red Line Stop": stpidHoward = "30273"; stpid95th = "30274";
            case "Belmont/Red Line Stop": stpidHoward = "30255"; stpid95th = "30256";
            case "Fullerton/Red Line Stop": stpidHoward = "30233"; stpid95th = "30234" ;
            
        default:
            stpidHoward = "30105"; stpid95th = "30106";
        }
        feed = "http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx?key=bd5b626c2e554a78adeffc17b722fd5e&stpid=" + stpid95th + "&outputType=JSON"
        JSONProcessing()
    }
    override func viewWillAppear(_ animated: Bool) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) &&
            !regions.isEmpty {
            for region in regions {
                locationManager.startMonitoring(for: region)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
        for region in regions {
            locationManager.stopMonitoring(for: region)
        }
    }
    
    // delegate methods
    
    var annotation: MKAnnotation?
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        NSLog("(\(location.coordinate.latitude), \(location.coordinate.longitude))")
        //print(manager.monitoredRegions) //.count)
        
        message.text =
            "Latitude: " + String(format: "%.4f", location.coordinate.latitude) +
            ", Longitude: " +  String(format: "%.4f", location.coordinate.longitude)
        
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        
        
        if mapView.isPitchEnabled {
            mapView.setCamera(MKMapCamera(lookingAtCenter: location.coordinate, fromDistance: 1000, pitch: 60, heading: 0), animated: true)
        }
        
        if annotation != nil {
            mapView.removeAnnotation(annotation!)
        }
        let place = Place(location.coordinate, "You are here!")
        mapView.addAnnotation(place)
        annotation = place
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        NSLog("Enter region \(region)")
        notice.text = "Enter \(region.identifier)"
        
        //run in background
        self.getTrainsAndTimes(String(region.identifier))
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        NSLog("Exit region \(region)")
        notice.text = "Exit \(region.identifier)"
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        NSLog("Error \(error)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    func JSONProcessing(){
        trainTimes.removeAll()
        guard let feedURL = URL(string: feed) else {
            return
        }
        
        let request = URLRequest(url: feedURL)
        let session = URLSession.shared
        session.dataTask(with: request){ data, response, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let data = data else { return }
            
           
            do {
                if let json =
                    try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                {
                    
                    guard let feed = json["ctatt"] as? [String:Any] else {
                        throw SerializationError.missing("ctatt")
                    }
                    guard let entry = feed["eta"] as? [Any] else {
                        throw SerializationError.missing("eta")
                    }
                    
                    //test code
                    //each train is a dictionary
                    for train in entry{
                        //incoming trains is a dictionary
                        incomingTrains = train as? [String : Any]
                        
                        //set the destination name
                        destination = incomingTrains!["destNm"] as! String
                        //save the destNm and multiple arrT from dictionary
                        //if the destination name is the same, only append the new arrival time
                        if(incomingTrains!["destNm"] as! String == destination){
                            trainTimes.append(incomingTrains!["arrT"] as! String)
                        }
                        
                    }
                    print("train times = ",trainTimes)
                    //test code
                    //destNum = nest1
                    //  guard let imageArray = entry["im:image"] as? [Any] else {
                    //  throw SerializationError.missing("im:image")
                    // }
                    // print("\n\n", "the entry for this one is: ", destNum!, "\n\n")
                    //destination = destNum!["destNm"] as! String
                    //arrivalTime = destNum!["arrT"] as! String
                    //print(destination)
                    //print(arrivalTime)
                   
                    DispatchQueue.main.async {
                        // self.titleLabel.text = title
                        //self.artistLabel.text = artist
                        //print(data)
                        self.trainTimes2 = trainTimes
                        
                    }
                    // if let imageEntry = imageArray.last as? [String:Any],
                    // let imageURL = imageEntry["label"] as? String,
                    //let url = URL(string:imageURL)
                    // {
                    // print("Title: \(title)\nArtist: \(artist)\nImage: \(imageURL)")
                    //self.loadImage(from: url, in: self.imageView)
                    //}
                    
                    
                }
            } catch SerializationError.missing(let msg) {
                print("Missing \(msg)")
            } catch SerializationError.invalid(let msg, let data) {
                print("Invalid \(msg): \(data)")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            }.resume()
        
        if trainTimes2.count > 0 {
            //call trainTimes2
            self.theTrainComing.text = "Next " + _currentStop + " Train Approaching at: \n" + convertArrivalTimeToAMPM(trainTimes2.first!)
        }
        else{
          
            self.theTrainComing.text = "Please Wait.\n Gathering Train information!"
   
        }
    }
    
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
}
func convertArrivalTimeToAMPM(_ train: String)-> String{
    var tmp = ""
    var new = ""
    tmp = String(train.dropFirst(11))
    new = dateFormat(tmp);
    return new
   
}

func dateFormat(_ date:String) -> String{
    //let date = NSDate()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH':'mm':'ss"
    let _date = dateFormatter.date(from: date)
    
    if _date != nil{
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let time = formatter.string(from: (_date as Date?)!)
        return time
    }
    else {
        let time = " "
        return time
    }
    
    // return time
}
class Place : NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(_ coordinate: CLLocationCoordinate2D,
         _ title: String? = nil,
         _ subtitle: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }

}
