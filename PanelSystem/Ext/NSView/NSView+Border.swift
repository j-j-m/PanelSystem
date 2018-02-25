//
//  NSView.swift
//  PanelSystem
//
//  Created by Jacob Martin on 2/22/18.
//  Copyright © 2018 JJ Martin. All rights reserved.
//

import Foundation

struct NSRectEdges: OptionSet {
    let rawValue: Int
    
    /// The top edge of the rectangle.
    static var top = NSRectEdges(rawValue: 1 << 0)
    
    /// The left edge of the rectangle.
    static var left = NSRectEdges(rawValue: 1 << 1)
    
    /// The bottom edge of the rectangle.
    static var bottom = NSRectEdges(rawValue: 1 << 2)
    
    /// The right edge of the rectangle.
    static var right = NSRectEdges(rawValue: 1 << 3)
    
    /// All edges of the rectangle.
    static var all: NSRectEdges = [.top, .left, .bottom, .right]
    
}

extension NSView {
    
    @discardableResult func addBorder(edges: NSRectEdges, color: NSColor = .green, thickness: NSNumber = 1.0) -> [NSView] {
        
        var borders = [NSView]()
        
        func border() -> NSView {
            let border = NSView()
            border.wantsLayer = true
            border.layer?.backgroundColor = color.cgColor
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }
        
        if edges.contains(.top) || edges.contains(.all) {
            let top = border()
            self.addSubview(top)
            self.addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[top(==thickness)]",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["top": top]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[top]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["top": top]))
            borders.append(top)
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            let left = border()
            addSubview(left)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[left(==thickness)]",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["left": left]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[left]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["left": left]))
            borders.append(left)
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            let right = border()
            addSubview(right)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["right": right]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[right]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["right": right]))
            borders.append(right)
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            let bottom = border()
            addSubview(bottom)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:[bottom(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["bottom": bottom]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[bottom]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["bottom": bottom]))
            borders.append(bottom)
        }
        
        return borders
    }
    
}
