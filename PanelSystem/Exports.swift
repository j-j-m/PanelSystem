//
//  Exports.swift
//  PanelSystem
//
//  Created by Jacob Martin on 2/20/18.
//  Copyright © 2018 JJ Martin. All rights reserved.
//

import Cocoa

extension NSView {
    var screenFrame: NSRect? {
        let rectOnScreen = self.convert(self.bounds, to: nil)
        return self.window?.convertToScreen(rectOnScreen)
    }
}

private let defaultWindowSize = NSSize(width: NSScreen.main!.frame.width * 0.80,
                                       height: NSScreen.main!.frame.height * 0.80)
internal let defaultFrame = NSRect(origin: .zero, size: defaultWindowSize)

public var panelControllers: [PanelController] = []

private func basicWindow(with frame: NSRect? = nil, centered: Bool = false) -> NSWindow {

    let frame = frame ?? defaultFrame
    let window = NSWindow(contentRect: frame,
                          styleMask: [.closable, .titled, .borderless, .resizable],
                          backing: .buffered,
                          defer: false)
    window.toolbar = NSToolbar(identifier: NSToolbar.Identifier("maintoolbar"))
    window.setFrame(frame, display: true)
    window.appearance = NSAppearance(named: .vibrantDark)

    window.isOpaque = false

    centered ? window.center() : nil

    window.title = "Main Panel"

    window.isMovableByWindowBackground = false
    window.backgroundColor = .gridColor

    return window
}

public var panelWindowController: NSWindowController? = {
    let window = basicWindow(centered: true)
    let controller = PanelController()

    let p = testPanel()
    controller.setup(with: [p.controller()])
    controller.window = window
    controller.loadWindow()
    panelControllers.append(controller)
    return controller
}()

public func panelController(with controllers: [NSViewController],
                            at frame: NSRect? = nil,
                            parent: NSWindow? = nil) -> NSWindowController {
    let window = basicWindow(with: frame)
    let controller = PanelController()
    controller.setup(with: controllers)

    controller.window = window
    controller.loadWindow()
    window.title = "Window"
    if let p = parent {
        p.addTabbedWindow(window, ordered: .above)
    } else {
        window.makeKeyAndOrderFront(nil)
    }

    panelControllers.append(controller)
    return controller
}
