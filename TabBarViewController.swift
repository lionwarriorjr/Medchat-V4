//
//  TabBarViewController.swift
//  Medchat
//
//  Created by Srihari Mohan on 5/21/16.
//  Copyright © 2016 Srihari Mohan. All rights reserved.
//

import Foundation
import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1.0)
        UITabBar.appearance().barTintColor = tabColor
        //let iconColor = UIColor(red: 64/255.0, green: 158/255.0, blue: 240/255.0, alpha: 1.0)
        let iconColor = UIColor(red: 0/255.0, green: 142/255.0, blue: 204/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = iconColor
    }
}
