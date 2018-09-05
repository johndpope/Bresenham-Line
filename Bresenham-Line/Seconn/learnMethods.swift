import Foundation


let repeats = 1
let learnCutoff: FloatType = 1.0
let delearnCutoff: FloatType = 0.5
let delearnRate: FloatType = 0.25

public func doLearn(_ test: SeconnTest, state: TrainStateProtocol, rate: FloatType) {
    for _ in 0..<repeats {
     
        let output = state.process()
        /*▿ 10 elements
         - 0 : 0.52
         - 1 : 0.48000002
         - 2 : 0.53999996
         - 3 : 0.48
         - 4 : 0.62
         - 5 : 0.5
         - 6 : 0.39999998
         - 7 : 0.56
         - 8 : 0.44
         - 9 : 0.42
         */
        
        let outputIdx: Int = argmax(output) // item 4 / 0.62 is max value
        let target = state.value.output // [1,0,0,0,0,0,0,0,0,0]
        let targetIdx = try! oneHotDecode(target)
        print("\n\n\n")
        print("\ntargetIdx:\(targetIdx) \noutputIdx:\(outputIdx)\noutput[" + output.map(String.init).joined(separator: ", "), terminator: "]")

        state.train(rate: rate) // take input pixels / match to 1 hot vector output

        do {
            let output = state.process()
            let outputIdx: Int = argmax(output)
            let target = state.value.output
            let targetIdx = try! oneHotDecode(target)
            print("\noutputIdx:\(outputIdx)\noutput:[" + output.map(String.init).joined(separator: ", "), terminator: "]")
        }
    }
}

// Brains of network
extension  SecoNetwork {
    public func train(input: [FloatType], output: [FloatType], rateReduction: FloatType, inverse: Bool = false) {
        let hiddenInput: [FloatType]
        var hiddenIOs: [([FloatType], [FloatType])] = []
        
        hiddenInput = layers.first!.process(input: input)
        
        let _ = layers.dropFirst().reduce(hiddenInput) { (lastOutput, layer) -> [FloatType] in
            let output = layer.process(input: lastOutput)
            hiddenIOs.append((lastOutput, output))
            return output
        }
        
        let _ = zip(hiddenIOs, layers.indices.filter { layerIdx in layers[layerIdx] is LearningLayer })
            .reversed()
            .reduce(output) { (lastOutput, arg) in
                let (layerIOs, layerIdx) = arg
                let (layerInput, layerOutput) = layerIOs
                var layerTmp = layers[layerIdx] as! Layer & LearningLayer
                let newOutput = layerTmp.learn(input: layerInput, output: layerOutput, target: lastOutput,
                                               weightRate: (inverse ? -1.0 : 1.0) * config.learningRateForWeights * rateReduction,
                                               biasRate: (inverse ? -1.0 : 1.0) * config.learningRateForBiases * rateReduction)
                layers[layerIdx] = layerTmp
                return newOutput
        }
    }
}
//extension OutputLayer: LearningLayer {
//    mutating func learn(input: [FloatType], output: [FloatType], target: [FloatType], weightRate: FloatType, biasRate: FloatType) -> [FloatType] {
//        return ceil(clip((reductionMatrixTransposed * SliceableMatrix(column: target))[column: 0], low: 0.0, high: 1.0))
//    }
//}


/*
public func doLearnMagic(_ test: SeconnTest, state: TrainStateProtocol, rate: FloatType) {
    for _ in 0..<repeats {
        let output = state.process()
        let outputIdx: Int = argmax(output)
        let target = state.value.output
        let targetIdx = try! oneHotDecode(target)

        print("\(targetIdx), \(outputIdx), " + output.map(String.init).joined(separator: ", "), terminator: ", ")

        if outputIdx != targetIdx {
            let delearnTargets = output.enumerated().filter({ i,e in e > delearnCutoff && i != targetIdx })
            if delearnTargets.count != 0 {
                var delearnVector: [FloatType] = Array(repeating: 0, count: 10)
                for (i,_) in delearnTargets { delearnVector[i] = 1.0 }
                test.neuralNetwork.train(input: state.value.input, output: delearnVector, rateReduction: rate*delearnRate, inverse: true)
            }
        }

        if output[targetIdx] <= learnCutoff {
            state.train(rate: rate)
        }

        do {
            let output = state.process()
            let outputIdx: Int = argmax(output)
            let target = state.value.output
            let targetIdx = try! oneHotDecode(target)
            print("\(outputIdx), " + output.map(String.init).joined(separator: ", "))
        }
    }
}

*/
