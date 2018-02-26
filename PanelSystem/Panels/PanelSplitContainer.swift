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
        
        self.splitView.isVertical = orientation == .horizontal
        splitView.dividerStyle = .thin
        view.wantsLayer = true
        
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
            }
            
            let item = NSSplitViewItem(viewController: vc)
            
            return item
        }
        
    }
    
}

extension PanelSplitContainerController: PanelToolbarControllerDelegate {
    
    func pop(_ panel: NSViewController) {
        guard let index = splitViewItems.index(where: { $0.viewController == panel } ) else { return }
        splitViewItems.remove(at: index)
    }
    
    func undock(_ panel: NSViewController) {
        
        let frame = panel.view.screenFrame ?? defaultFrame
        
        pop(panel)
        
        let _ = panelController(with: [panel], at: frame)
        
    }
    
    func undockTabbed(_ panel: NSViewController) {
        
        let frame = panel.view.screenFrame ?? defaultFrame
        let window = panel.view.window
        pop(panel)
        
        let _ = panelController(with: [panel], at: frame, parent: window)
        
    }
    
    func remove(_ panel: NSViewController) {
        pop(panel)
    }
}
