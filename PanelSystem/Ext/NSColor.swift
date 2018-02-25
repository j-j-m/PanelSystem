//
//  NSColor.swift
//  PanelSystem
//
//  Created by Jacob Martin on 2/23/18.
//  Copyright © 2018 JJ Martin. All rights reserved.
//

import Foundation

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension NSColor {
    static func random() -> NSColor {
        return NSColor(calibratedRed: .random(), green: .random(), blue: .random(), alpha: 1.0)
    }
}
