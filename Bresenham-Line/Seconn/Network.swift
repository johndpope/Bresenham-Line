//
//  Network.swift
//  Seconn
//
//  Created by Ilya Mikhaltsou on 6.04.2018.
//

import Foundation
import Surge

public typealias Double = Float

public enum OneHotDecoderError: Error {
    case invalidInput(value: [Double])
    
    public var localizedDescription: String {
        switch self {
        case let .invalidInput(value):
            return "Invalid input for one-hot decode: \(value)"
        }
    }
}

public func oneHotDecode(_ a: [Double]) throws -> Int {
    for i in a.indices {
        if a[i] == 1.0 {
            return i
        }
    }
    throw OneHotDecoderError.invalidInput(value: a)
}


struct InputLayer {
    let inputSize: Int
    let activationFunction: ([Double]) -> [Double] = { input in
        return ceil(clip(input, low: 0.0, high: 1.0))
    }
}

extension InputLayer: Layer {
    var outputSize: Int {
        return inputSize
    }
    
    func process(input: [Double]) -> [Double] {
        return activationFunction(input)
    }
}


protocol Layer {
    func process(input: [Double]) -> [Double]

    var inputSize: Int { get }

    var outputSize: Int { get }
}

protocol LearningLayer {
    mutating func learn(input: [Double], output: [Double], target: [Double], weightRate: Double, biasRate: Double) -> [Double]
}

public struct SecoNetworkConfiguration {
    var inputSize: Int
    var outputSize: Int

    var hiddenLayersSizes: [Int]

    var weightInitializer: () -> Double

    var learningRateForWeights: Double
    var learningRateForBiases: Double
}

public class SecoNetwork {

     let config: SecoNetworkConfiguration
     var layers: [Layer]

    public init(config: SecoNetworkConfiguration) {
        self.config = config

        self.layers = []
        setup()
    }

     func setup() {
        var lastLayer: Layer = InputLayer(inputSize: config.inputSize)
        layers.append(lastLayer)

        for layerSize in config.hiddenLayersSizes.dropLast() {
            lastLayer = HiddenLayer(inputSize: lastLayer.outputSize,
                                    outputSize: layerSize, weightInitializer: config.weightInitializer)
            layers.append(lastLayer)
        }

        if let layerSize = config.hiddenLayersSizes.last {
            lastLayer = HiddenLayer(inputSize: lastLayer.outputSize,
                                     outputSize: layerSize, weightInitializer: config.weightInitializer)
            layers.append(lastLayer)
        }

        lastLayer = OutputLayer(inputSize: lastLayer.outputSize, outputSize: config.outputSize)
        layers.append(lastLayer)
    }

    public func process(input: [Double]) -> [Double] {
        return layers.reduce(input) { (lastOutput, layer) -> [Double] in
            layer.process(input: lastOutput)
        }
    }
}

extension SecoNetwork: CustomDebugStringConvertible {
    public var debugDescription: String {
        return self.layers.map { layer in
            switch layer {
            case let l as InputLayer:
                return "InputLayer: {inputSize: \(l.inputSize)}"
            case let l as HiddenLayer:
                return "HiddenLayer: {inputSize: \(l.inputSize), outputSize: \(l.outputSize), minWeight: \(min(l.weights)), maxWeight: \(max(l.weights)), minBias: \(min(l.biases)), maxBias: \(max(l.biases)), data: \n\(l.weights)\n}"
            case let l as OutputLayer:
                return "OutputLayer: {inputSize: \(l.inputSize), outputSize: \(l.outputSize), minWeight: \(min(l.reductionMatrix)), maxWeight: \(max(l.reductionMatrix)), data: \n\(l.reductionMatrix)\n}"
            default:
                return ""
            }
        } .joined(separator: "\n")
    }
}

extension SecoNetwork: CustomReflectable {
    public var customMirror: Mirror {
        let children: [Mirror.Child] = [
            (label: "config", value: self.config),
            (label: "layers", value: self.layers),
        ]

        return Mirror(self, children: children, displayStyle: .`struct`)
    }
}

extension InputLayer: CustomReflectable {
    public var customMirror: Mirror {
        let children: [Mirror.Child] = [
            (label: "inputSize", value: self.inputSize),
        ]

        return Mirror(self, children: children, displayStyle: .`struct`)
    }
}

extension OutputLayer: CustomReflectable {
    public var customMirror: Mirror {
        let children: [Mirror.Child] = [
            (label: "inputSize", value: self.inputSize),
            (label: "outputSize", value: self.outputSize),
            (label: "minWeight", value: min(self.reductionMatrix)),
            (label: "maxWeight", value: max(self.reductionMatrix)),
            (label: "data", value: self.reductionMatrix),
        ]

        return Mirror(self, children: children, displayStyle: .`struct`)
    }
}

extension HiddenLayer: CustomReflectable {
    public var customMirror: Mirror {
        let children: [Mirror.Child] = [
            (label: "inputSize", value: self.inputSize),
            (label: "outputSize", value: self.outputSize),
            (label: "minWeight", value: min(self.weights)),
            (label: "maxWeight", value: max(self.weights)),
            (label: "minBias", value: min(self.biases)),
            (label: "maxBias", value: max(self.biases)),
            (label: "weights", value: self.weights),
            (label: "biases", value: self.biases),
        ]

        return Mirror(self, children: children, displayStyle: .`struct`)
    }
}
