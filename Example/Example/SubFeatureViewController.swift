//
//  SubFeatureViewController.swift
//  Example
//
//  Created by Dwi Permana Putra on 10/09/18.
//  Copyright © 2018 Ropen Indonesia. All rights reserved.
//

import UIKit
import notifhandler

class SubFeatureViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var data:[DataModel] = []
    var key:String? = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = key
        collectData()
        setupTable()
        // Do any additional setup after loading the view.
    }
    
    private func collectData(){
        if key == "Operation System" {
            let name = DataModel.init(title: "Name", subtitle: SwipeCollect.getSystemName(), isSubbed: false)
            let version = DataModel.init(title: "Version", subtitle: SwipeCollect.getSystemVersion(), isSubbed: false)
            let kernel = DataModel.init(title: "Kernel", subtitle: SwipeCollect.getKernel(), isSubbed: false)
            data.append(contentsOf: [name, version, kernel])
        }else if key == "Location" {
            let loc = SwipeCollect.getLocation()
            let lat = DataModel.init(title: "Latitude", subtitle: "\(loc.0 ?? 0)", isSubbed: false)
            let lon = DataModel.init(title: "Longitude", subtitle: "\(loc.1 ?? 0)", isSubbed: false)
            data.append(contentsOf: [lat, lon])
        }
    }
    
    private func setupTable(){
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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

extension SubFeatureViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if cell.detailTextLabel == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        let value = data[indexPath.row]
        cell.textLabel?.text = value.title
        cell.detailTextLabel?.text = value.subtitle
        if value.isSubbed {
            cell.accessoryType = .disclosureIndicator
        }else {
            cell.accessoryType = .none
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}