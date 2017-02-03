//
//  StatusMenu.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/11/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import AppKit

//NSUserDefaults(suiteName: "<group identifier>");

protocol KeyNamespaceable { }

extension KeyNamespaceable {
    private static func namespace(_ key: String) -> String {
        return "\(Self.self).\(key)"
    }
    
    static func namespace<T: RawRepresentable>(_ key: T) -> String where T.RawValue == String {
        return namespace(key.rawValue)
    }
}

protocol BoolUserDefaultable : KeyNamespaceable {
    associatedtype BoolDefaultKey : RawRepresentable
}

extension BoolUserDefaultable where BoolDefaultKey.RawValue == String {
    
    // Set
    static func set(_ bool: Bool, forKey key: BoolDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(bool, forKey: key)
    }
    
    // Get
    static func bool(forKey key: BoolDefaultKey) -> Bool {
        let key = namespace(key)
        return UserDefaults.standard.bool(forKey: key)
    }
}

extension UserDefaults {
    struct Account : BoolUserDefaultable {
        private init() { }
        
        enum BoolDefaultKey : String {
            case isUserLoggedIn
        }
    }
}
//UserDefaults.Account.set(true, forKey: .isUserLoggedIn)


