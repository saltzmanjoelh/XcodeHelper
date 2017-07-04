//
//  XCWorkspace.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/25/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation

struct XCWorkspace: XCDocumentable, CustomStringConvertible {
    var path: String
    var currentUser: String?
    var projects: [XCProject]?
    
    public var description: String {
        return URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
    }
    public static func ==(lhs: XCWorkspace, rhs: XCWorkspace) -> Bool {
        return lhs.path == rhs.path
    }
    
    init(at path: String, currentUser: String?){
        self.init(at: path)
        self.currentUser = currentUser
        self.projects = getProjects(from: self.path)
    }
    init(at path: String){
        self.path = path
        
    }
    func getXcUserStateUrl(for user: String, at path: String) -> URL? {
        return URL.init(fileURLWithPath: path).appendingPathComponent("xcuserdata/\(user).xcuserdatad/UserInterfaceState.xcuserstate")
    }
    func getProjects(from workspacePath: String) -> [XCProject]? {
        guard let user = currentUser else { return nil }
        //projects = get a list from contents.xcworkspacedata
        var projectPaths = [String]()
        let path = URL.init(fileURLWithPath: workspacePath).appendingPathComponent("contents.xcworkspacedata")
        do{
            let contents = try String.init(contentsOf: path)
            let regex = try NSRegularExpression(pattern: ":(.*)xcodeproj\"", options: [])
            let rootURL = URL.init(fileURLWithPath: workspacePath).deletingLastPathComponent()
            regex.enumerateMatches(in: contents, options: [], range: NSMakeRange(0, contents.utf8.count), using: { (result: NSTextCheckingResult?, flags: NSRegularExpression.MatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) in
                let resultRange = result!.range
                let contentsRange = contents.index(contents.startIndex, offsetBy: resultRange.location+1) ..<
                    contents.index(contents.startIndex, offsetBy: resultRange.location+1+resultRange.length-2)
                let projectName = contents.substring(with: contentsRange)
                projectPaths.append(rootURL.appendingPathComponent(projectName).path)
            })
        }catch let e {
            print("Error with getProjects: \(e)")
            return nil
        }
        return projectPaths.map{ XCProject(at: $0, currentUser: user) }
    }
    func orderedTargets() -> [XCTarget] {
        guard let projects = getProjects(from: path) else {
            return []
        }
        return projects.map({ $0.orderedTargets() }).flatMap({ $0 }).sorted(by: { $0.orderHint < $1.orderHint })
    }
    func currentTargetName() -> String? {
        //get current project.currentTargetName()
        //for now, we are just going to find the first target that matches, will try to find a better way to resolve duplicate target names later
        guard let user = currentUser,
              let url = getXcUserStateUrl(for: user, at: path),
              let contents = getXcUserStateContents(at: url) else {
            return nil
        }
        return getCurrentTargetName(from: contents)
    }
    func currentTargetPath() -> String? {
        return getProjects(from: self.path)?.first(where: { $0.currentTargetName() == currentTargetName() })?.path
    }
}
