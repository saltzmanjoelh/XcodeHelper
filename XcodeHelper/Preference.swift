//
//  Preference.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 6/4/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation
import XcodeHelperKit

public enum Preference {
    case logging
    public var stringValue: String {
        return "\(self)"
    }
    public enum UpdatePackages {
        public enum macOS: String {
            case generateXcodeproj = "UpdatePackages.macOS.generateXcodeproj"
            case symlinkDependencies = "UpdatePackages.macOS.symlinkDependencies"
        }
        public enum Docker: String {
            case imageName = "UpdatePackages.Docker.imageName"
        }
        
    }
    public enum BuildInDocker: String {
        case buildOnSuccess = "BuildInDocker.buildOnSuccess"
        case configuration = "BuildInDocker.configuration"
        case imageName = "BuildInDocker.imageName"
    }
    public enum CreateArchive: String {
        case flatList = "CreateArchive.flatList"
    }
    public enum CreateXCArchive: String {
        case flatList = "CreateXCArchive.flatList"
    }
    public enum UploadArchive: String {
        case bucket = "UploadArchive.bucket"
        case region = "UploadArchive.region"
        case key = "UploadArchive.key"
        case secret = "UploadArchive.secret"
    }
    public enum GitTag: String {
        case push = "GitTag.push"
    }
    public enum General: String {
        case alerts = "General.alerts"
    }
    
}
extension UserDefaults {
    public static func initializeDefaults() {
        
//        let keys = [Preference.logging.stringValue,
//                    Preference.UpdatePackages.macOS.generateXcodeproj.rawValue, Preference.UpdatePackages.macOS.symlinkDependencies.rawValue,
//                    Preference.UpdatePackages.Docker.imageName.rawValue,
//                    Preference.BuildInDocker.buildOnSuccess.rawValue, Preference.BuildInDocker.configuration.rawValue, Preference.BuildInDocker.imageName.rawValue,
//                    Preference.CreateArchive.flatList.rawValue,
//                    Preference.CreateXCArchive.flatList.rawValue,
//                    Preference.UploadArchive.bucket.rawValue, Preference.UploadArchive.region.rawValue, Preference.UploadArchive.key.rawValue, Preference.UploadArchive.secret.rawValue,
//                    Preference.GitTag.push.rawValue,
//                    Preference.General.alerts.rawValue
//                    ]
        let stringKeys = [Preference.BuildInDocker.imageName.rawValue, Preference.UpdatePackages.Docker.imageName.rawValue]
        let dictionary = self.standard.dictionaryRepresentation()
//        print("dictionary: \(dictionary)")
        stringKeys.forEach({ (key: String) in
            if dictionary[key] == nil ||
                (dictionary[key] as? String) == "" {
                self.standard.set("swift", forKey: key)
            }
        })
    }
}
