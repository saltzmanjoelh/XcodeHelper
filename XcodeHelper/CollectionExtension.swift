//
//  CollectionExtension.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 2/5/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    public subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
