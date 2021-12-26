import Algorithms

let width = 25
let height = 6
let pixelCount = width * height

// part 1

struct Layer {
    let numZeros: Int
    let numOnes: Int
    let numTwos: Int
}

extension Layer {
  init<S: StringProtocol>(_ data: S) {
    var numZeros = 0
    var numOnes = 0
    var numTwos = 0
    for char in data {
      switch char {
        case "0": numZeros += 1
        case "1": numOnes += 1
        case "2": numTwos += 1
        default: break
      }
    }
    self.init(numZeros: numZeros, numOnes: numOnes, numTwos: numTwos)
  }
}

public func partOne() {
  let layers = input.chunks(ofCount: 150).map { Layer($0) }
  if let bestLayer = layers.min(by: { $0.numZeros < $1.numZeros }) {
    print(bestLayer.numOnes * bestLayer.numTwos) // 1560
  }
}

extension Character {
    var isTransparent: Bool { self == "2" }

    var pixelValue: Character {
        switch self {
        case "0": return " "
        case "1": return "■"
        default: return self
        }
    }
}

public func partTwo() {
  let layerData = input.chunks(ofCount: pixelCount)
    let layers = layerData.map { substr in
        substr.map { $0.pixelValue }
    }

    let transparentLayer = Array(repeating: Character("2"), count: pixelCount)
    let image = layers.reduce(into: transparentLayer) { result, value in
        for i in 0..<result.count {
            if result[i].isTransparent {
                result[i] = value[i]
            }
        }
    }
    String(image).chunks(ofCount: width).forEach { print($0) } // UGCUH
}
