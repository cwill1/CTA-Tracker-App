//
//  FirstViewController.swift
//  Williams_C_IOSCTATransitApp
//
//  Created by CWILL on 4/26/18.
//  Copyright © 2018 DePaul. All rights reserved.
//

import UIKit

//trains ..data

let trains = ["Red", "Blue","Purple", "Brown","Green", "Pink","Orange","Yellow"]

let stops = ["Wilson-Red-Howard","Wilson-Red-95th","Harlem-Blue-OHare","Harlem-Blue-ForestPark","Linden-Purple-Loop","Kimball-Brown-Loop", "SouthPort-Brown-Kimball", "Ridgland-Green-Harlem", "Ridgeland-Green-63rd", "Kostner-Pink-54th", "Kostner-Pink-Loop","Midway-Orange-Loop", "Oakton-Yellow-Howard","Oakton-Yellow-Dempster"]
//
var feed = "http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx?key=bd5b626c2e554a78adeffc17b722fd5e&stpid=30105&outputType=JSON"
var incomingTrains: [String:Any]? = nil
var destNum: [String:Any]? = nil
var arrT = ""

var destination = ""
var arrivalTime = ""
var trainTimes = [String]()

var selectedStop = ""
var selectedTrain = ""

class FirstViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 1){
            return trains.count;
        }
        else{
            return stops.count;
        }
        
    }
    
    
    
    @IBAction func switchToLocationAndMapView(_ sender: UIButton) {
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int)
        -> String? {
            if (pickerView.tag == 1){
                return trains[row]
            }
            else{
                return stops[row]
            }
    }
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    @IBOutlet weak var Picker: UIPickerView!
    
    @IBOutlet weak var Picker2: UIPickerView!
    @IBAction func SaveChanges(_ sender: UIButton) {
        
        //p.5 tabs and pickers
        //the select action
        //change the string in feed
        var myStpid = "30297"
        selectedTrain = trains[Picker.selectedRow(inComponent: 0)]
        selectedStop = stops[Picker2.selectedRow(inComponent: 0)]
        print("ggg the selected stop" , selectedStop)
        
        switch(selectedStop){
            
            case "Wilson-Red-Howard": myStpid = "30106";break;
            case "Wilson-Red-95th": myStpid = "30105";break;
            
            case "Harlem-Blue-OHare": myStpid = "30189";break;
            case "Harlem-Blue-ForestPark": myStpid = "30146";break;
            
            case "Linden-Purple-Loop":myStpid = "30204";break;
    
            case "Kimball-Brown-Loop":myStpid = "30250";break;
            case"SouthPort-Brown-Kimball":myStpid = "30070";break;
            
            case "Ridgland-Green-Harlem":myStpid = "30120";break;
            case "Ridgeland-Green-63rd":myStpid = "30119";break;
            
            case "Kostner-Pink-54th":myStpid = "30118";break;
            case "Kostner-Pink-Loop":myStpid = "30117";break;
            
            case "Midway-Orange-Loop":myStpid = "30181";break;
            
            case "Oakton-Skokie-Howard" :myStpid = "30298";break;
            case "Oakton-Skokie-Dempster":myStpid = "30297";break;
            default: break;
        }
        
        feed = "http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx?key=bd5b626c2e554a78adeffc17b722fd5e&stpid=" + myStpid + "&outputType=JSON"
        //particularly the stopid
        selected()
        JSONProcessing()
        //selected()
    }
    func selectionValidation() -> Bool{
        let train = selectedTrain
        let stop = selectedStop
        
        if stop.range(of:train) != nil {
            return true
        }
        else{
            return false;
        }

    }
    func selected(){
        //validate correct selection
        let validationPassed = selectionValidation()
        
        //
        let title = "Train Confirmation"
        let message = "You have selected a \(selectedTrain + " Line Train to : ")\(selectedStop)"
        let alertController = UIAlertController(title: title,
                                                message: message, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .destructive) { action in //do nothing
                                            
        }
        let confirmAction = UIAlertAction(title: "Confirm",
                                          style: .default) { action in //do nothing
        }
        
        //else clause
        let title2 = "Incorrect Combination. Select Cancel. Choose corresponding color line and stop"
        let message2 = "You have selected a \(trains[Picker.selectedRow(inComponent: 0)] + " Line Train to : ")\(stops[Picker2.selectedRow(inComponent: 0)])"
        let alertController2 = UIAlertController(title: title2,
                                                message: message2, preferredStyle: .actionSheet)
        let cancelAction2 = UIAlertAction(title: "Cancel",
                                         style: .destructive) { action in //do nothing
                                            
        }
        
        
        
        if(validationPassed){
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            present(alertController, animated: true, completion: nil)
            
            //code to populate other list 
        }
        else{
            alertController2.addAction(cancelAction2)
            alertController2.addAction(confirmAction)
            present(alertController2, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //JSONProcessing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func JSONProcessing2(){
        
        guard let feedURL = URL(string: feed) else {
            return
        }
        
        let request = URLRequest(url: feedURL)
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let data = data else { return }
            
            print(data)
        }
        
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
            
            print(data)
            
            do {
                if let json =
                    try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                {
                    print(json)
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
        
        
    }

   
}

