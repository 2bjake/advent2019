import Foundation
import simd

extension Array where Element == SIMD3<Int32> {
    static func &+= (lhs: inout Self, rhs: Self) {
        for i in 0..<lhs.count {
            lhs[i] &+= rhs[i]
        }
    }
}

var posMatrix: [simd_int3] = [.init(x: -13, y: -13, z: -13),
                              .init(x: 5, y: -8, z: 3),
                              .init(x: -6, y: -10, z: -3),
                              .init(x: 0, y: 5, z: -5)]

var velMatrix: [simd_int3] = [.zero, .zero, .zero, .zero]

func update() {
    var velChange = [simd_int3.zero, .zero, .zero, .zero]
    for i in 0..<4 {
        for j in 1...3 {
            let diff = posMatrix[(i + j) % 4] &- posMatrix[i]
            velChange[i] &+= (diff &>> 31) &- ((0 &- diff) &>> 31)
        }
    }
    velMatrix &+= velChange
    posMatrix &+= velMatrix
}

public func partOne() {
    for _ in 0..<1000 {
        update()
    }

    var energy: Int32 = 0
    for i in 0..<4 {
        energy += reduce_add(abs(posMatrix[i])) * reduce_add(abs(velMatrix[i]))
    }
    print(energy) // 8044
}

//let initialXPos = [-13, 5, -6, 0]
//let initalVel = [0, 0, 0, 0]
//
//var xs = initialXPos
//var xvs = initalVel


func cycleSteps(initialPos: [Int], initialVel: [Int] = [0,0,0,0]) -> Int {
    var curPos = initialPos
    var curVel = initialVel
    var steps = 0
    while true {
        steps += 1
        for i in 0..<4 {
            for j in 1...3 {
                let diff = curPos[(i + j) % 4] - curPos[i]
                curVel[i] += (diff >> 31) - (-diff >> 31)
            }
        }

        for i in 0..<4 {
            curPos[i] += curVel[i]
        }

        if curPos == initialPos && curVel == initialVel {
            break
        }
    }
    return(steps)
}

//var posMatrix: [simd_int3] = [.init(x: -13, y: -13, z: -13),
//                              .init(x: 5, y: -8, z: 3),
//                              .init(x: -6, y: -10, z: -3),
//                              .init(x: 0, y: 5, z: -5)]

//print(cycleSteps(initialPos: [-13, 5, -6, 0])) //268296
//print(cycleSteps(initialPos: [-13, -8, -10, 5])) //231614
public func partTwo() {
  print(cycleSteps(initialPos: [-13, 3, -3, -5])) //23326
}

