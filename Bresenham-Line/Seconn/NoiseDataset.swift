//
//  NoiseDataset.swift
//  Seconn
//
//  Created by Ilya Mikhaltsou on 11.04.2018.
//

import Foundation


// Silence NoiseDataset playground representation. Otherwise, playground chokes on class members
extension NoiseDataset: CustomReflectable {
    public var customMirror: Mirror {
        return Mirror(self, children: [
            (label: "batchCount", value: self.batchCount),
            ], displayStyle: .`struct`)
    }
}



public class NoiseDataset {

    public enum RandomFunction {
        case linear(min: Double, max: Double)
        case gaussian(mean: Double, sigma: Double)

        func f() -> Double {
            switch self {
            case let .linear(min: min, max: max):
                return min + (max - min) * (Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max))
            case .gaussian:
                fatalError("Not implemented")
            }
        }
    }

    public enum ValueType {
        case single(value: [Double])
        case random(count: Int, RandomFunction)

        func value() -> [Double] {
            switch self {
            case let .single(v):
                return v
            case let .random(count: count, f):
                return (0 ..< count) .map { _ in f.f() }
            }
        }
    }

    let inputBatches: [[[Double]]]
    let outputBatches: [[[Double]]]

    public func batch(index: Int) -> ([[Double]], [[Double]]) {
        return (inputBatches[index], outputBatches[index])
    }

    public var batchCount: Int {
        return inputBatches.count
    }

    public init(input: ValueType, output: ValueType, count: Int, batchSize: Int) {
        self.inputBatches = NoiseDataset.generate(value: input, count: count, batchSize: batchSize)
        self.outputBatches = NoiseDataset.generate(value: output, count: count, batchSize: batchSize)
    }

    static func generate(value: ValueType, count: Int, batchSize: Int) -> [[[Double]]] {
        precondition(count % batchSize == 0, "Count should be divisible by batchSize")
        let countInBatch = count / batchSize

        var batches: [[[Double]]] = Array()

        for _ in 0 ..< batchSize {
            var batch: [[Double]] = Array()
            batch.reserveCapacity(countInBatch)

            for _ in 0 ..< countInBatch {
                batch.append(value.value())
            }
            batches.append(batch)
        }
        return batches
    }
}
