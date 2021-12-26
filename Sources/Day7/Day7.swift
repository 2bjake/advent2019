import Algorithms

enum Mode: Int {
    case position = 0
    case immediate = 1
}

func makeModes(opCode: Int, count: Int) -> [Mode] {
    var result = [Mode]()
    var modeValue = opCode / 100

    for _ in 0..<count {
        guard let mode = Mode(rawValue: modeValue % 10) else { fatalError() }
        result.append(mode)
        modeValue /= 10
    }
    return result
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

func run(_ program: [Int], initialInputs: [Int]) -> Int {
    guard !program.isEmpty else { fatalError() }
    var initialInputs = initialInputs
    var program = program
    var instructionPtr = 0
    var finalResult: Int?
    while true {
        let instruction = Instruction(at: instructionPtr, in: program)
        let inputs = instruction.inputs

        var output: Int?
        var jumpPointer: Int?

        switch instruction.operation {
        case .add: output = inputs[0] + inputs[1]

        case .multiply: output = inputs[0] * inputs[1]

        case .input: output = initialInputs.removeFirst()

        case .output: finalResult = inputs[0]

        case .jumpIfTrue: jumpPointer = inputs[0] != 0 ? inputs[1] : nil

        case .jumpIfFalse: jumpPointer = inputs[0] == 0 ? inputs[1] : nil

        case .lessThan: output = inputs[0] < inputs[1] ? 1 : 0

        case .equals: output = inputs[0] == inputs[1] ? 1 : 0

        case .halt: return finalResult!
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
  var maxResult: Int?
  Set(0...4).permutations().forEach { values in
    var input = 0
    values.forEach {
      input = run(data, initialInputs: [$0, input])
    }
    if let maxValue = maxResult {
      maxResult = input > maxValue ? input : maxValue
    } else {
      maxResult = input
    }
  }

  print(maxResult!) //79723
}

class Amplifier {
    enum Result {
        case halted
        case output(Int)
    }

    var program: [Int]
    let phaseSetting: Int
    var isHalted = false
    var hasStarted = false
    var lastOutput: Int?
    var instructionPtr = 0

    init(program: [Int], phaseSetting: Int) {
        self.program = program
        self.phaseSetting = phaseSetting
    }

    func run(input: Int) -> Result {
        var initialInputs = [Int]()
        if !hasStarted {
            initialInputs.append(phaseSetting)
            hasStarted = true
        }
        initialInputs.append(input)

        let result = execute(initialInputs: initialInputs)
        recordResult(result)
        return result
    }

    private func recordResult(_ result: Result) {
        switch result {
        case .halted:
            isHalted = true
        case let .output(value):
            lastOutput = value
        }
    }

    private func execute(initialInputs: [Int]) -> Result {
        guard !program.isEmpty else { fatalError() }
        var initialInputs = initialInputs
        while true {
            let instruction = Instruction(at: instructionPtr, in: program)
            let inputs = instruction.inputs

            var output: Int?
            var jumpPointer: Int?

            switch instruction.operation {
            case .add: output = inputs[0] + inputs[1]

            case .multiply: output = inputs[0] * inputs[1]

            case .input: output = initialInputs.removeFirst()

            case .output:
                instructionPtr += instruction.fieldCount
                return .output(inputs[0])

            case .jumpIfTrue: jumpPointer = inputs[0] != 0 ? inputs[1] : nil

            case .jumpIfFalse: jumpPointer = inputs[0] == 0 ? inputs[1] : nil

            case .lessThan: output = inputs[0] < inputs[1] ? 1 : 0

            case .equals: output = inputs[0] == inputs[1] ? 1 : 0

            case .halt: return .halted
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
}

func makeRunner(program: [Int]) -> ([Int]) -> Int {
    return { phaseSettings in
        let amps = phaseSettings.map { Amplifier(program: program, phaseSetting: $0) }
        var idx = 0
        var curOutput = 0
        while true {
            let result = amps[idx].run(input: curOutput)
            switch result {
            case .halted: return curOutput
            case let .output(output): curOutput = output
            }
            idx = (idx + 1) % amps.count
        }
    }
}

public func partTwo() {
  let run = makeRunner(program: data)

  let max = Set(5...9).permutations().map(run).max()
  print(max!) //70602018
}


