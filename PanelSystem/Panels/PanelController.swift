//
//  PanelController.swift
//  PanelSystem
//
//  Created by Jacob Martin on 2/23/18.
//  Copyright © 2018 JJ Martin. All rights reserved.
//

import AppKit

fileprivate extension NSTouchBar.CustomizationIdentifier {

    static let touchBar = "JJM.PanelSystem"
}

fileprivate extension NSTouchBarItem.Identifier {

    static let popover = NSTouchBarItem.Identifier("JJM.PanelSystem.popover")
    static let fontStyle = NSTouchBarItem.Identifier("JJM.PanelSystem.fontStyle")
    static let popoverSlider = NSTouchBarItem.Identifier("JJM.PanelSystem.slider")
}

public class PanelController: NSWindowController, NSWindowDelegate {

    let fontSizeToolbarItemID   = "FontSize"
    let fontStyleToolbarItemID  = "FontStyle"
    let defaultFontSize: Int    = 18

    var identifier: String?

    var orientation: PanelOrientation = .vertical

    lazy var container: PanelSplitContainerController = PanelSplitContainerController()

    var toolbar: NSToolbar!

    var children: [PanelController]?

    public override func loadWindow() {
        super.loadWindow()
        window?.delegate = self

        container.loadView()

        window?.contentView?.addSubview(container.splitView)
        setupLayout()

        if let t = window?.toolbar {
            self.toolbar = t
            self.toolbar.allowsUserCustomization = true
            self.toolbar.autosavesConfiguration = true
            self.toolbar.displayMode = .iconOnly
            self.toolbar.delegate = self
        }
    }

    func setupLayout() {
        if let contentView = window?.contentView {
            let splitView = container.splitView
            splitView.fill(contentView)
        }
    }

    public func setup(with controllers: [NSViewController]) {
        container.setup(with: controllers, orientation: orientation)
    }

    public override func newWindowForTab(_ sender: Any?) {
        // add window
    }

}

// MARK: - NSToolbarDelegate

extension PanelController: NSToolbarDelegate {

    /**
     Factory method to create NSToolbarItems.
     
     All NSToolbarItems have a unique identifer associated with them, used to tell your delegate/controller
     what toolbar items to initialize and return at various points.  Typically, for a given identifier,
     you need to generate a copy of your "master" toolbar item, and return.  The function
     creates an NSToolbarItem with a bunch of NSToolbarItem paramenters.
     
     It's easy to call this function repeatedly to generate lots of NSToolbarItems for your toolbar.
     
     The label, palettelabel, toolTip, action, and menu can all be nil, depending upon what you want
     the item to do.
     */
    func customToolbarItem(itemForItemIdentifier itemIdentifier: String,
                           label: String,
                           paletteLabel: String,
                           toolTip: String,
                           target: AnyObject,
                           itemContent: AnyObject,
                           action: Selector?,
                           menu: NSMenu?) -> NSToolbarItem? {

        let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: itemIdentifier))

        toolbarItem.label = label
        toolbarItem.paletteLabel = paletteLabel
        toolbarItem.toolTip = toolTip
        toolbarItem.target = target
        toolbarItem.action = action

        // Set the right attribute, depending on if we were given an image or a view.
        if itemContent is NSImage {
            if let image: NSImage = itemContent as? NSImage {
                toolbarItem.image = image
            }
        } else if itemContent is NSView {
            if let view: NSView = itemContent as? NSView {
                toolbarItem.view = view
            }
        } else {
            assertionFailure("Invalid itemContent: object")
        }

        /* If this NSToolbarItem is supposed to have a menu "form representation" associated with it
         (for text-only mode), we set it up here.  Actually, you have to hand an NSMenuItem
         (not a complete NSMenu) to the toolbar item, so we create a dummy NSMenuItem that has our real
         menu as a submenu.
         */
        // We actually need an NSMenuItem here, so we construct one.
        let menuItem: NSMenuItem = NSMenuItem()
        menuItem.submenu = menu
        menuItem.title = label
        toolbarItem.menuFormRepresentation = menuItem

        return toolbarItem
    }

    /**
     This is an optional delegate function, called when a new item is about to be added to the toolbar.
     This is a good spot to set up initial state information for toolbar items, particularly items
     that you don't directly control yourself (like with NSToolbarPrintItemIdentifier here).
     The notification's object is the toolbar, and the "item" key in the userInfo is the toolbar item
     being added.
     */
    public func toolbarWillAddItem(_ notification: Notification) {

        let userInfo = notification.userInfo!
        guard let addedItem = userInfo["item"] as? NSToolbarItem else { return }

        let itemIdentifier = addedItem.itemIdentifier

        if itemIdentifier.rawValue == "NSToolbarPrintItem" {
            addedItem.toolTip = "Print your document"
            addedItem.target = self
        }
    }

    /**
     NSToolbar delegates require this function.
     It takes an identifier, and returns the matching NSToolbarItem. It also takes a parameter telling
     whether this toolbar item is going into an actual toolbar, or whether it's going to be displayed
     in a customization palette.
     */
    private func toolbar(_ toolbar: NSToolbar,
                         itemForItemIdentifier itemIdentifier: String,
                         willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        var toolbarItem: NSToolbarItem = NSToolbarItem()

        /* We create a new NSToolbarItem, and then go through the process of setting up its
         attributes from the master toolbar item matching that identifier in our dictionary of items.
         */
        if itemIdentifier == fontStyleToolbarItemID {
            toolbarItem = customToolbarItem(itemForItemIdentifier: fontStyleToolbarItemID,
                                            label: "Font Style",
                                            paletteLabel: "Font Style",
                                            toolTip: "Change your font style",
                                            target: self,
                                            itemContent: NSView(),
                                            action: nil,
                                            menu: nil)!
        } else if itemIdentifier == fontSizeToolbarItemID {

            toolbarItem = customToolbarItem(itemForItemIdentifier: fontSizeToolbarItemID,
                                            label: "Font Size",
                                            paletteLabel: "Font Size",
                                            toolTip: "Grow or shrink the size of your font",
                                            target: self,
                                            itemContent: NSView(),
                                            action: nil,
                                            menu: nil)!
        }
        return toolbarItem
    }

    /**
     NSToolbar delegates require this function.  It returns an array holding identifiers for the default
     set of toolbar items.  It can also be called by the customization palette to display the default toolbar.
     */
    private func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {

        return [fontStyleToolbarItemID, fontSizeToolbarItemID]
        /*  Note:
         That since our toolbar is defined from Interface Builder, an additional separator and customize
         toolbar items will be automatically added to the "default" list of items.
         */
    }

    /**
     NSToolbar delegates require this function.  It returns an array holding identifiers for all allowed
     toolbar items in this toolbar.  Any not listed here will not be available in the customization palette.
     */
    private func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [String] {

        return [ fontStyleToolbarItemID,
                 fontSizeToolbarItemID,
                 NSToolbarItem.Identifier.space.rawValue,
                 NSToolbarItem.Identifier.flexibleSpace.rawValue,
                 NSToolbarItem.Identifier.print.rawValue ]
    }

}
