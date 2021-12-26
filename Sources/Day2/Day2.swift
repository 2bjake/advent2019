func process(_ vals: [Int], noun: Int, verb: Int) -> Int {
  var vals = vals
  vals[1] = noun
  vals[2] = verb
  var i = 0
  while vals[i] != 99 {
    let op: (Int, Int) -> Int = vals[i] == 1 ? (+) : (*)
    let first = vals[vals[i + 1]]
    let second = vals[vals[i + 2]]
    vals[vals[i + 3]] = op(first, second)
    i += 4
  }
  return vals[0]
}

public func partOne() {
  print(process(input, noun: 12, verb: 2)) // 3716250
}

public func partTwo() {
  let desired = 19690720
  func find(_ vals: [Int]) -> (Int, Int) {
    for i in 0...99 {
      for j in 0...99 {
        if process(vals, noun: i, verb: j) == desired {
          return (i, j)
        }
      }
    }
    return (-1, -1)
  }
  
  let (noun, verb) = find(input)
  print(noun * 100 + verb) // 6472
}
