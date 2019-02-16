//
//  Message.swift
//  Firebase Messenger
//
//  Created by Dake Aga on 2/9/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit

class Message: NSObject {
    var toId: String?
    var fromId: String?
    var timestamp: NSNumber?
    var text: String?
    
    init(dictionary: [String : Any]) {
        self.toId = dictionary["toId"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? NSNumber ?? 0
        self.text = dictionary["text"] as? String ?? ""
    }
}
