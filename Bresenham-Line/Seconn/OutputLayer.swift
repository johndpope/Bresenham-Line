//
//  OutputLayer.swift
//  Seconn
//
//  Created by Ilya Mikhaltsou on 13.04.2018.
//

import Foundation
import Surge

struct OutputLayer {
    let reductionMatrix: SliceableMatrix<Double>
    let reductionMatrixTransposed: SliceableMatrix<Double>

    init(inputSize: Int, outputSize: Int) {
        precondition(inputSize % outputSize == 0, "Output layer should be a multiple of its input")
        let count = inputSize / outputSize
        let rate = Double(outputSize) / Double(inputSize)
        var matrix = SliceableMatrix(rows: outputSize, columns: inputSize, repeatedValue: Double(0.0))
        var rowArray = Array(repeating: Double(0.0), count: inputSize)
        for i in 0..<outputSize {
            let prefixCount = count * i
            let postfixCount = count * (outputSize - i - 1)

            if prefixCount != 0 {
                rowArray.replaceSubrange(..<prefixCount, with: repeatElement(0.0, count: prefixCount))
            }

            rowArray.replaceSubrange(prefixCount..<(prefixCount+count), with: repeatElement(rate, count: count))

            if postfixCount != 0 {
                rowArray.replaceSubrange((prefixCount+count)..., with: repeatElement(0.0, count: postfixCount))
            }

            matrix.replace(row: i, with: rowArray)
        }
        reductionMatrix = matrix
        reductionMatrixTransposed = reductionMatrix′
    }
}

extension OutputLayer: Layer {
    var inputSize: Int {
        return reductionMatrix.columnCount
    }

    var outputSize: Int {
        return reductionMatrix.rowCount
    }

    func process(input: [Double]) -> [Double] {
        return Array((reductionMatrix * SliceableMatrix(column: input))[column: 0])
    }
}


extension OutputLayer: LearningLayer {
    mutating func learn(input: [Double], output: [Double], target: [Double], weightRate: Double, biasRate: Double) -> [Double] {
        return ceil(clip((reductionMatrixTransposed * SliceableMatrix(column: target))[column: 0], low: 0.0, high: 1.0))
    }
}
