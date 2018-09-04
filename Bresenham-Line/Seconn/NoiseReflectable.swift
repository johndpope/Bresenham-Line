import Foundation


// Silence NoiseDataset playground representation. Otherwise, playground chokes on class members
extension NoiseDataset: CustomReflectable {
    public var customMirror: Mirror {
        return Mirror(self, children: [
            (label: "batchCount", value: self.batchCount),
        ], displayStyle: .`struct`)
    }
}

