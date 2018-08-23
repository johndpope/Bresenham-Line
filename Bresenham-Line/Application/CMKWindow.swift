//
//  CMKWindow.swift
//  Bresenham-Line
//
//  Created by Cirno MainasuK on 2017-3-17.
//  Copyright © 2017年 Cirno MainasuK. All rights reserved.
//

import Cocoa

class CMKWindow: NSWindow {

    weak var mouseTrackdelegate: CMKMouseTrackDelegate?
    
    override func mouseMoved(with event: NSEvent) {
        mouseTrackdelegate?.mouseMoved(with: event.locationInWindow)
    }
    
}
