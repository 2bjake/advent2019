struct Segment {
  enum Direction { case left, right, up, down }
  let direction: Direction
  let length: Int
  init(_ str: Substring) {
    switch str.first! {
      case "U": direction = .up
      case "D": direction = .down
      case "L": direction = .left
      case "R": direction = .right
      default: direction = .up
    }
    length = Int(String(str.dropFirst()))!
  }
}

let wires = input.split(separator: "\n").map { $0.split(separator: ",").map(Segment.init) }

struct WireCoord: Hashable {
  let x: Int
  let y: Int
  let steps: Int
  
  static func == (lhs: WireCoord, rhs: WireCoord) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(x)
    hasher.combine(y)
  }
}

extension WireCoord: Comparable {
  var distance: Int { abs(x) + abs(y) }
  static func < (lhs: WireCoord, rhs: WireCoord) -> Bool {
    lhs.distance < rhs.distance
  }
}

func processWire(_ segments: [Segment]) -> Set<WireCoord> {
  var result = Set<WireCoord>()
  var curX = 0
  var curY = 0
  var steps = 0
  for segment in segments {
    for _ in 1...segment.length {
      switch segment.direction {
        case .up: curY += 1
        case .down: curY -= 1
        case .left: curX -= 1
        case .right: curX += 1
      }
      steps += 1
      result.insert(WireCoord(x: curX, y: curY, steps: steps))
    }
  }
  return result
}

let wireCoords = wires.map(processWire)

public func partOne() {
  let intersect = wireCoords[0].intersection(wireCoords[1])
  print(intersect.sorted().first!.distance) // 1431
}

public func partTwo() {
  var wire1Coords = wireCoords[0]
  var wire2Coords = wireCoords[1]
  wire1Coords.formIntersection(wire2Coords)
  wire2Coords.formIntersection(wire1Coords)
  
  var shortest: Int?
  
  for coord1 in wire1Coords {
    let coord2 = wire2Coords.first { $0 == coord1 }
    let steps = coord1.steps + coord2!.steps
    if steps <= (shortest ?? steps) { shortest = steps }
  }
  
  print(shortest!) // 48012
}
