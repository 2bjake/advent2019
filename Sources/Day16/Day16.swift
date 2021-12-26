import Extensions

func processPhase(_ signal: [Int]) -> [Int] {
  var newSignal = Array(repeating: 0, count: signal.count)

  for i in signal.indices {
    let patternSize = i + 1


    var positive = 0
    var negative = 0

    var signal = ArraySlice(signal).dropFirst(patternSize - 1)
    while signal.notEmpty {
      positive += signal.prefix(patternSize).reduce(0, +)
      signal = signal.dropFirst(patternSize * 2)
      negative -= signal.prefix(patternSize).reduce(0, +)
      signal = signal.dropFirst(patternSize * 2)
    }
    newSignal[i] = abs(positive + negative) % 10
  }

  return newSignal
}

public func partOne() {
  var signal = input.compactMap(Int.init)
  for _ in 0..<100 {
    signal = processPhase(signal)
  }
  print(signal.prefix(8).map(String.init).joined()) //22122816
}

var lookup: [[Int]] = {
  let row = Array(repeating: 0, count: 10)
  var result = Array(repeating: row, count: 10)
  for i in 0...9 {
    for j in 0...9 {
      result[i][j] = (i + j) % 10
    }
  }
  return result
}()

public func partTwo() {
  let inputSignal = input.compactMap(Int.init)
  let startIdx = Int(inputSignal.prefix(7).map(String.init).joined())!

  var signal = Array((0..<10_000).flatMap { _ in inputSignal }.dropFirst(startIdx))

  for _ in 0..<100 {
    var newSignal = Array(repeating: 0, count: signal.count)
    var sum = 0
    for idx in signal.indices.reversed() {
      sum = lookup[sum][signal[idx]]
      newSignal[idx] = sum
    }
    signal = newSignal
  }
  print(signal.prefix(8).map(String.init).joined()) // 41402171
}
