//
//  XCTarget.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 2/5/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation

struct XCTarget: CustomStringConvertible {
    
    enum TargetType {
        case app
        case binary
        case framework
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
        
        init(from extensionName: String){
            switch extensionName {
            case "app":
                self = .app
            case "":
                self = .binary
            case "framework":
                self = .framework
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
    func defaultImagePath(for targetType: TargetType) -> String {
        switch targetType {
        case .app:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Application/Cocoa Application.xctemplate/TemplateIcon.icns"
        case .binary:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Application/Command Line Tool.xctemplate/TemplateIcon.icns"
        case .framework:
            return "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Templates/Project Templates/iOS/Framework & Library/Cocoa Touch Framework.xctemplate/TemplateIcon.icns"
        case .appExtension:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Application Extension/Xcode Source Editor Extension.xctemplate/TemplateIcon@2x.png"
        case .bundle:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Other/IOKit Driver.xctemplate/TemplateIcon.icns"
        case .staticLib:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Framework & Library/Library.xctemplate/TemplateIcon@2x.png"
        case .xpc:
            return "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Framework & Library/XPC Service.xctemplate/TemplateIcon.icns"
        case .appleScriptAction:
            return defaultImagePath(for: .app)
        case .metalLib:
            return defaultImagePath(for: .staticLib)
        case .kernelExtension, .plugin, .prefPane, .screenSaver, .spotlightImporter, .quartzPlugin:
            return defaultImagePath(for: .bundle)
        default:
            return "/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Resources/BrokenLink.icns"
        }
    }

    let name: String
    var orderHint: Int
    var type: XCTarget.TargetType

    public var description: String {
        return name
    }
    
    init(name: String, orderHint: Int, targetType: TargetType) {
        self.name = name
        self.orderHint = orderHint
        self.type = targetType
    }
    
    public func imageData() -> Data? {
        //TODO: add option to parse plist and get image name - ProjectOne/App/Info.plist CFBundleIconFile
        //TODO: add option to parse pbxproj and get AppIcon - ProjectOne/ProjectOne.xcodeproj/project.pbxproj ASSETCATALOG_COMPILER_APPICON_NAME
        return try? Data.init(contentsOf: URL(fileURLWithPath: defaultImagePath(for: type)))
    }
}
