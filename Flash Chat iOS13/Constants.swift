//
//  Constants.swift
//  Flash Chat iOS13
//
//  Created by GurPreet SaiNi on 2024-03-20.
//  Copyright © 2024 Angela Yu. All rights reserved.
//

import Foundation

struct Constants {
    
    static let appName = "⚡️FlashChat"
    
    static let cellIdentifier = "ReusableCell"
    static let cellNibName = "MessageCell"
    
    struct Segues{
        static let registerToChat = "RegisterToChat"
        static let loginToChat = "LoginToChat"
    }
    
    struct BrandColors {
        static let purple = "BrandPurple"
        static let lightPurple = "BrandLightPurple"
        static let blue = "BrandBlue"
        static let lighBlue = "BrandLightBlue"
    }
    
    struct FStore {
        static let collectionName = "messages"
        static let senderField = "sender"
        static let bodyField = "body"
        static let dateField = "date"
    }
}
