import Extensions
import Foundation

func rating(of grid: [[Character]]) -> Int {
  grid.joined().enumerated().reduce(into: 0) { result, entry in
    if entry.element == "#" {
      result += Int(pow(2, Double(entry.offset)))
    }
  }
}

public func partOne() {
  var grid = input
  var knownGrids = Set<[[Character]]>()
  var match: [[Character]]?

  while match == nil {
    var newGrid = grid

    for pos in grid.allPositions {
      let neighborCount = grid.adjacentElements(of: pos).count { $0 == "#" }

      if grid[pos] == "#" && neighborCount != 1 {
        newGrid[pos] = "."
      } else if grid[pos] == "." && (neighborCount == 1 || neighborCount == 2) {
        newGrid[pos] = "#"
      }
    }
    grid = newGrid

    if grid.isIn(knownGrids) {
      match = grid
    } else {
      knownGrids.insert(grid)
    }
  }
  print(rating(of: match!)) // 18350099
}

struct Location {
  var position: Position
  var depth: Int
}

extension Location: CustomStringConvertible {
  var description: String {
    "P: (\(position.row), \(position.col)) D:\(depth)"
  }
}

extension Position {
  static let innerTop = Position(1, 2)
  static let innerBottom = Position(3, 2)
  static let innerLeft = Position(2, 1)
  static let innerRight = Position(2, 3)
  static let middle = Position(2, 2)
}

extension Location {
  func adjacentUpLocations() -> [Location] {
    var locations = [Location]()

    let upDepth = depth - 1
    if position.row == 0 {
      locations.append(Location(position: .innerTop, depth: upDepth))
    }
    if position.row == 4 {
      locations.append(Location(position: .innerBottom, depth: upDepth))
    }
    if position.col == 0 {
      locations.append(Location(position: .innerLeft, depth: upDepth))
    }
    if position.col == 4 {
      locations.append(Location(position: .innerRight, depth: upDepth))
    }
    return locations
  }

  func adjacentDownLocations() -> [Location] {
    var locations = [Location]()
    // depth + 1 adjacents
    if position == .innerTop {
      let innerLocations = (0..<5).map { Location(position: Position(0, $0), depth: depth + 1) }
      locations.append(contentsOf: innerLocations)
    }

    if position == .innerBottom {
      let innerLocations = (0..<5).map { Location(position: Position(4, $0), depth: depth + 1) }
      locations.append(contentsOf: innerLocations)
    }


    if position == .innerLeft {
      let innerLocations = (0..<5).map { Location(position: Position($0, 0), depth: depth + 1) }
      locations.append(contentsOf: innerLocations)
    }

    if position == .innerRight {
      let innerLocations = (0..<5).map { Location(position: Position($0, 4), depth: depth + 1) }
      locations.append(contentsOf: innerLocations)
    }
    return locations
  }
}

func adjacentLocations(of location: Location, in grid: [[Character]]) -> [Location] {
  var positions = grid.adjacentPositions(of: location.position)
  if let idx = positions.firstIndex(of: .middle) {
    positions.remove(at: idx)
  }

  return location.adjacentDownLocations() + location.adjacentUpLocations() + positions.map { Location(position: $0, depth: location.depth) }
}

extension Array where Element == [Character] {
  static var empty: Self {
    Array(repeating: Array<Character>(repeating: ".", count: 5), count: 5)
  }
}

struct GridStack {
  var gridByDepth: [Int: [[Character]]] = [:]
  var depthRange: ClosedRange<Int> { gridByDepth.keys.minMaxRange()! }

  var bugCount: Int {
    var count = 0
    for grid in gridByDepth.values {
      for pos in grid.allPositions {
        if grid[pos] == "#" {
          count += 1
        }
      }
    }
    return count
  }

  private func value(at location: Location) -> Character {
    gridByDepth[location.depth, default: .empty][location.position]
  }

  private func newGrid(at depth: Int) -> [[Character]] {
    let origGrid = gridByDepth[depth, default: .empty]
    var newGrid = origGrid

    for pos in origGrid.allPositions where pos != .middle {
      let neighborLocs = adjacentLocations(of: Location(position: pos, depth: depth), in: origGrid)
      let bugCount = neighborLocs.map { value(at: $0) }.count { $0 == "#" }

      if origGrid[pos] == "#" && bugCount != 1 {
        newGrid[pos] = "."
      } else if origGrid[pos] == "." && (bugCount == 1 || bugCount == 2) {
        newGrid[pos] = "#"
      }
    }
    return newGrid
  }

  func step() -> GridStack {
    var newGridByDepth = depthRange.reduce(into: [:]) { result, depth in
      result[depth] = newGrid(at: depth)
    }

    let upGrid = newGrid(at: depthRange.lowerBound - 1)
    if upGrid.allPositions.count(where: { upGrid[$0] == "#"}) > 0 {
      newGridByDepth[depthRange.lowerBound - 1] = upGrid
    }

    let downGrid = newGrid(at: depthRange.upperBound + 1)
    if downGrid.allPositions.count(where: { downGrid[$0] == "#"}) > 0 {
      newGridByDepth[depthRange.upperBound + 1] = downGrid
    }

    return GridStack(gridByDepth: newGridByDepth)
  }
}

public func partTwo() {
  var gridStack = GridStack(gridByDepth: [0: input])
  for _ in 0..<200 {
    gridStack = gridStack.step()
  }
  print(gridStack.bugCount)
}
