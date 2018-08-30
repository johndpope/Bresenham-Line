import Cocoa
import EasyImagy
//import TensorFlow

class CMKViewController: NSViewController {

    @IBOutlet weak var circlePointsLabel: NSTextField!
    
    @IBOutlet weak var mouseLocationLabel: NSTextField! {
        didSet { mouseLocationLabel.font = NSFont.monospacedDigitSystemFont(ofSize: mouseLocationLabel.font!.pointSize, weight: NSFontWeightRegular) }
    }
//    var xt = Tensor<Float>([[1, 2], [3, 4]])
    
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
        let kPenTipWidth2: Int = 2 * 5
        let view = NSView(frame: NSRect(origin: CGPoint.zero, size: CGSize(width: kPenTipWidth2, height: kPenTipWidth2)))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.red.cgColor
        view.layer?.cornerRadius = CGFloat(kPenTipWidth2 / 2)

        return view
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Just assert the width is a multiple of 2
        assert(type(of: self).kPenTipWidth % 2 == 0)
        view.addSubview(penTipView, positioned: .above, relativeTo: view)

        // Comment it to debug mouse track
        isDebug = false
        
        testAndTrainData()

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
