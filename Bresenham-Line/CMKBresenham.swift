//
//  Created by Cirno MainasuK on 2017-3-17.
//  Copyright © 2017年 Cirno MainasuK. All rights reserved.
//


import Foundation
import Cocoa


typealias BresenhamLine = (from: CGPoint, to: CGPoint)


struct BGPoint{
    var point  = CGPoint()
    var _octant = -1
    var octant: Int  {
        get {
            return _octant
        }
        set { _octant = newValue }
    }
    
    public init(x:CGFloat,y:CGFloat,o:Int){
        point.x = x
        point.y = y
        _octant = octant
    }
}


class Bresenham:NSObject{
    
    class func pointsAlongLineBresenham(_ line: BresenhamLine)->[CGPoint] {
        consolePrint("Draw bresenham line from \(line.0) to \(line.1)")
        var result: [CGPoint] = []
        guard !line.from.equalTo(line.to) else { return []}
        
        var dx = abs(Int(line.to.x - line.from.x))
        var dy = abs(Int(line.to.y - line.from.y))
        let xSign = Int(line.to.x - line.from.x).sign()
        let ySign = Int(line.to.y - line.from.y).sign()
        
        // Swap dx, dy
        var isSwap = false
        if dy > dx {
            (dx, dy) = (dy, dx)
            isSwap = true
        }
        var e = 2 * dy - dx
        
        var x = Int(line.from.x)
        var y = Int(line.from.y)
        
        for _ in 0...dx {
            let pt = CGPoint(x: x, y:y)
            result.append(pt)
            
            if e >= 0 {
                if isSwap   { x += xSign }
                else        { y += ySign }
                
                // if e >= 0, then minus 2dx
                e -= 2 * dx
            }
            
            if isSwap   { y += ySign }
            else        { x += xSign }
            
            // always plus 2dy
            e += 2 * dy
        }
        return result.unique()
    }
    

    // https://en.wikipedia.org/wiki/Midpoint_circle_algorithm
    class func pointsAlongMidPoint( xc:Int,  yc:Int,  r:Int)-> [CGPoint]{
        var  x = 0
        var  y = r
        var  d = 1 -  r
        var result: [CGPoint] = []
        
        while(x <= y){
            x = x + 1
            if(d < 0){
              d = d + 2 * x + 1
            } else{
                y = y - 1;
                d = d + 2 * (x - y) + 1
            }
            
            for octant in 0...7{
                var x1:Int, y1:Int;
                (x1, y1) = switchFromOctantZeroTo(octant:octant,x:x,y:y)
                result.append(CGPoint(x:xc + x1,y:yc + y1))
            }
            
        }
        return result.unique()
        
    }
    
    
    class func  pointsAlongCircle( pt:CGPoint,  r:Int)-> [CGPoint]
    {
        return Bresenham.pointsAlongCircle(xc:Int(pt.x),yc:Int(pt.y),r:r)
    }
    
    class func  pointsAlongCircle( xc:Int,  yc:Int,  r:Int)-> [CGPoint]
    {
        var  x = 0
        var  y = r
        var  d = 3 - 2 * r
        
        var result: [CGPoint] = []
        
        while(x <= y)
        {
            for octant in 0...7{
                var x1:Int, y1:Int;
                (x1, y1) = switchFromOctantZeroTo(octant:octant,x:x,y:y)
                result.append(CGPoint(x:xc + x1,y:yc + y1))
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
    
    
    

    class func  pointsForOctants( xc:Int,  yc:Int,  r:Int,octants:[Int])-> [CGPoint]
    {
        let radialRange:[Int] = Array(0...r)
        var pts:[CGPoint]  = []
        if(radialRange.count > 0){
            pts =  pointsForOctants(xc:xc,yc:yc,
                                    radialRange:radialRange,
                                    octants:octants)
        }
        
        return pts.unique()
    }
    
    class func  pointsForOctants( xc:Int,  yc:Int,  radialRange:[Int],octants:[Int])-> [CGPoint]
    {
        var  r = radialRange.last!
        var result: [CGPoint] = []
        
        while(r > 0){
            var  x = 0
            var  y = r
            var  d = 3 - 2 * r
        
            while(x <= y)
            {
                // all 8 octants
                // https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
                for octant in octants{
                    var x1:Int, y1:Int;
                    (x1, y1) = switchFromOctantZeroTo(octant:octant,x:x,y:y)
                    result.append(CGPoint(x:xc + x1,y:yc + y1))
                }
                
                if (d < 0){
                    d = d + 4*x + 6;
                } else {
                    d = d + 4*(x-y) + 10;
                    y = y-1;
                }
                x = x + 1;
            }
            if (radialRange.first! < r){
                r -= 1
            }else{
                break
            }
            
        }
        
        return result.unique()
    }


    /*
     Octants:
     \2|1/
     3\|/0
     ---+---
     4/|\7
     /5|6\
     */
    
    class func switchFromOctantZeroTo(octant:Int, x:Int, y:Int)->(x:Int,y:Int){
        
        switch(octant){
        case 0: return (x, y)
        case 1: return (y, x)
        case 2: return (-y, x)
        case 3: return (-x, y)
        case 4: return (-x, -y)
        case 5: return (-y, -x)
        case 6: return (y, -x)
        case 7: return (x, -y)
        default:
            return (x, y)
        }
        
       
    }
 
    
}
    

