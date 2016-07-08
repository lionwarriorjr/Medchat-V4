//
//  ProfileViewController.swift
//  Medchat
//
//  Created by Srihari Mohan on 5/21/16.
//  Copyright © 2016 Srihari Mohan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var contents = ProfileViewController.populateSettings()
    var imgs = ProfileViewController.populateSettingsImg()
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.image = UIImage(named: "ProfileImage")
        profileImage.layer.cornerRadius = 50
        profileImage.clipsToBounds = true
        tableView.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell")! as UITableViewCell
        
        cell.textLabel?.text = contents[indexPath.row]
        if indexPath.row < imgs.count {
            cell.imageView?.image = imgs[indexPath.row]
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.cellForRowAtIndexPath(indexPath)!.textLabel?.text
            == "Phone" {
            let phoneVC = self.storyboard?.instantiateViewControllerWithIdentifier("PhoneVC")
                as! PhoneViewController
            self.presentViewController(phoneVC, animated: true, completion: nil)
        } else if tableView.cellForRowAtIndexPath(indexPath)!.textLabel?.text
            == "Notifications" {
            let notificationsVC = self.storyboard?.instantiateViewControllerWithIdentifier("NotificationsVC")
                    as! NotificationsViewController
                self.navigationController?.pushViewController(notificationsVC, animated: true)
        } else if tableView.cellForRowAtIndexPath(indexPath)!.textLabel?.text
            == "Payments" {
            let paymentsVC = self.storyboard?.instantiateViewControllerWithIdentifier("StandardTableVC")
                as! StandardTableViewController
            paymentsVC.sects = ["Payment Methods", "Payment History", "Security", "Support"]
            paymentsVC.items = [["Add New Debit Card", "Add New Credit Card", "Copayments"], ["Transactions"], ["PIN"],
                ["Help Center", "Contact Us"]]
            self.navigationController?.pushViewController(paymentsVC, animated: true)
        } else if tableView.cellForRowAtIndexPath(indexPath)!.textLabel?.text
            == "Privacy & Terms" {
            let privacyVC = self.storyboard?.instantiateViewControllerWithIdentifier("StandardTableVC")
                as! StandardTableViewController
            privacyVC.sects = ["Medchat Data Policy", "FDA and HIPAA Compliance, Data Coordination with Providers"]
            privacyVC.items = [["Data Policy","Terms of Service","Third Party Integration"], ["FDA Classification", "HIPAA Compliance",
                "HIPAA Security Rule","Integration With Your EHR"], ["Data Sharing with Providers","Health Insurance Provider Policy"]]
            self.navigationController?.pushViewController(privacyVC, animated: true)
        } else if tableView.cellForRowAtIndexPath(indexPath)!.textLabel?.text
            == "Help" {
            let helpVC = self.storyboard?.instantiateViewControllerWithIdentifier("HelpTableVC")
                as! HelpTableViewController
            helpVC.sects = ["Frequently Asked Questions", "Browse Topics", "Contact Us"]
            helpVC.items = [["Can I chat with my doctor and nurses?", "Can my doctor see my chat history?", "Who is Flo?",
                "Can I turn off notification alerts?", "Can I schedule appointments within Medchat?",
                "How is my data protected?"], ["About Medchat","Staying In Touch With Your Providers",
                "Group Conversations With Providers"], ["Contact Us With Questions"]]
            self.navigationController?.pushViewController(helpVC, animated: true)
        } else if tableView.cellForRowAtIndexPath(indexPath)!.textLabel?.text
            == "Report a Problem" {
            let alertVC = UIAlertController(title: "What about your experience can be improved?", message: "Please let us know in a message to team@medchat.com from your inbox.", preferredStyle: .Alert)
            let alert_action = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            alertVC.addAction(alert_action)
            self.presentViewController(alertVC, animated: true, completion: nil)
        } else {
            let alertVC = UIAlertController(title: "Are you sure you want to log out?", message: "", preferredStyle: .Alert)
            var alert_action = UIAlertAction(title: "Log Out", style: .Default) {
                alert in
                //TODO: logout
            }
            alertVC.addAction(alert_action)
            alert_action = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            alertVC.addAction(alert_action)
            self.presentViewController(alertVC, animated: true, completion: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    private static func populateSettings() -> [String] {
        var contents = [String]()
        contents.appendContentsOf(["Phone","Notifications","Payments","Privacy & Terms",
            "Help","Report a Problem","Log Out"])
        return contents;
    }
    
    private static func populateSettingsImg() -> [UIImage] {
        var imgs = [UIImage]()
        imgs.appendContentsOf([UIImage(named:"Phone")!,UIImage(named:"Notifications")!,UIImage(named: "Payments")!,UIImage(named: "Privacy")!,UIImage(named: "Help")!,UIImage(named: "Report")!])
        return imgs;
    }
}
