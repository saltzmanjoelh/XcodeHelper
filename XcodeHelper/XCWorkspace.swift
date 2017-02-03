//
//  XCWorkspace.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/25/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation

struct XCWorkspace: XCProjectable {
    
    var path: String
    var currentUser: String?
    var projects: [XCProject]?
    
    init(at path: String){
        self.path = path
        currentUser = getCurrentUser()
        projects = getProjects(from: self.path)
    }
    
    func getProjects(from workspacePath: String) -> [XCProject]? {
        //projects = get a list from contents.xcworkspacedata
        var projectPaths = [String]()
        let path = URL.init(fileURLWithPath: workspacePath).appendingPathComponent("contents.xcworkspacedata")
        do{
            let contents = try String.init(contentsOf: path)
            let regex = try NSRegularExpression(pattern: ":(.*)xcodeproj\"", options: [])
            regex.enumerateMatches(in: contents, options: [], range: NSMakeRange(0, contents.utf8.count), using: { (result: NSTextCheckingResult?, flags: NSRegularExpression.MatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) in
                let resultRange = result!.range
                let contentsRange = contents.index(contents.startIndex, offsetBy: resultRange.location+1) ..<
                    contents.index(contents.startIndex, offsetBy: resultRange.location+1+resultRange.length-2)
                projectPaths.append(contents.substring(with: contentsRange))
            })
        }catch let e {
            print("Error with getProjects: \(e)")
        }
        return projectPaths.map{ XCProject(at: $0) }
    }
    func targetNames() -> [String]? {
        return nil
    }
    func currentTargetName() -> String? {
        //get current project.currentTargetName()
        return nil
    }
}
