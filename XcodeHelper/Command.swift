//
//  Command.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/21/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation

enum Command: String {
    
    case updateMacOsPackages = "Update Packages - macOS"
    case updateDockerPackages = "Update Packages - Docker"
    case buildInDocker = "Build in Docker"
    case symlinkDependencies = "Symlink Dependencies"
    case createArchive = "Create Archive"
    case createXcarchive = "Create XCArchive"
    case uploadArchive = "Upload Archive"
    case gitTag = "Git Tag"
    
    static var allValues: [Command] {
        get {
            return [.updateMacOsPackages,
            .updateDockerPackages,
            .buildInDocker,
            .symlinkDependencies,
            .createArchive,
            .createXcarchive,
            .uploadArchive,
            .gitTag]
        }
    }
}
