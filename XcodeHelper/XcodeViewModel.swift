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
    var projects = [XCProject]()
    var targets = [XCProject:[XCTarget]]()
    var flatList = [XCItem]()
    
    init(xcode: Xcode, document: XCDocumentable?) {
        self.xcode = xcode
        self.document = document
        documentChangedHandler()
    }
    
    var document: XCDocumentable? {
        didSet {
            documentChangedHandler()
        }
    }
    
    
    func documentChangedHandler() {
        if let currentDocument = self.document {
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
