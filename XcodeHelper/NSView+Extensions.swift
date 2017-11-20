//
//  NSView+Extensions.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 11/16/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import AppKit

extension NSView {
    public func subview(named name: String) -> NSView? {
        for view in subviews {
            if view.identifier?.rawValue == name  {
                return view
            }
            if let subview = view.subview(named: name) {
                return subview
            }
        }
        return nil
    }
}
