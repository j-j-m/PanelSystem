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

open class PanelViewController: NSViewController {

    weak var parentContainer: PanelSplitContainerController?
    var toolbarController = PanelToolbarController(backgroundColor: .darkGray)
    var containerController = ViewController(backgroundColor: .darkGray)
    var trackingArea: NSTrackingArea!

    lazy var borderViews: BorderViews = {
        let borderColor = NSColor.white.withAlphaComponent(0.4)
        // generate border views
        let borders = view.addBorder(edges: [.all], color: borderColor, thickness: 6)
        // set them to be initially hidden 
        borders.forEach { $0.isHidden = true }
        return BorderViews(top: borders[0], right: borders[2], bottom: borders[3], left: borders[1])
    }()
    
    lazy open var panelConstraints: [NSLayoutConstraint] = {
        return [
            self.view.widthAnchor.constraint(greaterThanOrEqualToConstant: 500)
        ]
    }()

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func loadView() {
        let dragHandler = DragHandler()
        dragHandler.parent = self
        dragHandler.container = parentContainer
        dragHandler.updateDragAction = { point in

            self.updateInteractionState(for: point)
        }

        self.view = dragHandler
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }

    private func setupUI() {

        view.addSubview(toolbarController.view)
        toolbarController.parentController = self

        view.addSubview(containerController.view)

        _ = self.borderViews

        setupTracking()
    }

    func setupTracking() {
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
                                           metrics: ["size": 17],
                                           views: ["t": tView, "c": cView]))
        view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[t(==c)]|",
                                           options: [],
                                           metrics: nil,
                                           views: ["t": tView, "c": cView]))

    }

    open override func viewWillLayout() {
        super.viewWillLayout()
        toolbarController.view.layout()
    }

    open override func viewDidLayout() {
        super.viewDidLayout()

        self.view.removeTrackingArea(trackingArea)

        setupTracking()
    }

    open override func mouseExited(with event: NSEvent) {
        borderViews.all.forEach { view in view.isHidden = true }
    }

    private func updateInteractionState(for pointInView: NSPoint?) {

        let b = borderViews

        b.all.forEach { view in view.isHidden = true }

        if let p = pointInView {
            let f = view.frame

            if p.x < f.minX + 20 { b.left.isHidden = false }
            if p.x > f.maxX - 20 { b.right.isHidden = false }
            if p.y < f.minY + 20 { b.bottom.isHidden = false }
            if p.y > f.maxY - 20 { b.top.isHidden = false }
        }

    }

    public func dockRelative(to panel: PanelViewController, at abutment: PanelAbutment) {

        switch abutment {
        case .top(let topo):
            dockTop(with: topo, inPanel: panel)
        case .right(let topo):
            dockRight(with: topo, inPanel: panel)
        case .bottom(let topo):
            dockBottom(with: topo, inPanel: panel)
        case .left(let topo):
            dockLeft(with: topo, inPanel: panel)
        case .none:
            break
        }

    }

    func dockTop(with topo: AbutmentTopology, inPanel panel: PanelViewController) {
        if let c = panel.parentContainer {
            let o = c.orientation
            switch o {
            case .horizontal:
                if let index = c.splitViewItems.index(where: { $0.viewController == panel }) {
                    if let n = self.parentContainer?.pop(self) {
                        c.insert(n, at: index)
                    }
                }
            case .vertical:
                if let index = c.splitViewItems.index(where: { $0.viewController == panel }) {
                    if let n = self.parentContainer?.pop(self)?.viewController,
                        let old = c.pop(c.splitViewItems[index].viewController) {
                        let split = PanelSplitContainerController()
                        split.setup(with: [old.viewController, n], orientation: .horizontal)
                        let item = NSSplitViewItem(viewController: split)
                        c.insert(item, at: index)
                    }
                }
            }
        }
    }

    func dockRight(with topo: AbutmentTopology, inPanel panel: PanelViewController) {
        if let c = panel.parentContainer {
            let o = c.orientation
            switch o {
            case .horizontal:
                if let index = c.splitViewItems.index(where: { $0.viewController == panel }) {
                    if let n = self.parentContainer?.pop(self)?.viewController,
                        let old = c.pop(c.splitViewItems[index].viewController) {
                        let split = PanelSplitContainerController()
                        split.setup(with: [old.viewController, n], orientation: .vertical)
                        let item = NSSplitViewItem(viewController: split)
                        c.insert(item, at: index)
                    }

                }
            case .vertical:
                if let index = c.splitViewItems.index(where: { $0.viewController == panel }) {
                    if let n = self.parentContainer?.pop(self) {
                        c.insert(n, at: index+1)
                    }
                }
            }
        }
    }

    func dockBottom(with topo: AbutmentTopology, inPanel panel: PanelViewController) {
        if let c = panel.parentContainer {
            let o = c.orientation
            switch o {
            case .horizontal:
                if let index = c.splitViewItems.index(where: { $0.viewController == panel }) {
                    if let n = self.parentContainer?.pop(self) {
                        c.insert(n, at: index)
                    }
                }
            case .vertical:
                if let index = c.splitViewItems.index(where: { $0.viewController == panel }) {
                    if let n = self.parentContainer?.pop(self)?.viewController,
                        let old = c.pop(c.splitViewItems[index].viewController) {
                        let split = PanelSplitContainerController()
                        split.setup(with: [n, old.viewController], orientation: .horizontal)
                        let item = NSSplitViewItem(viewController: split)
                        c.insert(item, at: index)
                    }
                }
            }
        }
    }

    func dockLeft(with topo: AbutmentTopology, inPanel panel: PanelViewController) {
        if let c = panel.parentContainer {
            let o = c.orientation
            switch o {
            case .horizontal:
                if let index = c.splitViewItems.index(where: { $0.viewController == panel }) {
                    if let n = self.parentContainer?.pop(self)?.viewController,
                        let old = c.pop(c.splitViewItems[index].viewController) {
                        let split = PanelSplitContainerController()
                        split.setup(with: [n, old.viewController], orientation: .vertical)
                        let item = NSSplitViewItem(viewController: split)
                        c.insert(item, at: index)
                    }

                }
            case .vertical:
                if let index = c.splitViewItems.index(where: { $0.viewController == panel }) {
                    if let n = self.parentContainer?.pop(self) {
                        c.insert(n, at: index)
                    }
                }
            }
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
        self.backgroundColor = NSColor(white: 0.141176, alpha: 1.0)
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
