//
//  XCProject.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/25/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation
import xcproj

public struct XCProject: XCDocumentable, CustomStringConvertible, Hashable, Equatable, XCItem {
    
    static let defaultImagePath = "/Applications/Xcode.app/Contents/Resources/xcode-project_Icon.icns"
    let managementPlistName = "xcschememanagement.plist"
    public var path: String
    public var currentUser: String? = nil
    public var modificationDate: NSDate?
    public var xcproj: XcodeProj?
    
    
    public var hashValue: Int {
        get{
            return path.hash
        }
    }
    public static func ==(lhs: XCProject, rhs: XCProject) -> Bool {
        return lhs.path == rhs.path
    }
    
//    var pbxProjectPath: String {
//        return URL.init(fileURLWithPath: self.path).appendingPathComponent("project.pbxproj").path
//    }
    var pbxProjectContents: NSDictionary?
    public var description: String {
        return URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
    }
    
    public var imagePath: String {
        return XCProject.defaultImagePath
    }
    
    public init(at path: String, currentUser: String?){
        self.init(at: path)
        self.currentUser = currentUser
        print("XcodeProj: \(path)")
        do {
            self.xcproj = try XcodeProj.init(pathString: path)
        } catch let error {
            print(error)
        }
    }
    public init(at path: String){
        self.path = path
        self.modificationDate = schemeManagementModificationDate()
    }
    
    public func getXcUserStateUrl(for user: String, at path: String) -> URL? {
        return URL.init(fileURLWithPath: path).appendingPathComponent("project.xcworkspace/xcuserdata/\(user).xcuserdatad/UserInterfaceState.xcuserstate")
    }
    func getUserXcSchemesURL(_ user: String, at path: String) -> URL? {
        let url = URL.init(fileURLWithPath: path).appendingPathComponent("xcuserdata/\(user).xcuserdatad/xcschemes/")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }
    func getSharedXcSchemesURL(at path: String) -> URL? {
        let url = URL.init(fileURLWithPath: path).appendingPathComponent("xcshareddata/xcschemes/")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }
    func getXcSchemeURLs(_ user: String, at path: String) -> [URL]? {
        var urls = [URL]()
        if let userURL = getUserXcSchemesURL(user, at: path) {
            urls.append(userURL)
        }
        if let sharedURL = getSharedXcSchemesURL(at: path) {
            urls.append(sharedURL)
        }
        return urls.count > 0 ? urls : nil
    }
    public func getXcSchemeManagement(from userSchemeManagementURL: URL) -> NSDictionary? {
        return NSDictionary.init(contentsOf: userSchemeManagementURL)
    }
    public func schemeManagementModificationDate() -> NSDate? {
        guard let user = currentUser,
              let userSchemeURL = getUserXcSchemesURL(user, at: self.path)
              else { return nil }
        let managementURL = userSchemeURL.appendingPathComponent(managementPlistName)
        return FileManager.default.modificationDateOfFile(path: managementURL.path)
    }
    
    
    func getTargetNames() -> [String]? {
//        guard let contents = FileManager.default.recursiveContents(of: URL(fileURLWithPath: projectPath)) else { return nil }
//        let targetNames: [String] = contents.compactMap{ return $0.pathExtension == "xcscheme" ? $0.lastPathComponent : nil }
//        return targetNames.count > 0 ? targetNames.sorted{ $0 < $1 } : nil
        let targets = xcproj?.pbxproj.objects.nativeTargets.map({ $0.value.name }) ?? []
        return targets
    }
    
    //returns an index of TargetName.xcscheme:XCTarget.TargetType
    func getTargetTypes(for targetNames: [String], from xcSchemesUrls: [URL]) -> [String:XCTarget.TargetType]? {
        var targetTypes: [String:XCTarget.TargetType] = [:]
        for name in targetNames {
            if let targetType:XCTarget.TargetType = getTargetType(for: name, from: xcSchemesUrls) {
                targetTypes[name] = targetType
            }
        }
        return targetTypes
    }
    //xcproj version
    func getTargetTypes() -> [String: XCTarget.TargetType]? {
        var targetTypes: [String:XCTarget.TargetType] = [:]
        if let nativeTargets = xcproj?.pbxproj.objects.nativeTargets {
            for target in nativeTargets {
                if let fileExtension = target.value.productType?.fileExtension {
                    targetTypes[target.value.name] = XCTarget.TargetType.init(from: fileExtension)
                }
            }
        }
        return targetTypes
    }
    
    func getTargetType(for scheme: String, from xcSchemesUrls: [URL]) -> XCTarget.TargetType? {
        let trimmedScheme = scheme.replacingOccurrences(of: "_^#shared#^_", with: "")
        for url in xcSchemesUrls {
            var schemeUrl = url.appendingPathComponent(trimmedScheme)
            if schemeUrl.pathExtension != "xcscheme" {
                schemeUrl.appendPathExtension("xcscheme")
            }
            let filePath = schemeUrl.path
            if !FileManager.default.fileExists(atPath: filePath) {
                continue
            }
            return parseTargetTypeFromXcSchemeFile(at: filePath)
        }
        return nil
    }
    func parseTargetTypeFromXcSchemeFile(at path: String) -> XCTarget.TargetType? {
        var xcScheme: String = ""
        var matches = [NSTextCheckingResult]()
        do {
            xcScheme = try String.init(contentsOfFile: path)
            let regex = try NSRegularExpression(pattern: "BuildableName = \"(.*)\"", options: [])
            matches = regex.matches(in: xcScheme, options: [], range: NSMakeRange(0, xcScheme.utf8.count))
        }catch let e{
            print(e)
        }
        
        var buildableName: String?
        for result in matches {
            let resultRange = result.range
            let nameRange = xcScheme.index(xcScheme.startIndex, offsetBy: resultRange.location+17) ..< // BuildableName = "
                xcScheme.index(xcScheme.startIndex, offsetBy: resultRange.location+resultRange.length-1)
            buildableName = String(xcScheme[nameRange.lowerBound..<nameRange.upperBound])
            break
        }
        
        return buildableName != nil ? XCTarget.TargetType(from: URL.init(fileURLWithPath: buildableName!).pathExtension) : nil
    }
    func getXcSchemeManagementURLs(at projectPath: String) -> [URL]? {
        guard let contents = FileManager.default.recursiveContents(of: URL(fileURLWithPath: projectPath)) else { return nil }
        let urls: [URL] = contents.compactMap{ return $0.lastPathComponent == "xcschememanagement.plist" ? $0 : nil }
        return urls.count > 0 ? urls : nil
    }
    //returns an index of TargetName.xcscheme:OrderHint
    func getOrderHints(from xcSchemeManagementUrls: [URL]) -> [String:Int] {
        //TODO: this should fail if xcSchemeManagement, schemes or keys aren't available?
        var orderHints = [String:Int]()
        for url in xcSchemeManagementUrls {
            if let xcSchemeManagement = NSDictionary.init(contentsOf: url),
               let schemes = xcSchemeManagement["SchemeUserState"] as? NSDictionary,
               let keys = schemes.allKeys as? [String] {
                for key in keys {
                    if let scheme = schemes[key] as? NSDictionary,
                       let orderHint = scheme["orderHint"] as? NSNumber {
                        let targetName = key.replacingOccurrences(of: "_^#shared#^_", with: "")
                        orderHints[targetName] = orderHint.intValue
                    }
                }
            }
        }
        return orderHints
    }
    
    func getOrderedTargets(fromXcSchemesUrls xcSchemesUrls: [URL], with schemeManagementURLs: [URL]) -> [XCTarget]? {
        guard let targetNames = getTargetNames(),
//              let targetTypes = getTargetTypes(for: targetNames, from: xcSchemesUrls)
                let targetTypes = getTargetTypes()
              else { return nil }
        let orderHints = getOrderHints(from: schemeManagementURLs)
        
        return targetNames.map{
            let key = $0.hasSuffix(".xcscheme") ? $0 : $0.appending(".xcscheme")
            return XCTarget(name: $0.replacingOccurrences(of: ".xcscheme", with: ""),
                            orderHint: orderHints[key] ?? Int.max,
                            targetType: targetTypes[key] ?? .unknown,
                            project: self)}
          .sorted(by: { $0.orderHint < $1.orderHint })
    }
    
    public func orderedTargets() -> [XCTarget] {
        guard let user = currentUser,
              let schemeURLs = getXcSchemeURLs(user, at: path),
              let schemeManagementURLs = getXcSchemeManagementURLs(at: path),
              let targets = getOrderedTargets(fromXcSchemesUrls: schemeURLs, with: schemeManagementURLs) else {
            return []
        }
        return targets
    }
    
    public func currentTargetName() -> String? {
        guard let user = currentUser,
              let url = getXcUserStateUrl(for: user, at: path),
              let contents = getXcUserStateContents(at: url) else {
                return nil
        }
        return getCurrentTargetName(from: contents)
    }
    public func currentTargetPath() -> String? {
        return self.path
    }
}
