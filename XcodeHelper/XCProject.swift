//
//  XCProject.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/25/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation

struct XCProject: XCProjectable {
    
    let managementPlistName = "xcschememanagement.plist"
    var path: String
    var currentUser: String?
//    var pbxProjectPath: String {
//        return URL.init(fileURLWithPath: self.path).appendingPathComponent("project.pbxproj").path
//    }
    var pbxProjectContents: NSDictionary?
    
    init(at path: String){
        self.path = path
//        self.pbxProjectContents = getPbxProjectContents(at: pbxProjectPath)
    }
//    func getPbxProjectContents(at pbxProjectPath: String) -> NSDictionary? {
//        return NSDictionary.init(contentsOfFile: pbxProjectPath)
//    }
//    func getObjects(from pbxProjectContents: NSDictionary) -> [NSDictionary]? {
//        guard let objects = pbxProjectContents["objects"] as? NSDictionary else {
//            return nil
//        }
//        return objects.allValues as? [NSDictionary]
//    }
//    func getTargetNames(from pbxProjectContents: NSDictionary) -> [String]? {
//        return getObjects(from: pbxProjectContents)?.flatMap({ (object: NSDictionary) in
//            guard let targetName = object["productName"] else {
//                return nil
//            }
//            return targetName as? String
//        })
//    }
    func getXcUserStateUrl(for user: String, at path: String) -> URL? {
        return URL.init(fileURLWithPath: path).appendingPathComponent("project.xcworkspace/xcuserdata/\(user).xcuserdatad/UserInterfaceState.xcuserstate")
    }
    func getXcSchemesUrl(for user: String, at path: String) -> URL? {
        return URL.init(fileURLWithPath: path).appendingPathComponent("xcuserdata/\(user).xcuserdatad/xcschemes/")
    }
    func getXcSchemeManagement(from schemeManagementURL: URL) -> NSDictionary? {
        return NSDictionary.init(contentsOf: schemeManagementURL)
    }
    func getOrderedTargets(from xcSchemeManagement: NSDictionary) -> [(Int, String)]? {
        guard let schemes = xcSchemeManagement["SchemeUserState"] as? NSDictionary,
            let keys = schemes.allKeys as? [String] else {
            return nil
        }
        var targets = [(Int, String)]()
        for key in keys {
            if !key.hasSuffix(".xcscheme") {
                continue;
            }
            if let scheme = schemes[key] as? NSDictionary {
                if let orderHint = scheme["orderHint"] as? NSNumber {
                    //targetNames[orderHint.intValue] = key.replacingOccurrences(of: ".xcscheme", with: "")
                    targets.append( (orderHint.intValue,key.replacingOccurrences(of: ".xcscheme", with: "")) )
                }
            }
        }
        return targets.count > 0 ? targets.sorted{ $0.0 < $1.0 } : nil
    }
    func orderedTargets() -> [(Int, String)]? {
        guard let currentUser = getCurrentUser(),
              let xcSchemesUrl = getXcSchemesUrl(for: currentUser, at: path),
              let xcSchemeManagement = getXcSchemeManagement(from: xcSchemesUrl.appendingPathComponent(managementPlistName)) else {
            return nil
        }
        if let targets = getOrderedTargets(from: xcSchemeManagement).flatMap({ $0.flatMap({ $0 }) }) {
            return targets
        }
        return getXcSchemeFiles(at: xcSchemesUrl.path)
    }
    
    func getXcSchemeFiles(at xcschemesPath: String) -> [(Int, String)]? {
        do{
            //get the targets like mytarget.xcsheme
            let targets = try FileManager.default.contentsOfDirectory(atPath: xcschemesPath).filter{ $0.hasSuffix("xcscheme") }
            //remove .xcscheme and return them with a position
            return targets.flatMap{ (targets.index(of: $0)!, $0.replacingOccurrences(of: ".xcscheme", with: "")) }
        }catch _ {
            return nil
        }
        
    }
    func currentTargetName() -> String? {
        guard let user = getCurrentUser(),
              let url = getXcUserStateUrl(for: user, at: path),
              let contents = getXCUserStateContents(at: url) else {
                return nil
        }
        return getCurrentTargetName(from: contents)
    }
}
