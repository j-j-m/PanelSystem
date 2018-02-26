//
//  Docking.swift
//  PanelSystem
//
//  Created by Jacob Martin on 2/21/18.
//  Copyright © 2018 JJ Martin. All rights reserved.
//

import AppKit

@objc protocol DockingInitiator: class {
    @objc func undockPanel()
    @objc func undockPanelTabbed()
    @objc func closePanel()
    @objc func dockingMenu() -> NSMenu
}


