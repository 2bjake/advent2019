import IntCode



func run(_ script: String) {
  var machine = Machine(program: input)
  let result = machine.run(initialInputs: script.map { Int($0.asciiValue!) })

  print(String(result.output.compactMap(UnicodeScalar.init).map(Character.init)))
  print(result.output.last!)
}

let firstScript = """
NOT B J
NOT C T
OR J T
AND D T
NOT A J
OR T J
WALK

"""

public func partOne() {
  run(firstScript)
}

let secondScript = """
NOT B J
NOT C T
OR J T
AND D T
NOT A J
OR T J
RUN

"""

public func partTwo() {
  run(secondScript)
}
