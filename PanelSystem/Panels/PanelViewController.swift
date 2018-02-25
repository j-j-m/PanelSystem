//
//  Operations.swift
//  PanelSystem
//
//  Created by Jacob Martin on 2/20/18.
//  Copyright © 2018 JJ Martin. All rights reserved.
//

// MARK: - PanelViewController


struct BorderViews {
    let top: NSView
    let right: NSView
    let bottom: NSView
    let left: NSView
    
    var all: [NSView] {
        return [top, right, bottom, left]
    }
}

public class PanelViewController: NSViewController {
    
    weak var parentContainer: PanelSplitContainerController?
    var toolbarController = PanelToolbarController(backgroundColor: .darkGray)
    var containerController = ViewController(backgroundColor: .darkGray)
    
    var trackingArea: NSTrackingArea!
    
    lazy var borderViews: BorderViews = {
        let borderColor = NSColor.white.withAlphaComponent(0.4)
        // generate border views
        let borders = view.addBorder(edges: [.all], color:borderColor, thickness: 6)
        // set them to be initially hidden 
        borders.forEach { $0.isHidden = true }
        return BorderViews(top: borders[0], right: borders[2], bottom: borders[3], left: borders[1])
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func loadView() {
        let dragHandler = DragHandler()
        
        dragHandler.updateDragAction = { point in
            
            self.updateInteractionState(for: point)
        }
        
        self.view = dragHandler
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    private func setupUI() {
        
        view.addSubview(toolbarController.view)
        toolbarController.parentController = self
        
        view.addSubview(containerController.view)
        
        let _ = self.borderViews
        
        setupTracking()
    }
    
    func setupTracking(){
        trackingArea = NSTrackingArea(rect: self.view.bounds,
                                      options: [.activeAlways,
                                                .mouseEnteredAndExited,
                                                .mouseMoved,
                                                .enabledDuringMouseDrag],
                                      owner: self, userInfo: nil)
        self.view.addTrackingArea(trackingArea)
    }
    
    private func setupLayout() {
        
        let tView = toolbarController.view
        let cView = containerController.view
        
        tView.translatesAutoresizingMaskIntoConstraints = false
        cView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[t(==size)][c]|",
                                           options: [],
                                           metrics: ["size": 15],
                                           views: ["t": tView, "c": cView]))
        view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat:  "H:|[t(==c)]|",
                                           options: [],
                                           metrics: nil,
                                           views: ["t": tView, "c": cView]))
        
        
    }
    
    public override func viewWillLayout() {
        super.viewWillLayout()
        toolbarController.view.layout()
    }
    
    public override func viewDidLayout() {
        super.viewDidLayout()
        
        self.view.removeTrackingArea(trackingArea)
        
        setupTracking()
    }
    
    
    public override func mouseExited(with event: NSEvent) {
        borderViews.all.forEach { v in v.isHidden = true }
    }
    
    private func updateInteractionState(for pointInView: NSPoint?) {
        
        let b = borderViews
        
        b.all.forEach { v in v.isHidden = true }
        
        if let p = pointInView {
            let f = view.frame
            
            if p.x < f.minX + 20 { b.left.isHidden = false }
            if p.x > f.maxX - 20 { b.right.isHidden = false }
            if p.y < f.minY + 20 { b.bottom.isHidden = false }
            if p.y > f.maxY - 20 { b.top.isHidden = false }
        }
        
    }
}

// MARK: - Extensions

extension NSWindow {
    
    func dragEndpoint(at point: CGPoint) -> DragEndpoint? {
        var view = contentView?.hitTest(point)
        while let candidate = view {
            if let endpoint = candidate as? DragEndpoint { return endpoint }
            view = candidate.superview
        }
        return nil
    }
    
}

// MARK: - Debug Objects

class ViewController: NSViewController {
    
    private let backgroundColor: NSColor
    
    init(backgroundColor: NSColor) {
        self.backgroundColor = .random()
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = backgroundColor.cgColor
    }
    
}
