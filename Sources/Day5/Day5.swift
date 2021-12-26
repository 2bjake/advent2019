enum Mode { case position, immediate }

func makeModes(opCode: Int, count: Int) -> [Mode] {
  var modeStr = String(opCode).dropLast(2)
  return (0..<count).map { _ in
    let last = modeStr.last
    modeStr = modeStr.dropLast()
    return last == "1" ? .immediate : .position
  }
}

enum Operation: Int {
  case add = 1
  case multiply = 2
  case input = 3
  case output = 4
  case jumpIfTrue = 5
  case jumpIfFalse = 6
  case lessThan = 7
  case equals = 8
  case halt = 99
}

extension Operation {
  init(opCode: Int) {
    guard let op = Operation(rawValue: opCode % 100) else { fatalError() }
    self = op
  }

  var inputParamCount: Int {
    switch self {
      case .input, .halt: return 0
      case .output: return 1
      case .add, .multiply, .lessThan, .equals, .jumpIfTrue, .jumpIfFalse: return 2
    }
  }

  var hasOutputParam: Bool {
    switch self {
      case .add, .multiply, .lessThan, .equals, .input: return true
      case .output, .jumpIfTrue, .jumpIfFalse, .halt: return false
    }
  }

  var paramCount: Int { hasOutputParam ? inputParamCount + 1 : inputParamCount }
}

struct Instruction {
  let operation: Operation
  let inputs: [Int]
  let outputIndex: Int?
  var fieldCount: Int { operation.paramCount + 1 }
}

extension Instruction {
  init(at instructionPtr: Int, in program: [Int]) {
    operation = Operation(opCode: program[instructionPtr])

    let inputModes = makeModes(opCode: program[instructionPtr], count: operation.inputParamCount)
    inputs = inputModes.enumerated().map { offset, mode in
      let value = program[instructionPtr + 1 + offset]
      return mode == .immediate ? value : program[value]
    }

    outputIndex = operation.hasOutputParam ? program[instructionPtr + operation.paramCount] : nil
  }
}

func run(_ program: [Int], input: Int) {
  guard !program.isEmpty else { fatalError() }
  var program = program
  var instructionPtr = 0
  while true {
    let instruction = Instruction(at: instructionPtr, in: program)
    let inputs = instruction.inputs

    var output: Int?
    var jumpPointer: Int?

    switch instruction.operation {
      case .add: output = inputs[0] + inputs[1]
      case .multiply: output = inputs[0] * inputs[1]
      case .input: output = input
      case .output: print(inputs[0])
      case .jumpIfTrue: jumpPointer = inputs[0] != 0 ? inputs[1] : nil
      case .jumpIfFalse: jumpPointer = inputs[0] == 0 ? inputs[1] : nil
      case .lessThan: output = inputs[0] < inputs[1] ? 1 : 0
      case .equals: output = inputs[0] == inputs[1] ? 1 : 0
      case .halt: return
    }

    if let output = output, let outputIndex = instruction.outputIndex {
      program[outputIndex] = output
    }

    if let jumpPointer = jumpPointer {
      instructionPtr = jumpPointer
    } else {
      instructionPtr += instruction.fieldCount
    }
  }
}

public func partOne() {
  run(input, input: 1) // 5577461
}

public func partTwo() {
  run(input, input: 5) // 7161591
}
