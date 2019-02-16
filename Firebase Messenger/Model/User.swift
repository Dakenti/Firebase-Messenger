//
//  User.swift
//  Firebase Messenger
//
//  Created by Dake Aga on 1/31/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import Foundation

class User {
    var id: String?
    var name: String?
    var email: String?
    var loginImage: String?
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.loginImage = dictionary["loginImage"] as? String ?? ""
    }
}
