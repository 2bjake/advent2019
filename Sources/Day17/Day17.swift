import IntCode
import Extensions
import Algorithms

let program = input.split(separator: ",").compactMap(Int.init)

public func partOne() {
  var machine = Machine(program: program)
  let output = machine.run().output
  let grid = buildPicture(output)

  var sum = 0
  for pos in grid.allPositions where grid[pos] == .scaffold {
    if grid.adjacentElements(of: pos).allSatisfy({ $0 == .scaffold }) {
      sum += pos.row * pos.col
    }
  }
  print(sum) // 9876
}

public func partTwo() {
  var program = program
  program[0] = 2
  var machine = Machine(program: program)

//  var livePicture = [Int]()
//  machine.outputWatcher = {
//    livePicture.append($0)
//    if $0 == 10 {
//      printPicture(livePicture)
//      livePicture = []
//    }
//  }

  let routine = MovementRoutine(
    main: "A,B,A,C,B,C,B,A,C,B",
    a: "L,10,L,6,R,10",
    b: "R,6,R,8,R,8,L,6,R,8",
    c: "L,10,R,8,R,8,L,10")
//  routine.printEvaluation()

  var result: Machine.Result?
  for input in routine.intCode {
    result = machine.run(input: input)
  }
  print(result!.output.last!) // 1234055
  
}
