//
//  XCTarget.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 2/5/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation
import xcproj

public struct XCTarget: CustomStringConvertible, XCItem, Equatable {
    
    public let name: String
    public var orderHint: Int
    public var type: XCTarget.TargetType
    public let project: XCProject
    
    public var description: String {
        return name
    }
    
    public init(name: String, orderHint: Int, targetType: TargetType, project: XCProject) {
        self.name = name
        self.orderHint = orderHint
        self.type = targetType
        self.project = project
    }
    
    public func imageData() -> Data? {
        //TODO: add option to parse plist and get image name - ProjectOne/App/Info.plist CFBundleIconFile
        //TODO: add option to parse pbxproj and get AppIcon - ProjectOne/ProjectOne.xcodeproj/project.pbxproj ASSETCATALOG_COMPILER_APPICON_NAME
        if type == .app {

        }
        return try? Data.init(contentsOf: URL(fileURLWithPath: defaultImagePath(for: type)))
    }
    
    public enum TargetType: Equatable {
        case app
        case binary
        case framework
        case test
        case appExtension
        case bundle
        case xpc
        case appleScriptAction
        case kernelExtension
        case staticLib
        case metalLib
        case prefPane
        case plugin
        case screenSaver
        case spotlightImporter
        case quartzPlugin
        case unknown
        
        public init(from extensionName: String){
            switch extensionName {
            case "app":
                self = .app
            case "":
                self = .binary
            case "framework":
                self = .framework
            case "xctest":
                self = .test
            case "appex":
                self = .appExtension
            case "bundle":
                self = .bundle
            case "xpc":
                self = .xpc
            case "action":
                self = .appleScriptAction
            case "kext":
                self = .kernelExtension
            case "a":
                self = .staticLib
            case "metallib":
                self = .metalLib
            case "prefPane":
                self = .prefPane
            case "plugin":
                self = .plugin
            case "saver":
                self = .screenSaver
            case "mdimporter":
                self = .spotlightImporter
            case "qlgenerator":
                self = .quartzPlugin
            default:
                self = .unknown
            }

        }
    }
    
    
    public var imagePath: String {
        get {
            return defaultImagePath(for: self.type)
        }
    }
    public func defaultImagePath(for targetType: TargetType) -> String {
        switch targetType {
        case .app:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Application/Cocoa App.xctemplate/TemplateIcon@2x.png"
        case .binary:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Application/Command Line Tool.xctemplate/TemplateIcon@2x.png"
        case .framework:
            return "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Templates/Project Templates/iOS/Framework & Library/Cocoa Touch Framework.xctemplate/TemplateIcon.icns"
        case .test:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Test/macOS Unit Testing Bundle.xctemplate/TemplateIcon@2x.png"
        case .appExtension:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Application Extension/Xcode Source Editor Extension.xctemplate/TemplateIcon@2x.png"
        case .bundle:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Other/IOKit Driver.xctemplate/TemplateIcon.icns"
        case .staticLib:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Framework & Library/Library.xctemplate/TemplateIcon@2x.png"
        case .xpc:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Framework & Library/XPC Service.xctemplate/TemplateIcon.icns"
        case .appleScriptAction:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Other/AppleScript App.xctemplate/TemplateIcon@2x.png"
        case .metalLib:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Framework & Library/Metal Library.xctemplate/TemplateIcon@2x.png"
        case .kernelExtension, .plugin, .prefPane, .screenSaver, .spotlightImporter, .quartzPlugin:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Other/Generic Kernel Extension.xctemplate/TemplateIcon.png"
        case .unknown:
            return "/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Resources/BrokenLink.icns"
        }
    }

    public static func ==(lhs: XCTarget, rhs: XCTarget) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type && lhs.project.path == rhs.project.path
    }
}
