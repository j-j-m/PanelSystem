//
//  ConnectionDragController.swift
//  PanelSystem
//
//  Created by Jacob Martin on 2/23/18.
//  Copyright © 2018 JJ Martin. All rights reserved.
//

import AppKit

class ConnectionDragController: NSObject, NSDraggingSource {

    var sourceEndpoint: DragEndpoint?

    func connect(to target: DragTerminal, at abutment: PanelAbutment) {
        Swift.print("Connect \(sourceEndpoint!) to \(target) at \(abutment)")
        if let source = sourceEndpoint?.parent, let destinaton = target.parent {
            source.dockRelative(to: destinaton, at: abutment)
        }
    }

    func trackDrag(forMouseDownEvent mouseDownEvent: NSEvent, in sourceEndpoint: DragEndpoint) {
        self.sourceEndpoint = sourceEndpoint

        guard let pbItem = NSPasteboardItem(pasteboardPropertyList: "\(view)", ofType: .string),
        let endpointView = sourceEndpoint as? NSView else { return }
        let item = NSDraggingItem(pasteboardWriter: pbItem)
        let session = endpointView.beginDraggingSession(with: [item], event: mouseDownEvent, source: self)
        session.animatesToStartingPositionsOnCancelOrFail = false
    }

    func draggingSession(_ session: NSDraggingSession,
                         sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        switch context {
        case .withinApplication: return .generic
        case .outsideApplication: return []
        }
    }

    func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
        sourceEndpoint?.dragState = .source
        //        lineOverlay = LineOverlay(startScreenPoint: screenPoint, endScreenPoint: screenPoint)
    }

    func draggingSession(_ session: NSDraggingSession, movedTo screenPoint: NSPoint) {
        //        lineOverlay?.endScreenPoint = screenPoint
    }

    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        //        lineOverlay?.removeFromScreen()
        //        sourceEndpoint?.dragState = .idle
        sourceEndpoint?.dragFinished()
    }

    func ignoreModifierKeys(for session: NSDraggingSession) -> Bool { return true }
    //    private var lineOverlay: LineOverlay?
}
