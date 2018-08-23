//
//  WindowViewController.swift
//  Bresenham-Line
//
//  Created by Cirno MainasuK on 2017-3-17.
//  Copyright © 2017年 Cirno MainasuK. All rights reserved.
//

import Cocoa

class CMKWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        guard let controller = contentViewController as? CMKViewController,
            let window = window as? CMKWindow else {
            return
        }

        window.mouseTrackdelegate = controller
        window.acceptsMouseMovedEvents = true
    }
    
}
