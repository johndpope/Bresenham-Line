//
//  CMKView+Mouse.swift
//  Bresenham-Line
//
//  Created by John Pope on 7/28/17.
//  Copyright © 2017 Cirno MainasuK. All rights reserved.
//

import Foundation
import Cocoa


extension CMKView {
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        let pixel = convert(event.locationInWindow, from: nil).integral()
        currentLine = (pixel, pixel)
        
        
        setNeedsDisplay(bounds)
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        
        let pixel = convert(event.locationInWindow, from: nil).integral()
        currentLine?.to = pixel
        
        setNeedsDisplay(bounds)
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        
        let pixel = convert(event.locationInWindow, from: nil).integral()
        currentLine?.to = pixel
        currentLine.flatMap { lines.append($0) }
        
        setNeedsDisplay(bounds)
    }
    
}
