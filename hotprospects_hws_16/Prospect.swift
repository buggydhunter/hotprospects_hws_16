//
//  Prospect.swift
//  hotprospects_hws_16
//
//  Created by Onur Ay on 07.10.26.
//

import SwiftData


@Model
class Prospect {
    var name: String
    var emailAddress: String
    var isContacted: Bool
    
    init(name: String, emailAddress: String, isContacted: Bool) {
        self.name = name
        self.emailAddress = emailAddress
        self.isContacted = isContacted
    }
}
