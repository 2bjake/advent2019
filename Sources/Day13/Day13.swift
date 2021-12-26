import IntCode

typealias JoystickInstruction = (xPos: Int, until: Int)

enum GameEndState {
  case won(Int)
  case lost([JoystickInstruction])
}

func playGame(_ program: [Int], paddlePositions: [JoystickInstruction]) -> GameEndState {
  var machine = Machine(program: program)
  var paddlePositions = paddlePositions
  var gameState = GameState()
  var input = [Int]()
  while !machine.isHalted {
    let result = machine.run(initialInputs: input)
    gameState.update(result.output)
//    print(gameState)
//    print("========")
    if case .inputNeeded = result {
      if paddlePositions.isEmpty {
        input = [-1]
      } else {
        input = [(paddlePositions[0].xPos - gameState.paddlePosition.x).signum()]
        if gameState.turn > paddlePositions[0].until {
          paddlePositions.removeFirst()
        }
      }
    }

    if gameState.blockPositions.isEmpty {
      return .won(gameState.score)
    } else if gameState.ballOutInfo != nil {
      return .lost(gameState.paddleHits)
    }
  }
  fatalError()
}

public func partOne() {
  var gameState = GameState()
  var machine = Machine(program: input)
  let result = machine.run(initialInputs: input)
  gameState.update(result.output)
  print(gameState.blockPositions.count) // 258
}

public func partTwo() {
  var freePlay = input
  freePlay[0] = 2

  var paddlePositions = [JoystickInstruction]()
  var endState = playGame(freePlay, paddlePositions: paddlePositions)
  while case .lost(let instructions) = endState {
    paddlePositions = instructions
    endState = playGame(freePlay, paddlePositions: paddlePositions)
  }
  print(endState) // 12765
}
