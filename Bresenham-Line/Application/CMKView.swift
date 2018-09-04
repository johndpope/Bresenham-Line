//
//  CMKView.swift
//  Bresenham-Line
//
//  Created by Cirno MainasuK on 2017-3-17.
//  Copyright © 2017年 Cirno MainasuK. All rights reserved.
//

import Cocoa

extension NSImage {
    var CGImage: CGImage {
        get {
            return self.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        }
    }
}
// DEPRECATE USE EASYIMAGY
extension NSImage {
    func getPixelColor(_ pos: CGPoint) -> NSColor {
        
        let pixelData = self.CGImage.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        //        var a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        let a = CGFloat(1.0)
        
        return NSColor(red: r, green: g, blue: b, alpha: a)
    }
}

class DataView{
    var view:CMKView?
}

let data = DataView()

class CMKView: NSView {

    typealias Line = BresenhamLine

    var lines = [Line]()
    var currentLine: Line?

    var runOnce = false
    var circlePoints:[CGPoint] = []
    var redCirclePoints:[CGPoint] = []
    var circleMidPoints:[CGPoint] = []
    var octantPoints:[CGPoint] = []

    // Optimize the rendering
    override var isOpaque: Bool {
        return true
    }

    var imageView:NSImageView?
    
    
    func preCalculateCirclePoints(){
        
        data.view = self
        // add test image


        
        
        
        for i in 0...3{
            let pts = Bresenham.pointsAlongMidPoint(xc: 300, yc: 300, r: i*80)
            circleMidPoints.append(contentsOf: pts)
        }
        
        // Arcs + octants
        let x = 0
        let y = 0
        var r = 2
        while(true){

            let pts = Bresenham.pointsForOctants(xc: x, yc: y, radialRange: Array(r...r),octants: [0,1])
            octantPoints.append(contentsOf: pts)
            if (r>1100){
                break
            }
            r = r*2
            
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

        // Fill background to white
        context.setFillColor(.white)
        context.fill(bounds)
        context.setFillColor(NSColor.red.cgColor)
        
        if (!runOnce){
            runOnce = true
            preCalculateCirclePoints()
        }
        


        // Draw red line
        context.fillPixels(redCirclePoints)
        
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
        
        // octant segments
        context.setFillColor(NSColor.blue.cgColor)
        context.fillPixels(octantPoints)
        
        
    }

}


class TestView:NSView{
    
    var myPixels:[CGPoint] = []
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context: CGContext = NSGraphicsContext.current()?.cgContext else {
            consolePrint("Cannot get graphics context")
            return
        }
        
        // Fill background to white
        context.setFillColor(.clear)
        context.fill(bounds)
        context.setFillColor(NSColor.blue.cgColor)
        
        
        // Draw pixels
        context.fillPixels(myPixels)
        
        
    }
}



extension CGContext {

    func fillPixels(_ pixels: [CGPoint]) {
        var size:CGSize?
        if Screen.retinaScale > 1{
            size = CGSize(width: 3, height: 3)
        }else{
            size = CGSize(width: 2, height: 2)
        }

        for pixel in pixels{
          fill(CGRect(origin: pixel, size: size!))
        }
    }
    
    func fill(_ pixel: CGPoint) {
        fill(CGRect(origin: pixel, size: CGSize(width: 1.0, height: 1.0)))
    }
}

