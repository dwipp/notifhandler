//
//  FeatureViewController.swift
//  Example
//
//  Created by Dwi Permana Putra on 10/09/18.
//  Copyright © 2018 Ropen Indonesia. All rights reserved.
//

import UIKit
import notifhandler

class FeatureViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var data:[DataModel] = []
    var subbed = "click to see detail"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "SwipeDK"
        setupTable()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectData()
        self.tableView.reloadData()
    }
    
    private func collectData(){
        data.removeAll()
        let udid = DataModel.init(title: "UDID", subtitle: SwipeDK.collect.getUDID() ?? "Check your SwipeDK Setup", isSubbed: false)
        let idfa = DataModel.init(title: "IDFA", subtitle: SwipeDK.collect.getIDFA() ?? "Check your setting", isSubbed: false)
        let type = DataModel.init(title: "Type", subtitle: SwipeDK.collect.getDeviceName() ?? "Check your SwipeDK Setup", isSubbed: false)
        let os = DataModel.init(title: "Operation System", subtitle: subbed, isSubbed: true)
        
        let timezone = DataModel.init(title: "Timezone", subtitle: "UTC " + (SwipeDK.collect.getTimeZone() ?? "Check your SwipeDK Setup"), isSubbed: false)
        let lang = DataModel.init(title: "Language", subtitle: SwipeDK.collect.getLanguage() ?? "Check your SwipeDK Setup", isSubbed: false)
        let country = DataModel.init(title: "Country", subtitle: SwipeDK.collect.getCountry() ?? "Check your SwipeDK Setup", isSubbed: false)
        let network = DataModel.init(title: "Network Type", subtitle: SwipeDK.collect.getNetworkType() ?? "Unreachable or Check your SwipeDK Setup", isSubbed: false)
        let location = DataModel.init(title: "Location", subtitle: subbed, isSubbed: true)
        let contact = DataModel.init(title: "Contacts", subtitle: subbed, isSubbed: true)
        data.append(contentsOf: [udid, idfa, type, os, timezone, lang, country, network, location, contact])
    }
    
    private func setupTable(){
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sub" {
            let des = segue.destination as! SubFeatureViewController
            des.title = self.title
            des.key = sender as? String
        }
    }
    

}

extension FeatureViewController: UITableViewDelegate, UITableViewDataSource {
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
        let value = data[indexPath.row]
        if value.isSubbed {
            performSegue(withIdentifier: "sub", sender: value.title)
        }
        
    }
}



