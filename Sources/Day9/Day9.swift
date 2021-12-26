import IntCode

public func partOne() {
  var machine = Machine(program: input)
  let result = machine.run(initialInputs: [1])
  print(result.output) // 3780860499
}

public func partTwo() {
  var machine = Machine(program: input)
  let result = machine.run(initialInputs: [2])
  print(result.output) // 33343
}
