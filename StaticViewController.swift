//
//  StaticViewController.swift
//  Williams_C_IOSCTATransitApp
//
//  Created by CWILL on 4/29/18.
//  Copyright © 2018 DePaul. All rights reserved.
//

import UIKit

class StaticViewController: UITableViewController {
    override func numberOfSections(in tableView: UITableView)
        -> Int {
            return 1;
    }
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return trainTimes.count;
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier:"basic",
                for: indexPath)
            // Configure the cell...
            cell.textLabel?.text = trainTimes[indexPath.row]
            return cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        tableView.delegate = self
        tableView.dataSource = self
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
 */
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
