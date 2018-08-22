//
//  NSPoint.swift
//  Bresenham-Line
//
//  Created by Cirno MainasuK on 2017-3-17.
//  Copyright © 2017年 Cirno MainasuK. All rights reserved.
//

import Cocoa

extension NSPoint {

    func integral() -> NSPoint {
        return NSPoint(x: Int(self.x + 0.5), y: Int(self.y + 0.5))
    }

}

extension CGPoint {
    func isInsidePolygon(vertices: [CGPoint]) -> Bool {
        guard !vertices.isEmpty else { return false }
        var j = vertices.last!, c = false
        for i in vertices {
            let a = (i.y > y) != (j.y > y)
            let b = (x < (j.x - i.x) * (y - i.y) / (j.y - i.y) + i.x)
            if a && b { c = !c }
            j = i
        }
        return c
    }
}
