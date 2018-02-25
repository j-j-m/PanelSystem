//
//  PanelController.swift
//  PanelSystem
//
//  Created by Jacob Martin on 2/23/18.
//  Copyright © 2018 JJ Martin. All rights reserved.
//

import AppKit

public class PanelController: NSWindowController, NSWindowDelegate {
    
    var identifier: String?
    
    var orientation: PanelOrientation = .vertical
    
    lazy var container: PanelSplitContainerController = PanelSplitContainerController()
    
    var children: [PanelController]?
    
    public override func loadWindow() {
        super.loadWindow()
        window?.delegate = self
        
        container.loadView()
        
        window?.contentView?.addSubview(container.splitView)
        setupLayout()
    }
    
    func setupLayout() {
        if let contentView = window?.contentView {
            let splitView = container.splitView
            splitView.fill(contentView)
        }
    }
    
    func setup(with controllers: [NSViewController]) {
        container.setup(with: controllers, orientation: orientation)
    }
    
}


