import Cocoa
import EasyImagy
import Foundation
import Surge


precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator ** : ExponentiationPrecedence

func ** (_ base: Double, _ exp: Double) -> Double {
    return pow(base, exp)
}

func ** (_ base: Float, _ exp: Float) -> Float {
    return pow(base, exp)
}

extension CMKViewController {
    
    func generateTrainingImage(_ angle:Float,_ width:Int,_ height:Int,_ thickness:Double)->Image<RGBA<UInt8>>{
        var image = Image<RGBA<UInt8>>(width: width, height: height, pixel: RGBA.transparent)
        
        let x_0 = Float(width / 2)
        let y_0 = Float(height / 2)
        let c = cos(angle)
        let s  = sin(angle)
        for y in 0...height-1{
            for x in 0...width-1{
                let w1 = abs((Float(x)-x_0)*c + (Float(y)-y_0)*s)
                let h1 = -(Float(x)-x_0)*s + (Float(y)-y_0)*c
                if (w1 < Float(thickness / 2) && h1  > 0){
                    image[x,y] = RGBA(red: 255, green: 0, blue: 0, alpha: 127)
                }
            }
        }
        
        return image
    }
    
    
    func testAndTrainData(){
        
        print("BEGIN TEST AND TRAIN DATA")
        let width = 100 // Image width
        let height = 100 // Image heigth
        let thickness = 1.0 // Line thickness
        
        
        let numTrain = 1000
        let numTest = 1000
        var testImages:[Image<RGBA<UInt8>>] = []
        var testAngles:[Float] = []
        var trainImages:[Image<RGBA<UInt8>>] = []
        var trainAngles:[Float] = []
        
        
        for _ in 0..<numTrain{
            let randomFloat = Float.random(in: 0..<1)
            let angle = Float.pi*randomFloat
            trainAngles.append(angle)
            let image = generateTrainingImage(angle,width,height,thickness)
            trainImages.append(image)
        }
        
        
        for _ in 0..<numTest{
            let randomFloat = Float.random(in: 0..<1)
            let angle = Float.pi*randomFloat
            testAngles.append(angle)
            let image = generateTrainingImage(angle,width,height,thickness)
            testImages.append(image)
        }
        

        do {
            let  test = try SeconnTest()
            
            test.debugLevel = .info
            
            let rateDefault: Float = 0.8
            var rate: Float = rateDefault
            var rateDecay: Float = 1.000
            var skipper = 0
            let skipValue = 10
            
            print("Rate: \(rateDefault)")
            print("Rate decay: \(rateDecay)")
            
            func doTest(_ test: SeconnTest) {
                if skipper == 0 {
                    skipper = skipValue
                    let t = test.test(batches: 0..<3)
//                    t.totalPerformance
//                    t.indexedPerformance
                } else {
                    skipper -= 1
                    let t = test.test(batches: 0..<1)
//                    t.totalPerformance
//                    t.indexedPerformance
                }
            }
            print("Using plain method")
            for trainState in test.train().prefix(500).dropFirst(250) {
                doLearn(test, state: trainState, rate: rate)
                rate *= rateDecay
//                doTest(test)
            }
            
            rate = 0.5
            rateDecay = 0.995
            
            print("Rate: \(rateDefault)")
            print("Rate decay: \(rateDecay)")

//            print(test.neuralNetwork)
            
            /*:
             Internally, this network is set to use 1000 neurons. Obviously,
             you can't get high performance with binary step and such a little quantity
             of neurons on MNIST dataset. But it also shows that it works, and doesn't
             suffer from EC-saturation and value locking, which happen when using
             Laplacian operator on common networks.
             */
          /*  let testResult = test.test(batches: 0..<10)
            
            let trainPerformance = test.train().prefix(250).map { s in argmax(s.process()) == (try! oneHotDecode(s.value.output)) ? 1.0 : 0.0  }.average()
            print("Train performance: \(trainPerformance)")
            print("Test performance: \(testResult.totalPerformance)")
            print("Test performance (indexed): \(testResult.indexedPerformance)")
            
            let target = test.dataset.testBatch(index: 0).1.map(argmax)
            let result = test.batchCompute(inputBatch: test.dataset.testBatch(index: 0).0)
            
            print(zip(target, result).map { t,r in "\(t): \(argmax(r)) \(r)"}, separator: "\n")*/
            
        }
        catch let error {
            print(error.localizedDescription)
            abort()
        }
        

        

      
    }
    // Returns encoded angle using specified method ("binned","scaled","cossin","gaussian")
    func encodeAngle(_ angle:Float,_ method:String)->[Float]{
        var X:[Float] = []
        if (method == "binned"){ // 1-of-500 encoding
            X = [Float](repeating: 0, count: 500 )
            X[Int(round(250*(angle/Float.pi + 1)))%500] = 1
        }else if (method == "gaussian"){ // Leaky binned encoding
            
            for i in 0...500{
                X.append(Float(i))
            }
            
            let idx:Float = 250*(angle/Float.pi + 1)
            let Y = X-idx
            //            X = exp(-Float.pi*(Y)**2.0) //TODO
        }else if (method == "scaled"){ // Scaled to [-1,1] encoding
            X = Array([angle/Float.pi])
        }else if (method == "cossin"){ //Oxinabox's (cos,sin) encoding
            X = Array([cos(angle),sin(angle)])
        }
        return X
    }
    
    
    // Returns decoded angle using specified method
    func decodeAngle(_ X:[Float],_ method:String)->Float{
        var M:Float = 0
        var angle:Float = 0
        if (method == "binned") || (method == "gaussian"){ // 1-of-500 or gaussian encoding
            M = X.max()!
            for i in 0...X.count{
                if abs(X[i]-M) < 1e-5{
                    angle = Float.pi*Float(i/250) - Float.pi
                }
            }
            // angle = pi*dot(array([i for i in range(500)]),X)/500  # Averaging
        } else if (method == "scaled"){ // Scaled to [-1,1] encoding
            angle = Float.pi*X[0]
        }else if (method == "cossin"){ //# Oxinabox's (cos,sin) encoding
            angle = atan2(X[1],X[0])
        }
        return angle
    }
    
    /*
    // Train and test neural network with specified angle encoding method
     func testEncodingMethod(trainImages:[Image<RGBA<UInt8>>],trainAngles:[Float],testImages:[Image<RGBA<UInt8>>], testAngles:[Float], method:String, numIters:Int, alpha:Float = 0.01, alphaBias:Float = 0.0001, momentum:Float = 0.9, hiddenLayerSize:Int = 500){
     //        var numTrain,inLayerSize = shape(train_images)
     var num_test = testAngles.count
     
     if method == "binned"{
        outLayerSize = 500
     }else if method == "gaussian"{
        outLayerSize = 500
     }else if method == "scaled"{
        outLayerSize = 1
     }else if  method == "cossin"{
        outLayerSize = 2
     }
     // Initial weights and biases
     var IN_HID = rand(inLayerSize,hidLayerSize) - 0.5 // IN --> HID weights
     var HID_OUT = rand(hid_layer_size,outLayerSize) - 0.5 // HID --> OUT weights
     var BIAS1 = rand(hidLayerSize) - 0.5 // Bias for hidden layer
     var BIAS2 = rand(outLayerSize) - 0.5 // Bias for output layer
     
     
     // Train
     for j in 0...numIters{
         for i in 0...numTrain{
         
         }
     }
     
     // Get training example
     IN = train_images[i]
     TARGET = encode_angle(train_angles[i],method)
     
     // Feed forward and compute error derivatives
     HID = sigmoid(dot(IN,IN_HID)+BIAS1)
     
     if method == "binned" or method == "gaussian": // Use softmax
     OUT = exp(clip(dot(HID,HID_OUT)+BIAS2,-100,100))
     OUT = OUT/sum(OUT)
     dACT2 = OUT - TARGET
     elif method == "cossin" or method == "scaled": // Linear
     OUT = dot(HID,HID_OUT)+BIAS2
     dACT2 = OUT-TARGET
     else:
     print("Invalid encoding method")
     
     dHID_OUT = outer(HID,dACT2)
     dACT1 = dot(dACT2,HID_OUT.T)*HID*(1-HID)
     dIN_HID = outer(IN,dACT1)
     dBIAS1 = dACT1
     dBIAS2 = dACT2
     
     
     // Update the weights
     HID_OUT -= alpha*dHID_OUT
     IN_HID -= alpha*dIN_HID
     BIAS1 -= alpha_bias*dBIAS1
     BIAS2 -= alpha_bias*dBIAS2
     
     // Test
     test_errors = zeros(num_test)
     angles = zeros(num_test)
     target_angles = zeros(num_test)
     accuracy_to_point001 = 0
     accuracy_to_point01 = 0
     accuracy_to_point1 = 0
     
     for i in 0...num_test{
     // Get training example
     IN = test_images[i]
     target_angle = test_angles[i]
     
     // Feed forward
     HID = sigmoid(dot(IN,IN_HID)+BIAS1)
     
     if (method == "binned") || method == "gaussian"{
     OUT = exp(clip(dot(HID,HID_OUT)+BIAS2,-100,100))
     OUT = OUT/sum(OUT)
     }else if  (method == "cossin") || (method == "scaled"){
     OUT = dot(HID,HID_OUT)+BIAS2
     }
     
     
     // Decode output
     angle = decodeAngle(OUT,method)
     
     // Compute errors
     error = abs(angle-target_angle)
     test_errors[i] = error
     angles[i] = angle
     
     target_angles[i] = target_angle
     if error < 0.1{
     accuracy_to_point1 += 1
     }
     if error < 0.01{
     accuracy_to_point01 += 1
     }
     if error < 0.001{
     accuracy_to_point001 += 1
     }
     }
     
     
     
     
     // Compute and return results
     accuracy_to_point1 = 100.0*accuracy_to_point1/num_test
     accuracy_to_point01 = 100.0*accuracy_to_point01/num_test
     accuracy_to_point001 = 100.0*accuracy_to_point001/num_test
     
     return mean(test_errors),median(test_errors),min(test_errors),max(test_errors),accuracy_to_point1,accuracy_to_point01,accuracy_to_point
     }*/
     

    
    
    
    
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
        
        
        //        let fast = FAST()
        //        let cnrs = fast.findLines(image: newImage, threshold: 2)
        //        testView.myPixels = cnrs
        
    }
    
    
}



