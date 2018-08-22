import Foundation
import EasyImagy

/**
 * FAST intends for "Features from Accelerated Segment Test". This method
 * performs a point segment test corner detection. The segment test
 * criterion operates by considering a circle of sixteen pixels around the
 * corner candidate p. The detector classifies p as a corner if there exists
 * a set of n contiguous pixelsin the circle which are all brighter than the
 * intensity of the candidate pixel Ip plus a threshold t, or all darker
 * than Ip − t.
 *
 * x   x 15 00 01 x   x
 * x  14          02
 * 13                03
 * 12       []       04
 * 11                05
 *    10          06
 *       09 08 07
 *
 * For more reference:
 * http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.60.3991&rep=rep1&type=pdf
 */




extension Image{
    //WARNING - Using Bresenham octants instead of FAST to allow increase of radius
    /*
     Octants:
     \2|1/
     3\|/0
     ---+---
     4/|\7
     /5|6\
     */
    //      let pts = Bresenham.pointsAlongCircle(xc: 0, yc: 0, r: 3)
    //      X -> your point
    //        let circle pixels =
    //            [
    //            0 ,0, 1, 1, 1, 0, 0,
    //            0, 1, 0, 0, 0, 1, 0,
    //            1, 0, 0, 0, 0, 0, 1,
    //            1, 0, 0, [], 0, 0, 1,
    //            1, 0, 0, 0, 0, 0, 1,
    //            0, 1, 0, 0, 0, 1, 0,
    //            0, 0, 1, 1, 1, 0, 0,
    //            ]
    //            )
    //
    //    }
}

class FAST{
    
    // at radius 3 -> at point x,y -> give me surrounding pixels
    static var gridCircle = Dictionary<CGPoint,[CGPoint]>()


    // FindCorners - Finds corners coordinates on the graysacaled image.
    func findCorners(image:Image<RGBA<UInt8>>,  threshold:Int)-> [CGPoint] {
        
        print("GRAY SCALING BEGIN")
        let grayScaleImage = image.map { $0.gray }
        print("GRAY SCALING END")
        
        var corners :[CGPoint] = []
      
        
        print("BEGIN")  // TODO calculate this offline / save to nsdefaults
        // When looping through the image pixels, skips the first three lines from
        // the image boundaries to constrain the surrounding circle inside the image
        // area.
        let iRange = image.width   - 4
        let jRange = image.height - 4
       
        var circleGrid = Dictionary<CGPoint,[CGPoint]>() // given a point as key -> return surrounding pixels values
        for i in 3...iRange {
            for  j in  3...jRange {
                let pt = CGPoint(x: i, y: j)
                circleGrid[pt] =  Bresenham.pointsAlongCircle(pt:pt, r: 3)
            }
        }

        print("END")
        for ptKey in circleGrid.keys{
            
            let i = Int(ptKey.x)
            let j = Int(ptKey.y)
            
            if let  surroudingPixelPoints = circleGrid[ptKey]{ // 16 points
                
                // Dig up the respective grayscale values for surrounding pixels
                var circlePixels: [UInt8] = []
                for pt in surroudingPixelPoints{
                    let cp = grayScaleImage[Int(pt.x), Int(pt.y)]
                    circlePixels.append(cp)
                }
                
                
                let p = Int(image[i, j].gray)
                if isCorner(p, circlePixels, threshold) {
                    //The pixel p is classified as a corner, as optimization increment j by the circle radius 3 to skip the neighbor pixels inside the surrounding circle. This can be removed without compromising the result.
                    let corner = CGPoint(x:i,y:image.height-j)
                    corners.append(corner)
                    //                    j += r //TODO restore skip
                }
            }
            
            
        }
        
        

        
        return corners
    }
    //
    
    
    /**
     * Checks if the circle pixel is within the corner of the candidate pixel p
     * by a threshold.
     */
    func isCorner(_ p:Int,_ circlePixels:[UInt8],_ threshold:Int)-> Bool {
        if isTriviallyExcluded(circlePixels, p, threshold) {
            return false
        }
        
        for x in 0...15{
            var darker = true
            var brighter = true
            
            for y in 0...8 {
                let idx = (x+y)&15 //???
                if (idx >= circlePixels.count){
                    continue
                }
                
                let circlePixel = Int(circlePixels[idx])
                
                if !isBrighter(p, circlePixel, threshold) {
                    brighter = false
                    if !darker {
                        break
                    }
                }
                
                if !isDarker(p, circlePixel, threshold) {
                    darker = false
                    if !brighter {
                        break
                    }
                }
            }
            
            if brighter || darker {
                return true
            }
        }
        
        return false
    }
    
    /**
     * Fast check to test if the candidate pixel is a trivially excluded value.
     * In order to be a corner, the candidate pixel value should be darker or
     * brighter than 9-12 surrounding pixels, when at least three of the top,
     * bottom, left and right pixels are brighter or darker it can be
     * automatically excluded improving the performance.
     */
    func isTriviallyExcluded(_ surroudingPixelPoints:[UInt8], _ p :Int,_ threshold :Int)-> Bool {
        var count = 0
        let circleBottom = Int(surroudingPixelPoints[8])
        let circleLeft = Int(surroudingPixelPoints[12])
        let circleRight = Int(surroudingPixelPoints[4])
        let circleTop = Int(surroudingPixelPoints[0])
        
        if isBrighter(circleTop, p, threshold) {
            count += 1
        }
        if isBrighter(circleRight, p, threshold) {
            count += 1
        }
        if isBrighter(circleBottom, p, threshold) {
            count += 1
        }
        if isBrighter(circleLeft, p, threshold) {
            count += 1
        }
        
        if count < 3 {
            count = 0
            if isDarker(circleTop, p, threshold) {
                count += 1
            }
            if isDarker(circleRight, p, threshold) {
                count += 1
            }
            if isDarker(circleBottom, p, threshold) {
                count += 1
            }
            if isDarker(circleLeft, p, threshold) {
                count += 1
            }
            if count < 3 {
                return true
            }
        }
        
        return false
    }
    
    /**
     * Checks if the circle pixel is brighter than the candidate pixel p by
     * a threshold.
     */
    func isBrighter(_ circlePixel :Int, _ p :Int, _ threshold :Int)->Bool {
        return circlePixel-p > threshold
    }
    
    /**
     * Checks if the circle pixel is darker than the candidate pixel p by
     * a threshold.
     */
    func isDarker(_ circlePixel :Int, _ p :Int, _ threshold :Int) ->Bool {
        return p-circlePixel > threshold
    }
    
    
}

