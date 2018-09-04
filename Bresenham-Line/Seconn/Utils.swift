//
//  Utils.swift
//  NnMnist
//
//  Created by Ilya Mikhaltsou on 6.04.2018.
//

import Foundation

extension Sequence where Element == Bool {
    fileprivate func all() -> Bool {
        return reduce(false) { r, v in r && v }
    }

    fileprivate func any() -> Bool {
        return reduce(false) { r, v in r || v }
    }
}

extension Sequence {
    func all(_ transform: (Element) throws -> Bool) rethrows -> Bool {
        return try map(transform).all()
    }

    func any(_ transform: (Element) throws -> Bool) rethrows -> Bool {
        return try map(transform).any()
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }

        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
