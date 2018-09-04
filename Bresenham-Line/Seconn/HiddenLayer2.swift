//
//  HiddenLayer2.swift
//  Seconn
//
//  Created by Ilya Mikhaltsou on 13.04.2018.
//

import Foundation
import Surge

/// Alternative consideration over how ECO applies to Binary step (doesn't seem to work)
struct HiddenLayer2 {
    var weights: SliceableMatrix<FloatType>
    var biases: [FloatType]
    let activationFunction: ([FloatType]) -> [FloatType] = { input in
        return ceil(clip(input, low: 0.0, high: 1.0))
    }

    init(inputSize: Int, outputSize: Int, weightInitializer: () -> FloatType) {
        let allWeights = (0 ..< inputSize*outputSize) .map { _ in
            weightInitializer()
        }
        self.weights = SliceableMatrix(rows: outputSize, columns: inputSize, grid: allWeights)
        self.biases = Array(repeating: 0.0, count: outputSize)
        self.weightCorrectionsInit = SliceableMatrix(rows: weights.rowCount, columns: weights.columnCount, repeatedValue: 1.0)
    }

     let weightCorrectionsInit: SliceableMatrix<FloatType>
}

extension HiddenLayer2: Layer {
    var inputSize: Int {
        return weights.columnCount
    }

    var outputSize: Int {
        return weights.rowCount
    }

    func process(input: [FloatType]) -> [FloatType] {
        return activationFunction(mul(weights, SliceableMatrix(column: input))[column: 0] .+ biases)
    }
}

extension HiddenLayer2: LearningLayer {
    mutating func learn(input: [FloatType], output: [FloatType], target: [FloatType], weightRate: FloatType, biasRate: FloatType) -> [FloatType] {
        //        y1 = act(sum(x1..xN * weights) + biases)
        //
        //        if y0_1 == 0
        //          if y1 == 0
        //            biases[y1] += biasRate
        //            if x1 == 0
        //              weights[x1][y1] += weightRate
        //              x1Corr = 1
        //            else x1 == 1
        //              weights[x1][y1] += weightRate
        //              x1Corr = 1
        //          else y1 == 1
        //            biases[y1] -= biasRate
        //            if x1 == 0
        //              weights[x1][y1] += weightRate
        //              x1Corr = 1
        //            else x1 == 1
        //              weights[x1][y1] -= weightRate
        //              x1Corr = 0
        //        else y0_1 == 1
        //          if y1 == 0
        //            biases[y1] += biasRate
        //            if x1 == 0
        //              weights[x1][y1] -= weightRate
        //              x1Corr = 0
        //            else x1 == 1
        //              weights[x1][y1] += weightRate
        //              x1Corr = 1
        //          else y1 == 1
        //            biases[y1] -= biasRate
        //            if x1 == 0
        //              weights[x1][y1] -= weightRate
        //              x1Corr = 0
        //            else x1 == 1
        //              weights[x1][y1] -= weightRate
        //              x1Corr = 0
        //
        //        weightCorr = [weightRate]
        //        y0_1 == 1 ->
        //          weightCorr[.][y1] *= -1
        //        y0_1 != y1 ->
        //          x1 == 1 -> weightCorr[x1][y1] *= -1
        //        sum(weigthCorr[x1][.]) > 0 ->
        //          x1Corr = 1
        //        else
        //          x1Corr = 0
        //
        //        biasCorr = [biasRate]
        //        y1 == 1 -> biasCorr[y1] *= -1

        var weightCorrections = mul(weightRate, weightCorrectionsInit)
        let targetEqualsOne = target
        let targetNotEqualsOutput = abs(target .- output)
        let inputIsOne = input

        weightCorrections = elmul(weightCorrections, SliceableMatrix(repeatElement(targetEqualsOne * -2.0 + 1.0, count: weightCorrections.columnCount))′)

        weightCorrections = elmul(weightCorrections,
                                  mul(-2.0, SliceableMatrix(column: targetNotEqualsOutput) * SliceableMatrix(row: inputIsOne)) + 1.0)

        var biasCorrections = Array(repeating: biasRate, count: biases.count)
        biasCorrections = biasCorrections .* (output * -2.0 + 1.0)
        biasCorrections = biasCorrections .* targetNotEqualsOutput

        let targetInput: [FloatType] =
            activationFunction(
                sum(weights, axies: .column)
        )

        weights = weights + weightCorrections
        biases = biases .+ biasCorrections

        return targetInput
    }
}
