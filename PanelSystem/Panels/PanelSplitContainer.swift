//
//  PanelSplitContainer.swift
//  PanelSystem
//
//  Created by Jacob Martin on 2/22/18.
//  Copyright © 2018 JJ Martin. All rights reserved.
//

import Foundation

// MARK: - PanelSplitView

public class PanelSplitView: NSSplitView {
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required public init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var dividerColor: NSColor {
        return NSColor(calibratedWhite: 0.2, alpha: 1.0)
    }
}

// MARK: - PanelSplitContainerController

public class PanelSplitContainerController: NSSplitViewController {
    
    var orientation: PanelOrientation = .vertical
    
    var _splitViewItems: [NSSplitViewItem]?
    
    override public init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        
        let panelSplitView = PanelSplitView()
        splitView = panelSplitView
        super.loadView()
        setupUI()
        setupLayout()
    }
    
    private func setupUI() {
        
        self.splitView.isVertical = orientation == .vertical
        splitView.dividerStyle = .thin
//        view.wantsLayer = true
        
    }
    
    private func setupLayout() {
        if let items = _splitViewItems {
            self.splitViewItems = items
        }
    }
    
    func setup(with controllers: [NSViewController], orientation: PanelOrientation) {
        
        self.orientation = orientation
        self._splitViewItems = controllers.map { vc in
            
            vc.view.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
            
            if let pvc = vc as? PanelViewController {
                pvc.toolbarController.delegate = self
                pvc.parentContainer = self 
            }
            
            let item = NSSplitViewItem(viewController: vc)
            
            return item
        }
        
    }
    
    func insert(_ item: NSSplitViewItem, at index: Int) {
        
        print("ADDITION: -")
        
        if let vc = item.viewController as? PanelViewController {
            vc.toolbarController.delegate = self
            vc.parentContainer = self 
        }
        
        if let items = _splitViewItems, index <= items.count  || index == 0 {
            _splitViewItems?.insert(item, at: index)
        } else {
            _splitViewItems?.append(item)
        }
        var glyphs = self.splitViewItems.map({ _ in "🅰️" }).reduce("",{ $0 + $1 })
        print("Before: \(glyphs)")

        
        setupLayout()
        glyphs = self.splitViewItems.map({ _ in "🅱️" }).reduce("",{ $0 + $1 })
        print("After: \(glyphs)")
    }
    
}


extension PanelSplitContainerController: PanelToolbarControllerDelegate {
    
    @discardableResult func pop(_ panel: NSViewController) -> NSSplitViewItem? {
        print("Items Count: \(self.splitViewItems.count)")
        guard let index = splitViewItems.index(where: { $0.viewController == panel } ) else { return nil }
        
        print("REMOVAL: -")
        
        var glyphs = self.splitViewItems.map({ _ in "🅰️" }).reduce("",{ $0 + $1 })
        print("Before: \(glyphs)")
        
        
        let element = _splitViewItems?.remove(at: index)
        setupLayout()
        
        glyphs = self.splitViewItems.map({ _ in "🅱️" }).reduce("",{ $0 + $1 })
        print("After: \(glyphs)")
        
        if splitViewItems.count == 0, let p = parent as? PanelSplitContainerController {
        
             guard let index = p.splitViewItems.index(where: { $0.viewController == self } ) else { return nil }
            p.splitViewItems.remove(at: index)
            
        }
        
        return element
    }
    
    func undock(_ panel: NSViewController) {
        
        let frame = panel.view.screenFrame ?? defaultFrame
        
        if let p = pop(panel), let vc = p.viewController as? PanelViewController {
            let _ = panelController(with: [vc], at: frame)
        }
        
    }
    
    func undockTabbed(_ panel: NSViewController) {
        
        let frame = panel.view.screenFrame ?? defaultFrame
        let window = panel.view.window
        if let p = pop(panel), let vc = p.viewController as? PanelViewController {
            let _ = panelController(with: [vc], at: frame, parent: window)
        }
        
    }
    
    func remove(_ panel: NSViewController) {
        pop(panel)
    }
}
