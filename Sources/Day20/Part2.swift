import Extensions

struct Space {
  enum Kind: Equatable {
    case passage
    case exit
    case wall
    case downPortal(Character)
    case upPortal(Character)

    var portalChar: Character? {
      switch self {
        case .upPortal(let char), .downPortal(let char): return char
        default: return nil
      }
    }
  }

  var kind: Kind
}

extension Space {
  func isPassable(currentDepth: Int, maxDepth: Int) -> Bool {
    switch kind {
      case .passage: return true
      case .exit: return currentDepth == 0
      case .wall: return false
      case .downPortal: return currentDepth < maxDepth
      case .upPortal: return currentDepth != 0
    }
  }

  var isUpPortal: Bool {
    if case .upPortal = kind { return true }
    return false
  }

  var isDownPortal: Bool {
    if case .downPortal = kind { return true }
    return false
  }

  var isPortal: Bool { isUpPortal || isDownPortal }
}

extension Space: CustomStringConvertible {
  var description: String {
    switch self.kind {
      case .exit: return "*"
      case .wall: return "#"
      case .passage: return "."
      case .downPortal(let char), .upPortal(let char): return String(char)
    }
  }
}

extension Space {
  init(_ source: Character, isOnOuterEdge: Bool) {
    switch source {
      case "1", "2": kind = .exit
      case "#", " ": kind = .wall
      case ".": kind = .passage
      default: kind = isOnOuterEdge ? .upPortal(source) : .downPortal(source)
    }
  }
}

func makeGrid() -> [[Space]] {
  let charGrid = input.map(Array.init)
  var spaceGrid = charGrid.map{ $0.map { _ in Space(kind: .passage) } }

  for pos in charGrid.allPositions {
    let isOnOuterEdge = pos.row == 0 || pos.row == charGrid.numberOfRows - 1 || pos.col == 0 || pos.col == charGrid.numberOfColumns - 1
    spaceGrid[pos] = Space(charGrid[pos], isOnOuterEdge: isOnOuterEdge)
  }
  return spaceGrid
}

private var grid = makeGrid()
let matchingPortalPositions = setUpPortals()

private func setUpPortals() -> [Position: Position] {
  let portalsByChar: [Character: [Position]] = grid.allPositions.reduce(into: [:]) { result, pos in
    if let char = grid[pos].kind.portalChar {
      result[char, default: []].append(pos)
    }
  }

  let matchingPortalPositions: [Position: Position] = portalsByChar.values.reduce(into: [:]) { result, pair in
    result[pair[0]] = pair[1]
    result[pair[1]] = pair[0]
  }
  return matchingPortalPositions
}

private func passableNeighbors(of location: Location, maxDepth: Int) -> [Location] {
  let positions = grid.adjacentPositions(of: location.position).filter { grid[$0].isPassable(currentDepth: location.depth, maxDepth: maxDepth) }
  return positions.map { Location(position: $0, depth: location.depth) }
}

enum PathResult {
  case success(Int)
  case failure
}

func bestOf(_ a: PathResult, b: PathResult) -> PathResult {
  switch (a, b) {
    case (.success, .failure): return a
    case (.success(let aCount), .success(let bCount)) where aCount < bCount: return a
    default: return b
  }
}

func findPath(fromPortal start: Location, to end: Location, visited: Set<Location>, maxDepth: Int, maxCount: Int, count: Int) -> PathResult {
  let otherPosition = matchingPortalPositions[start.position]!
  let otherDepth = grid[start.position].isUpPortal ? start.depth - 1 : start.depth + 1
  let otherLocation = Location(position: otherPosition, depth: otherDepth)

  let portalExit = passableNeighbors(of: otherLocation, maxDepth: maxDepth).only!
  return findPath(from: portalExit, to: end, visited: [otherLocation], maxDepth: maxDepth, maxCount: maxCount, count: count)
}

private func findPath(from start: Location, to end: Location, visited: Set<Location>, maxDepth: Int, maxCount: Int, count: Int) -> PathResult {
  guard count < maxCount else { return .failure }
  guard start != end else {
    return .success(count)
  }

  guard !grid[start.position].isPortal else {
    return findPath(fromPortal: start, to: end, visited: visited, maxDepth: maxDepth, maxCount: maxCount, count: count)
  }

  let newVisted = visited.inserting(start)
  let neighborLocations = passableNeighbors(of: start, maxDepth: maxDepth).filter { $0.notIn(newVisted) }

  var bestResult = PathResult.failure
  for neighborLoc in neighborLocations {
    let newResult = findPath(from: neighborLoc, to: end, visited: newVisted, maxDepth: maxDepth, maxCount: maxCount, count: count + 1)
    bestResult = bestOf(bestResult, b: newResult)
  }
  return bestResult
}

struct Location: Hashable {
  var position: Position
  var depth: Int
}

public func partTwo() {
  let exits = grid.allPositions.filter { grid[$0].kind == .exit }.map { Location(position: $0, depth: 0) }
  let result = findPath(from: exits[0], to: exits[1], visited: [], maxDepth: 25, maxCount: 6000, count: 0)
  if case .success(let value) = result {
    print("path found: \(value - 2) steps") // 5350
  } else {
    print("no path found")
  }
}
