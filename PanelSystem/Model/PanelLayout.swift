//
//  PanelLayout.swift
//  PanelSystem
//
//  Created by Jacob Martin on 2/24/18.
//  Copyright © 2018 JJ Martin. All rights reserved.
//

import Foundation

protocol DockableModel {
    
}

enum PanelOrientation {
    case horizontal
    case vertical
}

struct PanelViewModel: DockableModel {
    var name: String
    
    var panel: Panel {
        return .view(self)
    }
}

enum Panel {
    case layouts([Panel], PanelOrientation)
    case view(PanelViewModel)
}

extension Panel {
    func window()  {
    }
    
    func controller() -> NSViewController {
        switch self {
        case .layouts(let panels, let orientation):
            let container = PanelSplitContainerController()
            container.setup(with: panels.map { p in
                   let c = p.controller()
                if let view = c as? PanelViewController {
                    view.parentContainer = container
                }
                return c
            }, orientation: orientation)
            return container
        case .view(let view):
            return PanelViewController()
        }
    }
}


func testPanel() -> Panel {
    let panelsA:[Panel] = [PanelViewModel(name:"A").panel, PanelViewModel(name:"B").panel, PanelViewModel(name:"C").panel]
    let pA:Panel = .layouts(panelsA, .horizontal)
    
    let panelsB:[Panel] = [PanelViewModel(name:"A").panel, PanelViewModel(name:"B").panel]
    let pB:Panel = .layouts(panelsB, .horizontal)
    
    let panelsC:[Panel] = [PanelViewModel(name:"A").panel, PanelViewModel(name:"B").panel, PanelViewModel(name:"C").panel]
    let pC:Panel = .layouts(panelsA, .horizontal)
    
    let P:Panel = .layouts([pA, pB, pC], .vertical)
    
    return P
}
