import IntCode

public func partOne() {
  let program = input.split(separator: ",").compactMap(Int.init)


  var sum = 0
  for x in 0..<50 {
    for y in 0..<50 {
      var machine = Machine(program: program)
      let result = machine.run(initialInputs: [x, y])
      sum += result.output.first!
    }
  }
  print(sum)
}

func showLine(y: Int) -> (first: Int, last: Int) {
  let program = input.split(separator: ",").compactMap(Int.init)

  var first: Int!
  var last: Int!

  for x in 0...500 {
    var machine = Machine(program: program)
    let output = machine.run(initialInputs: [x, y]).output.first!
    print(output == 1 ? "#" : ".", terminator: "")
    if output == 1 {
      if first == nil { first = x }
      last = x
    }
  }
  print()
  return (first, last)
}

let program = input.split(separator: ",").compactMap(Int.init)

func length(at y: Int) -> Int {
  var first: Int?
  var last: Int?

  var seenLast = false
  var x = 0
  while !seenLast {
    var machine = Machine(program: program)
    let output = machine.run(initialInputs: [x, y]).output.first!
    if output == 1 {
      if first == nil { first = x }
      last = x
    } else if last != nil {
      seenLast = true
    }
    x += 1
  }
  return last! - first!
}

func bounds (at y: Int) -> ClosedRange<Int> {
  var first: Int?
  var last: Int?

  var seenLast = false
  var x = 0
  while !seenLast {
    var machine = Machine(program: program)
    let output = machine.run(initialInputs: [x, y]).output.first!
    if output == 1 {
      if first == nil { first = x }
      last = x
    } else if last != nil {
      seenLast = true
    }
    x += 1
  }
  return first!...last!
}

//public func partTwo() {
//  var matchFound = false
//
//  //var y = 1168
//  var y = 1094
//  while !matchFound {
//    let top = bounds(at: y)
//    let bottom = bounds(at: y + 100)
//    if top.upperBound - 100 >= bottom.lowerBound {
//      matchFound = true
//      print("y \(y) top \(top) bottom \(bottom)")
//      print(top.lowerBound * 10_000 + y)
//    }
//    y += 1
//  }
//}

public func partTwo() {
  var matchFound = false

  var y = 1094
  while !matchFound {
    let top = bounds(at: y)
    let bottom = bounds(at: y + 100)
    if bottom.lowerBound + 100 <= top.upperBound {
      matchFound = true
      print("y \(y) top \(top) bottom \(bottom)")
      print(top.lowerBound * 10_000 + y) // not 8481095 or 7771095 (too high)
    }
    y += 1
  }
}

//public func partTwo() {
//  let program = input.split(separator: ",").compactMap(Int.init)
//
//  var firstBottom: (Int, Int)?
//  var lastBottom: (Int, Int)?
//
//  var firstTop: (Int, Int)?
//  var lastTop: (Int, Int)?
//
//
//  var firstOnLine: (Int, Int)?
//  var lastOnLine: (Int, Int)?
//  for y in 50..<150 {
//    firstOnLine = nil
//    lastOnLine = nil
//    for x in 50..<150 {
//      var machine = Machine(program: program)
//      let result = machine.run(initialInputs: [x, y])
//      if result.output.first == 1 && firstOnLine == nil {
//        firstOnLine = (x, y)
//      }
//      if result.output.first == 1 {
//        lastOnLine = (x, y)
//      }
//    }
//    if firstOnLine != nil && firstBottom == nil {
//      firstBottom = firstOnLine
//    }
//    if lastOnLine != nil && firstTop == nil {
//      firstTop = lastOnLine
//    }
//  }
//
//  lastBottom = firstOnLine
//  lastTop = lastOnLine
//
//  print("bottom line goes from \(firstBottom!) to \(lastBottom!)")
//  print("top line goes from \(firstTop!) to \(lastTop!)")
//
//}
