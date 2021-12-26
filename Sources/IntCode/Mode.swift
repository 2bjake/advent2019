//
//  Mode.swift
//  
//
//  Created by Jake Foster on 12/11/19.
//

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
