//
//  XcodeViewModel.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 2/16/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation

class XcodeViewModel {
    
    let xcode: Xcode
    let projects: [XCProject]
    let targets: [XCProject:[XCTarget]]
    let flatList: [XCItem]
    
    init(xcode: Xcode, document: XCDocumentable?) {
        self.xcode = xcode
        if let currentDocument = document {
            self.projects = xcode.getProjects(from: currentDocument)
            targets = projects.reduce([XCProject:[XCTarget]](), { (result, project) -> [XCProject:[XCTarget]] in
                var copy = result
                copy[project] = project.orderedTargets()
                return copy
            })
        } else {
            self.projects = []
            self.targets = [XCProject:[XCTarget]]()
        }
        var list = [XCItem]()
        for project in projects {
            list.append(project)
            if let projectTargets: [XCItem] = targets[project] {
                list += projectTargets
            }
        }
        self.flatList = list
    }
}
