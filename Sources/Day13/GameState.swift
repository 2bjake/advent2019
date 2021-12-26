//
//  GameState.swift
//
//
//  Created by Jake Foster on 12/13/19.
//

struct Point: Hashable {
  let x: Int
  let y: Int
}

extension Point: CustomStringConvertible {
  var description: String {
    "(\(x),\(y))"
  }
}

enum Tile: Int {
  case empty = 0
  case wall
  case block
  case paddle
  case ball
}

struct GameState {
  var turn: Int
  var score: Int
  var ballPosition: Point
  var paddlePosition: Point
  var blockPositions: Set<Point>
  var ballOutInfo: (position: Point, turn: Int)?
  var paddleHits: [(JoystickInstruction)] = []

  init() {
    turn = 0
    score = 0
    ballPosition = Point(x: 0, y: 0)
    paddlePosition = Point(x: 0, y: 0)
    blockPositions = []
  }

  private func curValues(_ slice: ArraySlice<Int>) -> (x: Int, y: Int, element: Int) {
    let xIndex = slice.startIndex
    let yIndex = slice.index(after: xIndex)
    let elementIndex = slice.index(after: yIndex)
    return (slice[xIndex], slice[yIndex], slice[elementIndex])
  }

  mutating func update(_ output: [Int]) {
    turn += 1
    var output = ArraySlice(output)
    while !output.isEmpty {
      let (x, y, element) = curValues(output.prefix(3))
      if x == -1 && y == 0 {
        score = element
      } else {
        let tile = Tile(rawValue: element)
        let position = Point(x: x, y: y)
        if tile == .block {
          blockPositions.insert(position)
        } else {
          if tile == .ball {
            ballPosition = position
            if ballPosition.y == 22 {
                ballOutInfo = (ballPosition, turn - 1)
            }
            if ballPosition.y == 21 {
              paddleHits.append((ballPosition.x, turn - 1))
            }
          } else if tile == .paddle {
            paddlePosition = position
          }
          blockPositions.remove(position)
        }

      }
      output = output.dropFirst(3)
    }
  }
}

extension GameState: CustomStringConvertible {
  var description: String {
        """
        Turn: \(turn)
        Score: \(score)
        Ball at: \(ballPosition)
        Paddle at: \(paddlePosition)
        Block count: (\(blockPositions.count))
        """
  }
}
