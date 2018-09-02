//
//  PanelToolbarController.swift
//  PanelSystem
//
//  Created by Jacob Martin on 2/21/18.
//  Copyright © 2018 JJ Martin. All rights reserved.
//

import AppKit

extension NSImage {
    static func named(_ resourceName: String) -> NSImage? {
        let name = resourceName
        guard let bundle = Bundle(identifier: "JJM.PanelSystem") else { return nil }
        return bundle.image(forResource: name)
    }
}

// MARK: - Panel Toolbar Elements

struct PanelToolbarElements {
    static var dockingButton: DockingOperationGlyph {
        let b = DockingOperationGlyph()
        b.wantsLayer = true
        b.layer?.contents = NSImage.named("docking_icon")
        return b
    }
}

// MARK: - PanelToolbarController

/// PanelToolbarControllerDelegate
protocol PanelToolbarControllerDelegate: class {
    func undock(_ panel: NSViewController)
    func undockTabbed(_ panel: NSViewController)
    func remove(_ panel: NSViewController)
}

/// PanelToolbarController
class PanelToolbarController: NSViewController {

    private let backgroundColor: NSColor

    var dockingButton: DockingOperationGlyph!

    weak var parentController: PanelViewController? {
        didSet {
             self.dockingButton.parent = parentController
        }
    }
    weak var delegate: PanelToolbarControllerDelegate? {
        didSet {
            print("set delegate")
        }
    }

    init(backgroundColor: NSColor) {
        self.backgroundColor = backgroundColor

        dockingButton = PanelToolbarElements.dockingButton

        super.init(nibName: nil, bundle: nil)

        dockingButton.menuAction = {
            self.openMenu(sender: self.dockingButton)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.addSubview(dockingButton)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

    }

    func setupLayout() {

        dockingButton.translatesAutoresizingMaskIntoConstraints = false

        view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-(2)-[d]-(2)-|",
                                           options: [],
                                           metrics: ["size": 0],
                                           views: ["d": dockingButton]))
        view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-(2)-[d]",
                                           options: [],
                                           metrics: nil,
                                           views: ["d": dockingButton]))

        view.addConstraint(NSLayoutConstraint(item: dockingButton,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: dockingButton,
                                              attribute: .height,
                                              multiplier: 1,
                                              constant: 0))
    }

    @IBAction func openMenu(sender: DockingOperationGlyph) {
        let p = NSPoint(x: sender.frame.midX, y: sender.frame.midY)
        let menu = dockingMenu()
        menu.popUp(positioning: menu.item(at: 0), at: p, in: view)
    }

}

extension PanelToolbarController: DockingInitiator {
    @objc func dockingMenu() -> NSMenu {
        let menu = NSMenu()
        let undockPanelMenuItem = NSMenuItem(title: "Undock", action: #selector(self.undockPanel), keyEquivalent: "")
        undockPanelMenuItem.target = self

        let undockPanelTabbedMenuItem = NSMenuItem(title: "Undock to New Tab",
                                                   action: #selector(self.undockPanelTabbed),
                                                   keyEquivalent: "")
        undockPanelTabbedMenuItem.target = self
        let closePanelMenuItem = NSMenuItem(title: "Close", action: #selector(self.closePanel), keyEquivalent: "")
        closePanelMenuItem.target = self

        menu.addItem(undockPanelMenuItem)
        menu.addItem(undockPanelTabbedMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(closePanelMenuItem)
//        menu.autoenablesItems = false

        return menu
    }

    @objc func undockPanel() {
        if let d = delegate, let p = parentController {
            d.undock(p)
        }
    }

    @objc func undockPanelTabbed() {
        if let d = delegate, let p = parentController {
            d.undockTabbed(p)
        }
    }

    @objc func closePanel() {
        if let d = delegate, let p = parentController {
            d.remove(p)
        }
    }
}
