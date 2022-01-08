import IntCode

public func partOne() {
  var sum = 0
  for x in 0..<50 {
    for y in 0..<50 {
      var machine = Machine(program: input)
      let result = machine.run(initialInputs: [x, y])
      sum += result.output.first!
    }
  }
  print(sum) // 192
}

func bounds(at y: Int, previous: ClosedRange<Int>? = nil) -> ClosedRange<Int> {
  var first: Int?
  var last: Int?

  var seenLast = false
  var x = previous?.lowerBound ?? 0
  while !seenLast {
    var machine = Machine(program: input)
    let output = machine.run(initialInputs: [x, y]).output.first!
    if output == 1 {
      if first == nil {
        first = x
        if let upper = previous?.upperBound {
          x = upper - 1
        }
      }
      last = x
    } else if last != nil {
      seenLast = true
    }
    x += 1
  }
  return first!...last!
}

func isBeamAt(x: Int, y: Int) -> Bool {
  var machine = Machine(program: input)
  let result = machine.run(initialInputs: [x, y])
  return result.output.first == 1
}

public func partTwo() {
  var y = 12
  var previousBounds = bounds(at: y)
  while previousBounds.count < 100 || !isBeamAt(x: previousBounds.upperBound - 99, y: y + 99) {
    y += 1
    previousBounds = bounds(at: y, previous: previousBounds)
  }
  let result = (previousBounds.upperBound - 99) * 10_000 + y
  print(result) // 8381082
}
