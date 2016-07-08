//
//  Content.swift
//  Medchat
//
//  Created by Srihari Mohan on 6/8/16.
//  Copyright © 2016 Srihari Mohan. All rights reserved.
//

import Foundation
import CoreData


class Content: NSManagedObject {

    // Insert code here to add functionality to your managed object subclass
    convenience init(sender: String, date: String, body: String, creationDate: NSDate,
                     context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Content", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.sender = sender
            self.body = body
            self.date = date
            self.creationDate = creationDate
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
