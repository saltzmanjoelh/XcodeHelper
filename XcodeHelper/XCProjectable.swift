//
//  XCProjectable.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/25/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation


protocol XCProjectable {
    var path: String { get set }
    var currentUser: String? { get set }
    
    init(at path: String)
    func getXcUserStateUrl(for user: String, at path: String) -> URL?
    func currentTargetName() -> String?
    func orderedTargets() -> [(Int, String)]?
}

extension XCProjectable {
    public func getCurrentUser() -> String? {
        let result = Process.run("/usr/bin/whoami", arguments: nil, printOutput: false, outputPrefix: nil)
        return result.output?.trimmingCharacters(in: .newlines)
    }
    
    func getXCUserStateContents(at getXcUserStateUrl: URL) -> NSDictionary? {
        guard FileManager.default.fileExists(atPath: getXcUserStateUrl.path) else {
            return nil
        }
        return NSDictionary.init(contentsOfFile: getXcUserStateUrl.path)
    }
    func getCurrentTargetName(from XCUserStateContents: NSDictionary) -> String? {
        guard let objects = XCUserStateContents.object(forKey: "$objects") as? NSArray else {
            return nil
        }
        let targetIndex = objects.index(of: "IDENameString")
        guard targetIndex != NSNotFound else {
            return nil
        }
        return objects[targetIndex+1] as? String
    }
}
