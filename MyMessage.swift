//
//  MyMessage.swift
//  Medchat
//
//  Created by Srihari Mohan on 5/21/16.
//  Copyright © 2016 Srihari Mohan. All rights reserved.
//

import Foundation
import UIKit

struct MyMessage {
    var sender: String?
    var topic: String?
    var content: String
    var baseImage: UIImage?
    
    static let SenderKey = "SenderKey"
    static let TopicKey = "TopicKey"
    static let ContentKey = "ContentKey"
    static let ImageKey = "ImageKey"
    
    init(dictionary: [String: AnyObject?]) {
        self.sender = dictionary[MyMessage.SenderKey] as! String?
        self.topic = dictionary[MyMessage.TopicKey] as! String?
        self.content = dictionary[MyMessage.ContentKey] as! String
        self.baseImage = dictionary[MyMessage.ImageKey] as! UIImage?
    }
}

extension MyMessage {
    static var testSet: [MyMessage] {
        get {
            var testInbox = [MyMessage]()
            for d in MyMessage.localInbox() {
                testInbox.append(MyMessage(dictionary: d))
            }
            return testInbox;
        }
    }
    
    static func localInbox() -> [[String: AnyObject?]] {
        var demoDictionary: [[String: AnyObject?]]
        demoDictionary = [
            [MyMessage.SenderKey: "Dr. Elaine Cho ", MyMessage.TopicKey: "Progress Update: Halfway to Recovery!", MyMessage.ContentKey: "You passed all your progress tests this week. Way to go!", MyMessage.ImageKey: nil]
        ]
        return demoDictionary;
    }
}