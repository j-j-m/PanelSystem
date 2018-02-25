//
//  AppDelegate.swift
//  PanelSystemExample
//
//  Created by Jacob Martin on 2/20/18.
//  Copyright © 2018 JJ Martin. All rights reserved.
//

import Cocoa
import PanelSystem

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        if let controller = PanelSystem.panelWindowController, let window = controller.window {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}

