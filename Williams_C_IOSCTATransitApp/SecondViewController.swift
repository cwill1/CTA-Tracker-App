//
//  SecondViewController.swift
//  Williams_C_IOSCTATransitApp
//
//  Created by CWILL on 4/26/18.
//  Copyright © 2018 DePaul. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainTimes.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basic")! as UITableViewCell
        
        cell.textLabel!.text = trainTimes[indexPath.row]
        
        return cell;
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.delegate = self
        //tableView.dataSource = self
        
        //DispatchQueue.main.async{
           // self.tableView.reloadData()
       // }
        // Do any additional setup after loading the view.
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
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
    func convertArrivalTimeToAMPM(){
        var tmp = ""
        var i = 0;
        for time in trainTimes{
            tmp = String(time.dropFirst(11))
            //trainTimes[i] = tmp;
            trainTimes[i] = dateFormat(tmp);
            //convert number to regular time
            
            i += 1;
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async{
            self.convertArrivalTimeToAMPM()
            self.tableView.reloadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

