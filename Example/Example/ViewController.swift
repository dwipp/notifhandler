//
//  ViewController.swift
//  Example
//
//  Created by Dwi Permana Putra on 15/08/18.
//  Copyright © 2018 Ropen Indonesia. All rights reserved.
//

import UIKit
import notifhandler
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var lblToken: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.setToken(_:)), name: NSNotification.Name("setToken"), object: nil)
        
        let tapToken = UITapGestureRecognizer(target: self, action: #selector(self.copyToken))
        lblToken.addGestureRecognizer(tapToken)
        lblToken.isUserInteractionEnabled = false
        
        let network = SwipeCollect.getNetworkType()
        print("network: \(network)")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("setToken"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @objc func setToken(_ sender:Notification){
        let userInfo = sender.userInfo
        if let token = userInfo?["token"] as? String {
            lblToken.text = token
            lblToken.isUserInteractionEnabled = true
        }else {
            lblToken.text = "No token found. Please try to restart SwipeDK sample app."
            lblToken.isUserInteractionEnabled = false
        }
    }
    
    @objc func copyToken(){
        let board = UIPasteboard.general
        board.string = lblToken.text
        
        let alert = UIAlertController(title: nil, message: "Token has been copied", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
