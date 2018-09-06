import Cocoa
import EasyImagy
import Foundation
import Surge
import QuartzCore





extension CMKViewController {
    


    // will spit out images with slopes on them.
    // attempt to use bresenham radial slices instead of square image to slim down neural network
    //https://stats.stackexchange.com/questions/218407/encoding-angle-data-for-neural-network
    func testRadialNeuralNetAndTrainData(){
        
        print("BEGIN RADIAL TRAIN DATA")
        let width = 101 // Image width
        let height = 101 // Image heigth
  
        let thickness:Double = 1.0 // Line thickness

        let numTrain = 1000
        let numTest = 1000
        var testImages:[[Byte]] = []
        var testAngles:[Double] = []
        var trainImages:[[Byte]] = []
        var trainAngles:[[Double]] = []
        
        // TRAINING
        for _ in 0..<numTrain{
            let angle:Double = .pi * .random(in: 0..<1)
       
            let encodedAngle = encodeAngle(angle,.binned) /// 1 -> 500 array 1 hot vector 000000000100000
//            let encodedAngle = encodeAngle(angle,.gaussian) // FAILS HARD
//             let encodedAngle = encodeAngle(angle,.scaled)
//              let encodedAngle = encodeAngle(angle,.cossin)
            trainAngles.append(encodedAngle)
            let image = generateTrainingImage(angle,width,height,thickness)
            let grayscale: Image<UInt8> = image.map { $0.gray }
            let radialImageArray:[UInt8]  = grayscale.radialCuts()
            trainImages.append(radialImageArray)

        }
        
        // TESTING
        for _ in 0..<numTest{
            let angle:Double = .pi * .random(in: 0..<1)
            testAngles.append(angle)
            let image = generateTrainingImage(angle,width,height,thickness)
               let grayscale: Image<UInt8> = image.map { $0.gray }
              let radialImageArray:[UInt8] = grayscale.radialCuts()
            testImages.append(radialImageArray)
        }
        

        let trainImageData = trainImages.map{ return $0.map{ return   Double($0) / 255 }}
        
        do{
          
            // TOTAL NEURONS FOR SQUARE IMAGE - 10201 = 101 x 101
            // TOTAL NEURONS FOR BRESENHAM RADIAL CUTS - 524 /  r = 3 + r = 5 + r = 15 + r = 30 +  r = 45
            
            let n = trainImages[0].count // will correspond to the count of 5 radialCuts flattened as array
            
            let network = Network(layerStructure: [n,500,1], activationFunction: sigmoid, derivativeActivationFunction: derivativeSigmoid, learningRate: 0.006, hasBias: true)
            
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
    
   
    
}



