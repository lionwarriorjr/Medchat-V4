//
//  Content+CoreDataProperties.swift
//  Medchat
//
//  Created by Srihari Mohan on 6/8/16.
//  Copyright © 2016 Srihari Mohan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Content {

    @NSManaged var body: String?
    @NSManaged var date: String?
    @NSManaged var sender: String?
    @NSManaged var creationDate: NSDate?

}
