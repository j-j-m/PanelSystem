//
//  PanelLayout.swift
//  PanelSystem
//
//  Created by Jacob Martin on 2/24/18.
//  Copyright © 2018 JJ Martin. All rights reserved.
//

import Foundation

public protocol DockableModel {
    
    var name: String { get set }
    var panel: Panel { get }
}

public protocol ControllerContainer {
    var controller: PanelViewController { get }
}

public protocol DockingControllerModel: DockableModel, ControllerContainer {
    associatedtype ControllerType: PanelViewController
}

public enum PanelOrientation {
    case horizontal
    case vertical
}

public struct PanelViewModel: DockingControllerModel {
    
    public typealias ControllerType = PanelViewController
    
    public var name: String
    public var panel: Panel {
        return .view(self)
    }
    
    public var controller: PanelViewController {
        return PanelViewController()
    }
    
    public init(name: String) {
        self.name = name
    }
}

public enum Panel {
    
    case layouts([Panel], PanelOrientation)
    case view(DockableModel)
}

public extension Panel {
    func window() {}
    public func controller() -> NSViewController {
        switch self {
        case .layouts(let panels, let orientation):
            let container = PanelSplitContainerController()
            container.setup(with: panels.map { panel in
                   let c = panel.controller()
                if let view = c as? PanelViewController {
                    view.parentContainer = container
                }
                return c
            }, orientation: orientation)
            return container
        case .view(let model):
            guard let m = model as? ControllerContainer else { return PanelViewController() }
            return m.controller
        }
    }
}

/// generate test panels
///
/// - Returns: test panel
func testPanel() -> Panel {
    let panelsA: [Panel] = [PanelViewModel(name: "A"),
                            PanelViewModel(name: "B"),
                            PanelViewModel(name: "C")].map { $0.panel }
    let pA: Panel = .layouts(panelsA, .horizontal)

    let panelsB: [Panel] = [PanelViewModel(name: "A"), PanelViewModel(name: "B")].map { $0.panel }
    let pB: Panel = .layouts(panelsB, .horizontal)

    let panelsC: [Panel] = [PanelViewModel(name: "A"),
                            PanelViewModel(name: "B"),
                            PanelViewModel(name: "C")].map { $0.panel }
    let pC: Panel = .layouts(panelsC, .horizontal)

    let P: Panel = .layouts([pA, pB, pC], .vertical)
    return P
}
