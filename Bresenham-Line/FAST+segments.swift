import Foundation
import EasyImagy


extension FAST{

    // at radius 3 -> at point x,y -> give me surrounding pixels
    static var radiusSegmentGridCircle = Dictionary<Int,Dictionary<CGPoint,[SegPoint]>>()
    
    // FindCorners - Finds corners coordinates on the graysacaled image.
    func findLines(image:Image<RGBA<UInt8>>,  threshold:Int)-> [CGPoint] {
        
        
        
        print("GRAY SCALING BEGIN")
        let grayScaleImage = image.map { $0.gray }
        print("GRAY SCALING END")
        
        
        var corners :[CGPoint] = []
        let r = 3
        
        print("BEGIN EXPENSIVE PRE-CALCULATION")  // TODO calculate this offline / save to nsdefaults
        // When looping through the image pixels, skips the first three lines from
        // the image boundaries to constrain the surrounding circle inside the image
        // area.
        let iRange = image.width   - (r+1)
        let jRange = image.height - (r+1)
        
        let adhocRadius = [3] // ,15,30,45 increase in radius works similar to blur function but allows more precision
        
        
        for radius in adhocRadius {
            var circleGrid = Dictionary<CGPoint,[SegPoint]>() // given a point as key -> return surrounding pixels values
            for i in radius...iRange { // 3 -> width - 4
                for  j in  radius...jRange { // 3 -> height - 4
                    let pt = CGPoint(x: i, y: j)
                    circleGrid[pt] =  Bresenham.segmentPointsAlongCircle(pt:pt, r: radius)
                }
            }
            
            FAST.radiusSegmentGridCircle[r] = circleGrid // cache dictionary by radius
        }
        
        
        print("END")
        
        // IDEAS
        
        // given a selection of values
        // circleGrid.keys.count ~ 160,000 keys x 16 surrounding pixels
        var skip = false
        var skipCount = 0
        if var circleGrid = FAST.radiusSegmentGridCircle[r]{
            for ptKey in circleGrid.keys{
                if (skip) {
                    if (skipCount != r){
                        skipCount += 1
                        continue
                    }else{
                        skipCount = 0
                        skip = false
                    }
                }
                
                let i = Int(ptKey.x)
                let j = Int(ptKey.y)
                
                if let  surroudingPixelSegments = circleGrid[ptKey]{ // 16 points
                    
                    // Dig up the respective grayscale values for surrounding pixels
                    var circlePixels: [UInt8] = []
                    
                    // local binary pattern / will incur performance hit for digging up all the surrounding data.
                    var circleLBP: [UInt8] = []
                    
                    for seg in surroudingPixelSegments{
                        let cp = grayScaleImage[seg.x, seg.y]
                        let lbp = grayScaleImage.OLBPat(x: seg.x, y: seg.y)
                        circleLBP.append(lbp)
                        circlePixels.append(cp)
                    }
                    
                    
                    let p = Int(image[i, j].gray)
                    if isCorner(p, circlePixels, threshold) {
                        //The pixel p is classified as a corner, as optimization increment j by the circle radius 3 to skip the neighbor pixels inside the surrounding circle. This can be removed without compromising the result.
                        let corner = CGPoint(x:i,y:image.height-j)
                        corners.append(corner)
                        skip = true
                    }
                }
            }
        }
        
        
        
        return corners
    }
}

