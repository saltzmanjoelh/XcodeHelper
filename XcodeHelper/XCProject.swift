//
//  XCProject.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/25/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation

struct XCProject: XCDocumentable, CustomStringConvertible {
    
    let managementPlistName = "xcschememanagement.plist"
    var path: String
    var currentUser: String?
//    var pbxProjectPath: String {
//        return URL.init(fileURLWithPath: self.path).appendingPathComponent("project.pbxproj").path
//    }
    var pbxProjectContents: NSDictionary?
    public var description: String {
        return URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
    }
    
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
    func getOrderedTargets(at xcSchemesUrl: URL, from xcSchemeManagement: NSDictionary) -> [XCTarget]? {
        guard let schemes = xcSchemeManagement["SchemeUserState"] as? NSDictionary,
            let keys = schemes.allKeys as? [String] else {
            return nil
        }
        var targets = [XCTarget]()
        for key in keys {
            if !key.hasSuffix(".xcscheme") {
                continue;
            }
            if let scheme = schemes[key] as? NSDictionary {
                if let orderHint = scheme["orderHint"] as? NSNumber {
                    if let targetType = getTargetType(for: key, at: xcSchemesUrl) {
                        targets.append(XCTarget(name: key.replacingOccurrences(of: ".xcscheme", with: ""),
                                                orderHint: orderHint.intValue,
                                                targetType: targetType))
                    }
                }
            }
        }
        return targets.count > 0 ? targets.sorted{ $0.orderHint < $1.orderHint } : nil
    }
    
    func getTargetType(for scheme: String, at xcSchemesUrl: URL) -> XCTarget.TargetType? {
        do {
            let xcScheme = try String.init(contentsOfFile: xcSchemesUrl.appendingPathComponent(scheme).path)
            let regex = try NSRegularExpression(pattern: "BuildableName = \"(.*)\"", options: [])
            let matches = regex.matches(in: xcScheme, options: [], range: NSMakeRange(0, xcScheme.utf8.count))
            for result in matches {
                let resultRange = result.range
                let nameRange = xcScheme.index(xcScheme.startIndex, offsetBy: resultRange.location+17) ..< // BuildableName = "
                    xcScheme.index(xcScheme.startIndex, offsetBy: resultRange.location+resultRange.length-1)
                let buildableName = xcScheme.substring(with: nameRange)
                return XCTarget.TargetType(from: URL.init(fileURLWithPath: buildableName).pathExtension)
            }
        }catch _{
           
        }
        return nil
    }
    func orderedTargets() -> [XCTarget]? {
        guard let currentUser = getCurrentUser(),
              let xcSchemesUrl = getXcSchemesUrl(for: currentUser, at: path),
              let xcSchemeManagement = getXcSchemeManagement(from: xcSchemesUrl.appendingPathComponent(managementPlistName)) else {
            return nil
        }
        guard let targets = getOrderedTargets(at: xcSchemesUrl, from: xcSchemeManagement).flatMap({ $0.flatMap({ $0 }) }) else {
            return nil
        }
        return targets
//        return getXcSchemeFiles(at: xcSchemesUrl.path)
    }
    
//    func getXcSchemeFiles(at xcschemesPath: String) -> [XCTarget]? {
//        do{
//            //get the targets like mytarget.xcsheme
//            let targets = try FileManager.default.contentsOfDirectory(atPath: xcschemesPath).filter{ $0.hasSuffix("xcscheme") }
//            //remove .xcscheme and return them with a position
//            return targets.flatMap{ XCTarget(named: $0.replacingOccurrences(of: ".xcscheme", with: ""),
//                                             orderHint: targets.index(of: $0)!) }
//        }catch _ {
//            return nil
//        }
//        
//    }
    func currentTargetName() -> String? {
        guard let user = getCurrentUser(),
              let url = getXcUserStateUrl(for: user, at: path),
              let contents = getXCUserStateContents(at: url) else {
                return nil
        }
        return getCurrentTargetName(from: contents)
    }
}
