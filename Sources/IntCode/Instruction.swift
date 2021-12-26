//
//  Instruction.swift
//  
//
//  Created by Jake Foster on 12/11/19.
//

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
