//
//  MNISTManager.swift
//  NeuralNet-MNIST
//
//  Created by Collin Hundley on 4/12/17.
//
//

import Foundation
import Gzip


public class MNISTManager {

    fileprivate static let defaultDirectory = "MNIST/"
    let directory = "abc"

    /// All data files in the MNIST dataset.
    fileprivate enum File: String {
        case trainImages = "train-images-idx3-ubyte"
        case trainLabels = "train-labels-idx1-ubyte"
        case validationImages = "t10k-images-idx3-ubyte"
        case validationLabels = "t10k-labels-idx1-ubyte"
    }
    
    
    // MARK: Data caches
    
    public let trainImages: [[[Float]]]
    public let trainLabels: [[[Float]]]
    public let validationImages: [[[Float]]]
    public let validationLabels: [[[Float]]]
    
    
    // MARK: One-hot encoding helper
    // Note: This is easy, fast and convenient since MNIST only has 10 classifications
    
    fileprivate static let labelEncodings: [[Float]] = [
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 1]
    ]
    
    
    // MARK: Initialization
    
    /// Initializes an instance of `MNISTManager` and caches the full dataset for quick access.
    ///
    /// - Parameter directory: The directory URL where MNIST data will be stored.
    /// - Parameter pixelRange: A range [Float, Float] to scale image pixels.
    /// The desired range will depend on the activation functions used in the neural network.
    /// For example, a network with Logistic hidden activation might want to scale pixels to [-1, 1].
    public init(directory: URL, pixelRange: (min: Float, max: Float), batchSize: Int) throws {
        // Download data
        let downloader = Downloader(in: directory)
        if !downloader.isDataLoaded() {
            try downloader.downloadData()
        }

        try downloader.unzipData()

        // Cache training images
        trainImages = try MNISTManager.extractImages(from: .trainImages, directory: directory, range: pixelRange, batchSize: batchSize)
        // Cache training labels
        trainLabels = try MNISTManager.extractLabels(from: .trainLabels, directory: directory, batchSize: batchSize)
        // Cache validation images
        validationImages = try MNISTManager.extractImages(from: .validationImages, directory: directory, range: pixelRange, batchSize: batchSize)
        // Cache validation labels
        validationLabels = try MNISTManager.extractLabels(from: .validationLabels, directory: directory, batchSize: batchSize)
    }

}

fileprivate class Downloader {

    let parentDirectory: URL

    static let allFiles = [MNISTManager.File.trainImages, MNISTManager.File.trainLabels,
                    MNISTManager.File.validationImages, MNISTManager.File.validationLabels]
        .map { t in t.rawValue }

    static let datasetUrl = URL(string: "http://yann.lecun.com/exdb/mnist/")!
    static let gzippedExtension = "gz"

    let unzippedFiles: [URL]

    let gzippedFiles: [URL]

    let remoteFileUrls: [URL]

    init(in directory: URL) {
        self.parentDirectory = directory

        self.unzippedFiles = Downloader.allFiles
            .map { t in
                directory
                .appendingPathComponent(t)
            }

        self.gzippedFiles = unzippedFiles.map { t in t.appendingPathExtension(Downloader.gzippedExtension) }

        self.remoteFileUrls = Downloader.allFiles.map { t in
            Downloader.datasetUrl.appendingPathComponent(t).appendingPathExtension( "gz")
        }
    }

    func isDataLoaded() -> Bool {
        return gzippedFiles.all { fileUrl in
            FileManager.default.fileExists(atPath: fileUrl.absoluteString)
        }
    }

    func downloadData() throws {
        for (remoteUrl, localUrl) in zip(remoteFileUrls, gzippedFiles) {
            print("Downloading: \(remoteUrl.absoluteString)")
            let data = try Data(contentsOf: remoteUrl)
            try data.write(to: localUrl)
        }
        print("Complete")
    }

    func unzipData() throws {
        for (gzippedUrl, unzippedUrl) in zip(gzippedFiles, unzippedFiles) {
//            try FileManager.default.removeItem(at: unzippedUrl)
            print("Unpacking: \(gzippedUrl.absoluteString)")
            let data = try Data(contentsOf: gzippedUrl)
            let unzipped = try data.gunzipped()
            try unzipped.write(to: unzippedUrl)
        }
    }


}


// MARK: Data and file management

private extension MNISTManager {
    
    /// Extracts image data from the given file, with all bytes scaled to the given range.
    static func extractImages(from file: File, directory: URL, range: (min: Float, max: Float), batchSize: Int) throws -> [[[Float]]] {
        /// Scales a byte to the correct range.
        func scale(x: UInt8) -> Float {
            return (range.max - range.min) * Float(x) / 255 + range.min
        }
        // Read data from file and drop header data
        let url = directory.appendingPathComponent(file.rawValue)
        let data = try readFile(url: url).dropFirst(16)
        // Convert UInt8 array to Float array, scaled to the specified range
        let array = data.map{scale(x: $0)}
        // Split array into segments of length 784 (1 image = 28x28 pixels)
        return createBatches(stride(from: 0, to: array.count, by: 784).map{Array(array[$0..<min($0 + 784, array.count)])},
                             size: batchSize)
    }
    
    /// Extracts label data from the given file.
    static func extractLabels(from file: File, directory: URL, batchSize: Int) throws -> [[[Float]]] {
        // Read data from file and drop header data
        let url = directory.appendingPathComponent(file.rawValue)
        let data = try readFile(url: url).dropFirst(8)
        // Lookup one-hot encodings in our key
        return createBatches(data.map{labelEncodings[Int($0)]}, size: batchSize)
    }
    
    /// Attempts to read the file with the given path, and returns its raw data.
    private static func readFile(url: URL) throws -> Data {
        return try Data(contentsOf: url)
    }
    
    /// Groups the given set of data into batches of the specified size.
    private static func createBatches(_ set: [[Float]], size: Int) -> [[[Float]]] {
        let set = set.shuffled()
        var output = [[[Float]]]()
        let numBatches = set.count / size
        for batchIdx in 0..<numBatches {
            var batch = [[Float]]()
            for item in 0..<size {
                let idx = batchIdx * size + item
                batch.append(set[idx])
            }
            output.append(batch)
        }
        return output
    }
    
}

