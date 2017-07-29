//
//  CMKView.swift
//  Bresenham-Line
//
//  Created by Cirno MainasuK on 2017-3-17.
//  Copyright © 2017年 Cirno MainasuK. All rights reserved.
//

import Cocoa

class CMKView: NSView {

    typealias Line = BresenhamLine

    var lines = [Line]()
    var currentLine: Line?

    var runOnce = false
    var circlePoints:[CGPoint] = []
    var circleMidPoints:[CGPoint] = []
    var octantPoints:[CGPoint] = []
    var crossHairPoints:[CGPoint] = []

    // Optimize the rendering
    override var isOpaque: Bool {
        return true
    }

    func randomArcs(){
        // Arcs + octants
        octantPoints.removeAll()
        var x = Int.rand(1000)
        var y = Int.rand(1000)
        var r = 4
        
        var idx = 0
        while(true){
            
            
            if(octantPoints.count > 100000){
                break
            }
            let arcs = [Int.rand(8),Int.rand(8),Int.rand(8),Int.rand(8),Int.rand(8),Int.rand(8),Int.rand(8)]
            let pts = Bresenham.pointsAlongCircle(xc: x, yc: y, r:r,octants: arcs)
            octantPoints.append(contentsOf: pts)
            
            if (idx>Int.rand(100)){
                break
            }
            r = r*2
            idx += 1
            
            // break out into another circle
            let randomBreakout = Int.rand(400)
            if (r>2^randomBreakout){
                crossHairPoints.append(CGPoint(x:x,y:y))
                if (pts.count>0){
                    let randomIndex = Int.rand(pts.count)
                    let pt = pts[randomIndex]
                    x = Int(pt.x)
                    y = Int(pt.y)
                    r = 4
                }
            }
        }
    }
    func preCalculateCirclePoints(){
        for i in 0...2{
            let pts = Bresenham.pointsAlongCircle(xc: 0, yc: 0, r: i*150)
            circlePoints.append(contentsOf: pts)
        }
        
        for i in 0...3{
            let pts = Bresenham.pointsAlongMidPoint(xc: 300, yc: 300, r: i*80)
            circleMidPoints.append(contentsOf: pts)
        }
        
       

    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        Swift.print("")
        Swift.print("----- Drawing -----")

        guard let context: CGContext = NSGraphicsContext.current()?.cgContext else {
            consolePrint("Cannot get graphics context")
            return
        }

        if (!runOnce){
            runOnce = true
            preCalculateCirclePoints()
        }
        
        // Fill background to white
        context.setFillColor(.white)
        context.fill(bounds)
        context.setFillColor(NSColor.red.cgColor)

       
        // Draw lines
        for line in lines {
           let pts =  Bresenham.pointsAlongLineBresenham(line)
            context.fillPixels(pts)
        }

        if let currentLine = currentLine {
           let pts =  Bresenham.pointsAlongLineBresenham(currentLine)
            context.fillPixels(pts)
        }
        
        
        context.setFillColor(NSColor.lightGray.cgColor)
        
        // Draw circle
        context.fillPixels(circlePoints)
        
        // Mid point algorithm
        context.fillPixels(circleMidPoints)
        
        // octant random arc segments
        context.setFillColor(NSColor.black.cgColor)
        context.fillPixels(octantPoints)
        
        context.drawCrossHair(pts: crossHairPoints)
    }

}



