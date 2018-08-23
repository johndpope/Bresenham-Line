//
//  ViewController.swift
//  Bresenham-Line
//
//  Created by Cirno MainasuK on 2017-3-17.
//  Copyright © 2017年 Cirno MainasuK. All rights reserved.
//

import Cocoa
import EasyImagy


extension CMKViewController {

    func generateTrainingImage(angle:Float, width:Int, height:Int, thickness:Int)->Image<RGBA<UInt8>>{
         let image = Image<RGBA<UInt8>>(width: width, height: height, pixel: RGBA.transparent)

        let x_0 = width / 2
        let y_0 = height / 2
        let c = cos(angle)
        let s  = sin(angle)
        for y in 0...height{
            for x in 0...width{
                let w1 = abs((x-x_0)*c + (y-y_0)*s)
                let h1 = -(x-x_0)*s + (y-y_0)*c
                if (w1 < (thickness / 2) && h1  > 0){
                     image[x,y] = 1
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
        let testImages = []
        let testAngles = []
        let trainImages = []
        let trainAngles = []
        
        
        for i in 0...numTrain{
            let angle = pi*(2*rand() - 1)
            trainAngles.append(angle)
            let image = generateTrainingImage(angle,width,height,thickness)
            trainImages.append(image)
        }
        
       
        for i in 0...numTest{
            let angle = pi*(2*rand() - 1)
            testAngles.append(append)
            let image = generateTrainingImage(angle,width,height,thickness)
            trainImages.append(image)
        }

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
        

        let fast = FAST()
        let cnrs = fast.findLines(image: newImage, threshold: 2)
        testView.myPixels = cnrs
        
    }
    

}



