import Cocoa
import EasyImagy
import Foundation
import Surge
import QuartzCore



extension CMKViewController {
    
    enum trainingKind{
        case binned
        case gaussian
        case scaled
        case cossin
    }
    
    
    func generateTrainingImage(_ angle:Double,_ width:Int,_ height:Int,_ thickness:Double)->Image<RGBA<UInt8>>{
        var image = Image<RGBA<UInt8>>(width: width, height: height, pixel: RGBA.transparent)
        
        let x_0 = Double(width / 2) + 1
        let y_0 = Double(height / 2) + 1
        let c = cos(angle)
        let s  = sin(angle)
        for y in 0..<height{
            for x in 0..<width{
                let w1 = abs((Double(x)-x_0)*c + (Double(y)-y_0)*s)
                let h1 = -(Double(x)-x_0)*s + (Double(y)-y_0)*c
                if (w1 < Double(thickness / 2) && h1  > 0){
                    image[x,y] = RGBA(red: 255, green: 0, blue: 0, alpha: 127)
                }
            }
        }

        return image
    }
    
    

    func testAndTrainData(){
        
        print("BEGIN TEST AND TRAIN DATA")
        let width = 101 // Image width
        let height = 101 // Image heigth
        // TOTAL NEURONS 10201 = 101 x 101
        let thickness:Double = 1.0 // Line thickness

        let numTrain = 10
        let numTest = 10
        var testImages:[[Byte]] = []
        var testAngles:[Double] = []
        var trainImages:[[Byte]] = []
        var trainAngles:[[Double]] = []
        
        
        for _ in 0..<numTrain{

            let angle:Double = .pi * .random(in: 0..<1)
            //https://stats.stackexchange.com/questions/218407/encoding-angle-data-for-neural-network
            let encodedAngle = encodeAngle(angle,.binned) /// 1 -> 500 array 1 hot vector 000000000100000
//            let encodedAngle = encodeAngle(angle,"gaussian") // FAILS HARD
//             let encodedAngle = encodeAngle(angle,"scaled")
//              let encodedAngle = encodeAngle(angle,"cossin")
//            print("encodedAngle:",encodedAngle)
            trainAngles.append(encodedAngle)
            let image = generateTrainingImage(angle,width,height,thickness)
            let grayscale: Image<UInt8> = image.map { $0.gray }
            trainImages.append(grayscale.byteArray())
        }
        
        
        for _ in 0..<numTest{

            let angle:Double = .pi * .random(in: 0..<1)
            testAngles.append(angle)
            let image = generateTrainingImage(angle,width,height,thickness)
              let grayscale: Image<UInt8> = image.map { $0.gray }
            testImages.append(grayscale.byteArray())
        }
        

        let trainImageData = trainImages.map{ return $0.map{ return   Double($0) / 255 }}
        
        do{
          

            let network = Network(layerStructure: [10201,500,1], activationFunction: sigmoid, derivativeActivationFunction: derivativeSigmoid, learningRate: 0.006, hasBias: true)
            
            network.train(inputs: trainImageData, expecteds: trainAngles, printError: true)
            let testImageData = testImages.map{ return $0.map{ return   Double($0) / 255 }}
            let (_, _, percentage) = network.validate(inputs: testImageData, expecteds: testAngles, accuracy: 0.95)
            print( "Accuracy: \(percentage * 100)%")
            
            Storage.store(network, to: .documents, as: "network.json")
              let savedNetwork = Storage.retrieve("network.json", from: .documents, as: Network.self)
        }
        catch{
            print("FAILED")
        }
     
        
    }
    
    // Returns encoded angle using specified method ("binned","scaled","cossin","gaussian")
    func encodeAngle(_ angle:Double,_ method:trainingKind)->[Double]{
        var X:[Double] = []
        if (method == .binned){ // 1-of-500 encoding
            X = [Double](repeating: 0, count: 500 )
            X[Int(round(250*(angle/Double.pi + 1)))%500] = 1
        }else if (method == .gaussian){ // Leaky binned encoding
            for i in 0..<500{
                X.append( Double(i))
            }
            
            let piArray = Array(repeating:-Double.pi ,count:500)
            let idx = Array(repeating:250*(angle/Double.pi + 1),count:500)

            let squared  = pow(mul(piArray,sub(X,idx )), 2)
            X = Surge.exp(squared)
            print("X:",X)
            
        }else if (method == .scaled){ // Scaled to [-1,1] encoding
            X = Array([angle/Double.pi])
        }else if (method == .cossin){ //Oxinabox's (cos,sin) encoding
            X = Array([cos(angle),sin(angle)])
        }
        return X
    }
    
    
    // Returns decoded angle using specified method
    func decodeAngle(_ X:[Double],_ method:trainingKind)->Double{
        var M:Double = 0
        var angle:Double = 0
        if (method == .binned) || (method == .gaussian){ // 1-of-500 or gaussian encoding
            M = X.max()!
            for i in 0...X.count{
                if abs(X[i]-M) < 1e-5{
                    angle = Double.pi*Double(i/250) - Double.pi
                }
            }
            // angle = pi*dot(array([i for i in range(500)]),X)/500  # Averaging
        } else if (method == .scaled){ // Scaled to [-1,1] encoding
            angle = Double.pi*X[0]
        }else if (method == .cossin){ //# Oxinabox's (cos,sin) encoding
            angle = atan2(X[1],X[0])
        }
        return angle
    }

    
    
    
    func test(){
        // Add test image
        let image = Image<RGBA<UInt8>>(nsImage: NSImage(named: "fast_1.png")!)
        
        print("image.xRange:",image.xRange)
        let testImage = NSImage(named: "fast_1.png")!
        let testIV = NSImageView(image: testImage)
        testIV.frame = CGRect(x:0,y:0,width:image.width, height:image.height)
        self.view.addSubview(testIV)
        
        
        
        
        let testView = TestView()
        testView.frame = CGRect(x:0,y:0,width:image.width, height:image.height)
        self.view.addSubview(testView)
        
        
        
        let points = Bresenham.pointsAlongCircle(xc: 0, yc: 0, r: 3)
        print("points:",points)
        
        
    }
    
    
}



