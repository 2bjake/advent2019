//
//  Operation.swift
//  
//
//  Created by Jake Foster on 12/11/19.
//

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
