//
//  XchelperServiceable.swift
//  xchelperxpc
//
//  Created by Joel Saltzman on 4/6/18.
//  Copyright © 2018 Joel Saltzman. All rights reserved.
//

import Foundation

@objc(XchelperServiceable) protocol XchelperServiceable {
    func run(commandIdentifier: String, withReply: @escaping (Any) -> ())
}

