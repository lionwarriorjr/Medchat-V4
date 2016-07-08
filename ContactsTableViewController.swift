//
//  ContactsTableViewController.swift
//  Medchat
//
//  Created by Srihari Mohan on 6/17/16.
//  Copyright © 2016 Srihari Mohan. All rights reserved.
//

import UIKit

class ContactsTableViewController: UITableViewController {

    var contacts = ["Dr. Elaine Cho","Sheryl Smith","Katherine Steiner",
        "Ryan Newsome"]
    var roles = ["General Physician","Nurse Practitioner","Registered Nurse",
                 "Cognitive Therapist"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contacts.count;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! Contacts
        cell.person.text = contacts[indexPath.row]
        cell.providerRole.text = roles[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell;
    }
}
