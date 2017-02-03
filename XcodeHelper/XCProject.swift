//
//  XCProject.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/25/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation

struct XCProject: XCProjectable {
    
    var path: String
    var currentUser: String?
    var pbxProjectPath: String {
        return URL.init(fileURLWithPath: self.path).appendingPathComponent("project.pbxproj").path
    }
    var pbxProjectContents: NSDictionary?
    
    init(at path: String){
        self.path = path
        self.pbxProjectContents = getPbxProjectContents(at: pbxProjectPath)
    }
    func getPbxProjectContents(at pbxProjectPath: String) -> NSDictionary? {
        return NSDictionary.init(contentsOfFile: pbxProjectPath)
    }
    func getObjects(from pbxProjectContents: NSDictionary) -> [NSDictionary]? {
        guard let objects = pbxProjectContents["objects"] as? NSDictionary else {
            return nil
        }
        return objects.allValues as? [NSDictionary]
    }
    func getTargetNames(from pbxProjectContents: NSDictionary) -> [String]? {
        return getObjects(from: pbxProjectContents)?.flatMap({ (object: NSDictionary) in
            guard let targetName = object["productName"] else {
                return nil
            }
            return targetName as? String
        })
    }
    func targetNames() -> [String]? {
        return nil
    }
    func currentTargetName() -> String? {
        return nil
    }
}
