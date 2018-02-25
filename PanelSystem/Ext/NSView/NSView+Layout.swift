//
//  NSView+Layout.swift
//  PanelSystem
//
//  Created by Jacob Martin on 2/23/18.
//  Copyright © 2018 JJ Martin. All rights reserved.
//

import Foundation

extension NSView {
    func fill(_ superview: NSView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let trailingAnchor = self.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        let leadingAnchor = self.leadingAnchor.constraint(equalTo: superview.leadingAnchor)
        let topAnchor = self.topAnchor.constraint(equalTo: superview.topAnchor)
        let bottomAnchor = self.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        
        NSLayoutConstraint.activate([trailingAnchor, leadingAnchor, topAnchor, bottomAnchor])
    }
}
