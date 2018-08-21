//
//  ViewController.swift
//  Bresenham-Line
//
//  Created by Cirno MainasuK on 2017-3-17.
//  Copyright © 2017年 Cirno MainasuK. All rights reserved.
//

import Cocoa
import EasyImagy


class CMKViewController: NSViewController {

    @IBOutlet weak var circlePointsLabel: NSTextField!
    
    @IBOutlet weak var mouseLocationLabel: NSTextField! {
        didSet { mouseLocationLabel.font = NSFont.monospacedDigitSystemFont(ofSize: mouseLocationLabel.font!.pointSize, weight: NSFontWeightRegular) }
    }

    static let kPenTipWidth: Int = 2 * 5

    var points:[CGPoint] = []{
        didSet { circlePointsLabel.stringValue = points.debugDescription
            
            dump(points)
        }
    }
    var mouseLocation: NSPoint = NSPoint() {
        didSet { mouseLocationLabel.stringValue = mouseLocation.debugDescription }
    }

    var isDebug = true {
        didSet { penTipView.isHidden = !isDebug }
    }

    lazy var penTipView: NSView = {
        let view = NSView(frame: NSRect(origin: CGPoint.zero, size: CGSize(width: kPenTipWidth, height: kPenTipWidth)))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.red.cgColor
        view.layer?.cornerRadius = CGFloat(kPenTipWidth / 2)

        return view
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Just assert the width is a multiple of 2
        assert(type(of: self).kPenTipWidth % 2 == 0)
        view.addSubview(penTipView, positioned: .above, relativeTo: view)

        // Comment it to debug mouse track
        isDebug = false
        
        test()
    }
    
    func test(){
        // Add test image
        let image = Image<RGBA<UInt8>>(nsImage: NSImage(named: "fast_1.png")!)

        let testImage = NSImage(named: "fast_1.png")!
        let testIV = NSImageView(image: testImage)
        testIV.frame = CGRect(x:0,y:0,width:image.width, height:image.height)
        self.view.addSubview(testIV)
        
        
        
        
        let testView = TestView()
        testView.frame = CGRect(x:0,y:0,width:image.width, height:image.height)
        self.view.addSubview(testView)
        
        
        
        let points = Bresenham.pointsAlongCircle(xc: 0, yc: 0, r: 3)
        print("points:",points)
        
        // Gaussian Filter
        let kernel = Image<Int>(width: 5, height: 5, pixels: [
            1,  4,  6,  4, 1,
            4, 16, 24, 16, 4,
            6, 24, 36, 24, 6,
            4, 16, 24, 16, 4,
            1,  4,  6,  4, 1,
            ]).map { Float($0) / 256.0 }
        let newImage = image.convoluted(with: kernel)
//
//
        
        let fast = FAST()
        let cnrs = fast.findCorners(image: newImage, threshold: 40)
        testView.myPixels = cnrs
        
    }
    

}



extension CMKViewController: CMKMouseTrackDelegate {

    func mouseMoved(with position: NSPoint) {
        let point = position.integral()
        let width = penTipView.bounds.width

        mouseLocation = NSPoint(x: point.x, y: point.x)
        data.view?.redCirclePoints = Bresenham.pointsAlongCircle(xc: Int(point.x), yc: Int(point.y), r: 4)
        penTipView.frame.origin = CGPoint(x: point.x - width / 2.0, y: point.y - width / 2.0)
        view.setNeedsDisplay(penTipView.frame)
    }
    
}

extension CMKViewController {

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        let point = event.locationInWindow.integral()
        mouseLocation = NSPoint(x: point.x, y: point.y)
    }
}
