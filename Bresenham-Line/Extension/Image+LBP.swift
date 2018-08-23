import EasyImagy
import Foundation

//typealias <#type name#> = <#type expression#>
func step(_ lhs:UInt8,_ rhs:UInt8)->UInt8{
    if lhs > rhs{
        return 1
    }else{
        return 0
    }
}


extension UInt8 {
    
    var toBinaryString: String {
        return String(self, radix: 2)
    }
    var toHexaString: String {
        return String(self, radix: 16)
    }
    
}

extension Image where Pixel == UInt8 {
    //or Pixel == RGBA<UInt32> 
    
    public func OLPB()->[UInt8]{
        var histogram :[UInt8] = []

        for x in 1...self.xRange.upperBound - 1{
            for y in 1...self.yRange.upperBound - 1{
                let olbp = OLBPat(x: x, y: y)
                histogram.append(olbp)
            }
        }
        return histogram
    }
    
  
    //Original LBP
    // https://github.com/carolinepacheco/lbplibrary/tree/master/package_lbp/olbp
    public func OLBPat(x: Int, y: Int)->UInt8{

        if(x == 0 || y == 0) {
          return 0
        }
        if(x >= self.xRange.upperBound - 1 || y >= self.yRange.upperBound - 1){
          return 0
        }
        
        let centerIntensity = self[x,y]
        let bottomLeftIntensity  = self[x-1,y-1]
        let leftIntensity        = self[x-1, y]
        let topLeftIntensity     = self[x-1, y+1]
        let topIntensity         = self[x+0, y+1]
        let topRightIntensity    = self[x+1,y+1]
        let rightIntensity       = self[x+1, y]
        let bottomRightIntensity = self[x+1, y-1]
        let bottomIntensity      = self[x+0, y-1]

        var code:UInt8 = 0
        code |= step(centerIntensity, bottomLeftIntensity) << 7
        code |= step(centerIntensity,  leftIntensity ) << 6
        code |= step(centerIntensity,topLeftIntensity ) << 5
        code |= step(centerIntensity,topIntensity ) << 4
        code |= step(centerIntensity,topRightIntensity) << 3
        code |= step(centerIntensity, rightIntensity) << 2
        code |= step(centerIntensity, bottomRightIntensity) << 1
        code |= step(centerIntensity, bottomIntensity) << 0
        
//        print("code:",code.toBinaryString)
  
        return code
    }
}
