enum Mode: Int {
    case position = 0
    case immediate = 1
    case relative = 2
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
    case adjustRelativeBase = 9
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
        case .output, .adjustRelativeBase: return 1
        case .add, .multiply, .lessThan, .equals, .jumpIfTrue, .jumpIfFalse: return 2
        }
    }

    var hasOutputParam: Bool {
        switch self {
        case .add, .multiply, .lessThan, .equals, .input: return true
        case .output, .jumpIfTrue, .jumpIfFalse, .adjustRelativeBase, .halt: return false
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
    init(at instructionPtr: Int, in program: [Int], withRelativeBase relativeBase: Int) {
        operation = Operation(opCode: program[instructionPtr])

        let modes = makeModes(opCode: program[instructionPtr], count: operation.paramCount)

        inputs = (0..<operation.inputParamCount).map { offset in
            let value = program[instructionPtr + offset + 1]
            switch modes[offset] {
            case .immediate: return value
            case .position: return program[value]
            case .relative: return program[relativeBase + value]
            }

        }

        if operation.hasOutputParam {
            let outputOffset = program[instructionPtr + operation.paramCount]
            switch modes[operation.paramCount - 1] {
            case .immediate: fatalError()
            case .position: outputIndex = outputOffset
            case .relative: outputIndex = outputOffset + relativeBase
            }
        } else {
            outputIndex = nil
        }
    }
}

func run(_ program: [Int], initialInputs: [Int]) -> Int {
    guard !program.isEmpty else { fatalError() }
    var initialInputs = initialInputs
    var program = program
    program.append(contentsOf: Array(repeating: 0, count: 1000)) // extra space
    var relativeBase = 0
    var instructionPtr = 0
    var finalResult: Int?
    while true {
        let instruction = Instruction(at: instructionPtr, in: program, withRelativeBase: relativeBase)
        let inputs = instruction.inputs

        var output: Int?
        var jumpPointer: Int?

        switch instruction.operation {
        case .add: output = inputs[0] + inputs[1]

        case .multiply: output = inputs[0] * inputs[1]

        case .input: output = initialInputs.removeFirst()

        case .output:
            print(inputs[0])
            finalResult = inputs[0]

        case .jumpIfTrue: jumpPointer = inputs[0] != 0 ? inputs[1] : nil

        case .jumpIfFalse: jumpPointer = inputs[0] == 0 ? inputs[1] : nil

        case .lessThan: output = inputs[0] < inputs[1] ? 1 : 0

        case .equals: output = inputs[0] == inputs[1] ? 1 : 0

        case .adjustRelativeBase: relativeBase += inputs[0]

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
  _ = run(input, initialInputs: [1]) // 3780860499
}

public func partTwo() {
  _ = run(input, initialInputs: [2]) // 33343
}
