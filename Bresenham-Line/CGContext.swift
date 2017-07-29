//
//  CGContext.swift
//  Bresenham-Line
//
//  Created by John Pope on 7/29/17.
//

import Foundation
import Cocoa


extension CGContext {
    
    func drawCrossHair(pts:[CGPoint]){
        
        self.setStrokeColor(NSColor.red.cgColor)
        self.setLineWidth(5.0)
        
        self.beginPath()
        for pt in pts{
            self.move(to: pt)
            self.addLine(to:pt)
        }
        self.strokePath()
        
    }
    func fillPixels(_ pixels: [CGPoint]) {
        var size:CGSize?
        if Screen.retinaScale > 1{
            size = CGSize(width: 1.5, height: 1.5)
        }else{
            size = CGSize(width: 1.0, height: 1.0)
        }
        
        for pixel in pixels{
            fill(CGRect(origin: pixel, size: size!))
        }
    }
    
    func fill(_ pixel: CGPoint) {
        fill(CGRect(origin: pixel, size: CGSize(width: 1.0, height: 1.0)))
    }
}
