//
//  Machine.swift
//  
//
//  Created by Jake Foster on 12/11/19.
//

public struct Machine {
  public enum Result {
    case halted([Int])
    case inputNeeded([Int])

    public var output: [Int] {
      switch self {
        case .halted(let output), .inputNeeded(let output):
          return output
      }
    }
  }

  private var program: [Int]
  private var memory: [Int: Int] = [:]
  private var instructionPtr = 0
  private var relativeBase = 0
  public var outputWatcher: ((Int) -> Void)?
  public private(set) var isHalted = false

  public init(program: [Int]) {
    self.program = program
  }

  public mutating func run(input: Int) -> Result {
    run(initialInputs: [input])
  }

  public mutating func run(initialInputs: [Int] = []) -> Result {
    guard !program.isEmpty else { fatalError() }
    var initialInputs = initialInputs
    var outputs = [Int]()
    while true {
      let instruction = Instruction(at: instructionPtr, in: program, memory: memory, withRelativeBase: relativeBase)
      let inputs = instruction.inputs

      var result: Int?
      var jumpPointer: Int?

      switch instruction.operation {
        case .add:
          result = inputs[0] + inputs[1]
        case .multiply:
          result = inputs[0] * inputs[1]
        case .input:
          guard !initialInputs.isEmpty else { return .inputNeeded(outputs) }
          result = initialInputs.removeFirst()
        case .output:
          outputs.append(inputs[0])
          outputWatcher?(inputs[0])
        case .jumpIfTrue:
          jumpPointer = inputs[0] != 0 ? inputs[1] : nil
        case .jumpIfFalse:
          jumpPointer = inputs[0] == 0 ? inputs[1] : nil
        case .lessThan:
          result = inputs[0] < inputs[1] ? 1 : 0
        case .equals:
          result = inputs[0] == inputs[1] ? 1 : 0
        case .adjustRelativeBase:
          relativeBase += inputs[0]
        case .halt:
          isHalted = true
          return .halted(outputs)
      }

      if let result = result, let resultIndex = instruction.outputIndex {
        if program.indices.contains(resultIndex) {
          program[resultIndex] = result
        } else {
          memory[resultIndex] = result
        }
      }

      if let jumpPointer = jumpPointer {
        instructionPtr = jumpPointer
      } else {
        instructionPtr += instruction.fieldCount
      }
    }
  }
}
