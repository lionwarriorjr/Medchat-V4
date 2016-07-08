//
//  InboxViewController.swift
//  Medchat
//
//  Created by Srihari Mohan on 5/21/16.
//  Copyright © 2016 Srihari Mohan. All rights reserved.
//

import Foundation
import UIKit

class InboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var inbox: [MyMessage] = MyMessage.testSet
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        self.edgesForExtendedLayout = UIRectEdge.None
        
        self.navigationController?.toolbarHidden = false
        var items = Array<UIBarButtonItem>()
        let cancel = UIImage(named: "Cancel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let bbIcon = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(dismiss))
        bbIcon.image = cancel
        items.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil))
        items.append(bbIcon)
        items.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil))
        self.navigationController?.setToolbarItems(items, animated: true)
        tableView.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismiss()
    }
    
    @IBAction func compose(sender: AnyObject) {
    
    }
    
    @objc private func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inbox.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("InboxCell")! as UITableViewCell
        let message = self.inbox[indexPath.row]
        
        if let label = message.sender {
            cell.textLabel?.text = label
        }
        
        if let detailedText = message.topic {
            cell.detailTextLabel?.text = detailedText
        }
        
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let messageVC = self.storyboard?.instantiateViewControllerWithIdentifier("MessageVC")
            as! MessageViewController
        messageVC.message = self.inbox[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.presentViewController(messageVC, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
}
