//
//  XCDocumentable.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/25/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation
import ProcessRunner

protocol XCDocumentable {
    var path: String { get set }
    var currentUser: String? { get set }
    
    init(at path: String)
    func getXcUserStateUrl(for user: String, at path: String) -> URL?
    func currentTargetName() -> String?
    func orderedTargets() -> [XCTarget]
}

extension XCDocumentable {
    public static func getCurrentUser() -> String? {
        let result = ProcessRunner.synchronousRun("/usr/bin/whoami")
        return result.output?.trimmingCharacters(in: .newlines)
    }
    
    func getXcUserStateContents(at xcUserStateUrl: URL) -> NSDictionary? {
        guard FileManager.default.fileExists(atPath: xcUserStateUrl.path) else {
            return nil
        }
        return NSDictionary.init(contentsOfFile: xcUserStateUrl.path)
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
