//
//  Instruction.swift
//  
//
//  Created by Jake Foster on 12/11/19.
//

import Extensions

struct Instruction {
  let operation: Operation
  let inputs: [Int]
  let outputIndex: Int?
  var fieldCount: Int { operation.paramCount + 1 }
}

extension Instruction {
  init(at instructionPtr: Int, in program: [Int], memory: [Int: Int], withRelativeBase relativeBase: Int) {
    operation = Operation(opCode: program[instructionPtr])
    
    let modes = makeModes(opCode: program[instructionPtr], count: operation.paramCount)
    
    inputs = (0..<operation.inputParamCount).map { offset in
      let value = program[instructionPtr + offset + 1]
      switch modes[offset] {
        case .immediate: return value
        case .position: return program.element(at: value) ?? memory[value] ?? 0
        case .relative:
          let ptr = relativeBase + value
          return program.element(at: ptr) ?? memory[ptr] ?? 0
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
