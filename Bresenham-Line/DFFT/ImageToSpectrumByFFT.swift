//
//  ImageToSpectrumByFFT.swift
//  EasyCamery
//
//  Created by 岡大輔 on 2018/07/03.
//  Copyright © 2018年 koherent.org. All rights reserved.
//


import EasyImagy
import Surge

public class ImageToSpectrumByFFT: NSObject {
    public class func ImageToSpectrumByFFTFunctionR(inputImage:Image<RGBA<UInt8>>)->Array<Double>
    {
        let timeAxisWaveForm = TimeAxisWaveFormGenerate.extractRTimeAxisWaveFormFromImage(inputImage: inputImage)
        //以下FFTルーチン
        return FFTTimeAxisWaveForm(timeAxisWaveForm: timeAxisWaveForm)
        
    }
    public class func ImageToSpectrumByFFTFunctionG(inputImage:Image<RGBA<UInt8>>)->Array<Double>
    {
        let timeAxisWaveForm = TimeAxisWaveFormGenerate.extractGTimeAxisWaveFormFromImage(inputImage: inputImage)
        return FFTTimeAxisWaveForm(timeAxisWaveForm: timeAxisWaveForm)
    }
    public class func ImageToSpectrumByFFTFunctionB(inputImage:Image<RGBA<UInt8>>)->Array<Double>
    {
        let timeAxisWaveForm = TimeAxisWaveFormGenerate.extractBTimeAxisWaveFormFromImage(inputImage: inputImage)
        return FFTTimeAxisWaveForm(timeAxisWaveForm: timeAxisWaveForm)
    }
    
    public class func ImageToSpectrumByFFTFunctionWhite(inputImage:Image<RGBA<UInt8>>)->Array<Double>
    {
        let timeAxisWaveForm = TimeAxisWaveFormGenerate.extractWhiteTimeAxisWaveFormFromImage(inputImage: inputImage)
        return FFTTimeAxisWaveForm(timeAxisWaveForm: timeAxisWaveForm)
    }
    
    public class func FFTTimeAxisWaveForm(timeAxisWaveForm:Array<Double>)->Array<Double>
    {
        //ここは、FFTをするルーチン、書き換えるかもしれない
        var wave = timeAxisWaveForm
        if(timeAxisWaveForm.count != 1024){
            var initial = timeAxisWaveForm.count
            while(initial < 1024){
                wave.append(Double(0.0))
                initial += 1
            }
        }
        return fft(wave)
    }
}
