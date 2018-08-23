//
//  Created by Cirno MainasuK on 2017-3-17.
//  Copyright © 2017年 Cirno MainasuK. All rights reserved.
//


import Foundation
import Cocoa


// include octant in data structure to help training as we increase the radius of circle they should recognise potential neighbors
/*
 Octants:
 \2|1/
 3\|/0
 ---+---
 4/|\7
 /5|6\

 */
struct SegPoint{
    var point  = CGPoint()
    var _octant = -1
    var octant: Int  {
        get {
            return _octant
        }
        set {
            _octant = newValue
        }
    }
    var x: Int  {
        get {
            return Int(point.x)
        }
    }
    var y: Int  {
        get {
            return Int(point.y)
        }
    }
    
    public init(x:Int,y:Int,o:Int){
        point.x = CGFloat(x)
        point.y = CGFloat(y)
        _octant = o
    }
}
func ==(lhs: SegPoint, rhs: SegPoint) -> Bool {
    return lhs.distance(point: rhs.point) < 0.000001 //CGPointEqualToPoint(lhs, rhs)
}

extension SegPoint : Hashable {

    func distance(point: CGPoint) -> Float {
        let dx = Float(self.point.x - point.x)
        let dy = Float(self.point.y - point.y)
        return sqrt((dx * dx) + (dy * dy))
    }
    public var hashValue: Int {
        // iOS Swift Game Development Cookbook
        // https://books.google.se/books?id=QQY_CQAAQBAJ&pg=PA304&lpg=PA304&dq=swift+CGpoint+hashvalue&source=bl&ots=1hp2Fph274&sig=LvT36RXAmNcr8Ethwrmpt1ynMjY&hl=sv&sa=X&ved=0CCoQ6AEwAWoVChMIu9mc4IrnxgIVxXxyCh3CSwSU#v=onepage&q=swift%20CGpoint%20hashvalue&f=false
        return self.point.x.hashValue << 32 ^ self.point.y.hashValue
    }
}


extension Bresenham{
    class func  segmentPointsAlongCircle( pt:CGPoint,  r:Int)-> [SegPoint]
    {
        return Bresenham.segmentPointsAlongCircle(xc:Int(pt.x),yc:Int(pt.y),r:r)
    }
    
    class func  segmentPointsAlongCircle( xc:Int,  yc:Int,  r:Int)-> [SegPoint]
    {
        var  x = 0
        var  y = r
        var  d = 3 - 2 * r
        
        var result: [SegPoint] = []
        
        while(x <= y)
        {
            for octant in 0...7{
                var x1:Int, y1:Int;
                (x1, y1) = switchFromOctantZeroTo(octant:octant,x:x,y:y)
                let pt = SegPoint(x:xc + x1,y:yc + y1,o:octant)
                result.append(pt)
            }
            
            
            if (d < 0){
                d = d + 4*x + 6;
            } else {
                d = d + 4*(x-y) + 10;
                y = y-1;
            }
            x = x + 1;
        }
        return result.unique()
    }
}
