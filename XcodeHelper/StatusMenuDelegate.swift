//
//  StatusMenuDelegate.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/21/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import AppKit

@objc
protocol StatusMenuDelegate: NSMenuDelegate {
    func preferences(sender: Any)
    func quit(sender: Any)
    func updateMacOsPackages()
    func updateDockerPackages()
    func buildInDocker()
    func symlinkDependencies()
    func createArchive()
    func uploadArchive()
    func gitTag()
    func createXCArchive()
}
