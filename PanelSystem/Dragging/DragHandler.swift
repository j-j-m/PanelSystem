//
//  DragHandler.swift
//  PanelSystem
//
//  Created by Jacob Martin on 2/23/18.
//  Copyright © 2018 JJ Martin. All rights reserved.
//

import Cocoa

protocol DragEndpoint {
    var parent: PanelViewController? { get set }
    var dragState: State { get set }
    func dragFinished()
}

protocol DragSource: DragEndpoint {}

protocol DragTerminal: DragEndpoint {}

enum State {
    case idle
    case source
    case target
}

public enum AbutmentTopology {
    case interior, exterior
}

public enum PanelAbutment {
    case none
    case top(AbutmentTopology)
    case right(AbutmentTopology)
    case bottom(AbutmentTopology)
    case left(AbutmentTopology)
}

class DockingOperationGlyph: NSView, DragSource {

    weak var parent: PanelViewController?

    var menuAction: () -> Void = { }

    lazy var controller = ConnectionDragController()

    var dragState: State = State.idle { didSet { needsLayout = true } }

    var interiorDrag: Bool = true

    func dragFinished() {}

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        menuAction()
    }

    override func mouseDragged(with event: NSEvent) {
        if let window = self.window,
            let source = window.dragEndpoint(at: event.locationInWindow) {
            controller.trackDrag(forMouseDownEvent: event, in: source)
        }
    }

    public override func draggingExited(_ sender: NSDraggingInfo?) {
        interiorDrag = false
        guard case .target = dragState else { return }
        dragState = .source
    }

    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        interiorDrag = true
        dragState = .idle
        return super.draggingEntered(sender)
    }

    public override func draggingEnded(_ sender: NSDraggingInfo?) {

        guard case .target = dragState else { return }
        dragState = .idle
    }

    override init(frame: NSRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    private func commonInit() {
        wantsLayer = true
        registerForDraggedTypes([NSPasteboard.PasteboardType.string])
    }

}

class DragHandler: NSView, DragTerminal {

    weak var parent: PanelViewController?
    weak var container: PanelSplitContainerController?

    var dragState: State = State.idle { didSet { needsLayout = true } }

    var updateDragAction: (NSPoint?) -> Void = { _ in }

    func dragFinished() {
        // nothin' yet
    }

    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
//        print("entered \(sender.draggingSource())")
        guard case .idle = dragState else { return [] }
        guard (sender.draggingSource as? ConnectionDragController)?.sourceEndpoint != nil else { return [] }
        dragState = .target
        return sender.draggingSourceOperationMask
    }

    public override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        let point = self.convert(sender.draggingLocation, from: nil)
//        print("\(self), \(point)")
        updateDragAction(point)
        return super.draggingUpdated(sender)
    }

    public override func draggingExited(_ sender: NSDraggingInfo?) {
        updateDragAction(nil)
        guard case .target = dragState else { return }
        dragState = .idle
    }

    public override func draggingEnded(_ sender: NSDraggingInfo?) {
        updateDragAction(nil)
        guard case .target = dragState else { return }
        dragState = .idle
    }

    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let controller = sender.draggingSource as? ConnectionDragController else { return false }
        let point = self.convert(sender.draggingLocation, from: nil)
        let abutment = getSelectedAbutment(at: point)
        controller.connect(to: self, at: abutment)
        return true
    }

    convenience init(frame: NSRect = .zero, container: PanelSplitContainerController) {
        self.init(frame: frame)
        self.container = container

    }

    override init(frame: NSRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    private func commonInit() {
        wantsLayer = true
        registerForDraggedTypes([NSPasteboard.PasteboardType.string])
    }

    override var intrinsicContentSize: CGSize { return CGSize(width: 80, height: 80) }

    func getSelectedAbutment(at point: NSPoint) -> PanelAbutment {

        let p = point
        let f = self.frame

        if p.x < f.minX + 20 { return .left(.interior) }
        if p.x > f.maxX - 20 { return .right(.interior) }
        if p.y < f.minY + 20 { return .bottom(.interior) }
        if p.y > f.maxY - 20 { return .top(.interior) }

        return .none
    }

}
