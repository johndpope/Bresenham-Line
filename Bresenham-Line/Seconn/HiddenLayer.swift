//
//  HiddenLayer.swift
//  Seconn
//
//  Created by Ilya Mikhaltsou on 13.04.2018.
//

import Foundation
import Surge

/// Initial view of how ECO should apply to Binary step. Note that high bias learning rate is a
/// prerequisite, since it controls the activation threshold. Without appropriate bias learnint
/// rate, the output becomes saturated.
struct HiddenLayer {
    var weights: SliceableMatrix<Double>
    var biases: [Double]
    let activationFunction: ([Double]) -> [Double] = { input in
        return ceil(clip(input, low: 0.0, high: 1.0))
    }

    init(inputSize: Int, outputSize: Int, weightInitializer: () -> Double) {
        let allWeights = (0 ..< inputSize*outputSize) .map { _ in
            weightInitializer()
        }
        self.weights = SliceableMatrix(rows: outputSize, columns: inputSize, grid: allWeights)
        self.biases = Array(repeating: 0.0, count: outputSize)
        self.weightCorrectionsInit = SliceableMatrix(rows: weights.rowCount, columns: weights.columnCount, repeatedValue: 1.0)
    }

     let weightCorrectionsInit: SliceableMatrix<Double>
}

extension HiddenLayer: Layer {
    var inputSize: Int {
        return weights.columnCount
    }

    var outputSize: Int {
        return weights.rowCount
    }

    func process(input: [Double]) -> [Double] {
        return activationFunction(mul(weights, SliceableMatrix(column: input))[column: 0] .+ biases)
    }
}

extension HiddenLayer: LearningLayer {
    mutating func learn(input: [Double], output: [Double], target: [Double], weightRate: Double, biasRate: Double) -> [Double] {
       

        var weightCorrections = mul(weightRate, weightCorrectionsInit)
        weightCorrections = elmul(weightCorrections, SliceableMatrix(repeatElement(output * -1.5 + 0.5, count: weightCorrections.columnCount))′)
        let targetNotEqualsOutput = abs(target .- output)
        let inputIsOne = input

        // Simplify expression for Swift compiler
        let weightFormula1 = SliceableMatrix(column: neg(targetNotEqualsOutput) + 1.0) * SliceableMatrix(row: neg(inputIsOne) + 1.0)
        let weightFormula2 = SliceableMatrix(column: targetNotEqualsOutput) * SliceableMatrix(row: inputIsOne)
        let weightFormula3 = matrixOp({x in clip(x, low: 0.0, high: 1.0)},
                                      weightFormula1 + weightFormula2)
        weightCorrections = elmul(weightCorrections, weightFormula3)

        var biasCorrections = Array(repeating: biasRate, count: biases.count)
        biasCorrections = biasCorrections .* (output * -2.0 + 1.0)
        biasCorrections = biasCorrections .* targetNotEqualsOutput

        let targetInput: [Double] =
            activationFunction(
//                sum(weights′ * SliceableMatrix(column: targetNotEqualsOutput /* * 2.0 - 1.0 */), axies: .row)[column: 0]
                sum(weights′ * SliceableMatrix(column: output), axies: .row)
        )

        weights = weights + weightCorrections
        biases = biases .+ biasCorrections

        return targetInput
    }
}
