import Extensions

private struct PartOneSpace {
  enum Kind: Equatable {
    case passage
    case exit
    case wall
    case portal(Character)

    var isPassable: Bool { self != .wall }
  }

  var kind: Kind
  var neighbors: [Position] = []
}

extension PartOneSpace: CustomStringConvertible {
  var description: String {
    switch self.kind {
      case .exit: return "*"
      case .wall: return "#"
      case .passage: return "."
      case .portal(let char): return String(char)
    }
  }
}

extension PartOneSpace {
  init(_ source: Character) {
    switch source {
      case "1", "2": kind = .exit
      case "#", " ": kind = .wall
      case ".": kind = .passage
      default: kind = .portal(source)
    }
  }
}

private var grid = input.map { $0.map(PartOneSpace.init) }

private func passableNeighbors(of position: Position) -> [Position] {
  grid.adjacentPositions(of: position).filter { grid[$0].kind.isPassable }
}

private func setUpPortals() -> [Position: Position] {
  let portalsByChar: [Character: [Position]] = grid.allPositions.reduce(into: [:]) { result, pos in
    if case .portal(let char) = grid[pos].kind {
      result[char, default: []].append(pos)
    }
  }

  let destinationForPortalPos: [Position: Position] = portalsByChar.values.reduce(into: [:]) { result, pair in
    result[pair[0]] = passableNeighbors(of: pair[1]).only!
    result[pair[1]] = passableNeighbors(of: pair[0]).only!
  }
  return destinationForPortalPos
}

private func findStepCount(from start: Position, to end: Position, havingVisited visited: Set<Position>, withCount count: Int, shortest: Int) -> Int {
  guard start != end else { return count }

  let newVisted = visited.inserting(start)

  var shortest = shortest
  for neighbor in grid[start].neighbors where neighbor.notIn(newVisted) {
    let newCount = findStepCount(from: neighbor, to: end, havingVisited: newVisted, withCount: count + 1, shortest: shortest)
    shortest = min(shortest, newCount)
  }
  return shortest
}

public func partOne() {
  let destinationForPortalPos = setUpPortals()

  var exits = [Position]()

  for pos in grid.allPositions where grid[pos].kind == .passage || grid[pos].kind == .exit {
    if grid[pos].kind == .exit { exits.append(pos) }
    for neighbor in passableNeighbors(of: pos) {
      grid[pos].neighbors.append(destinationForPortalPos[neighbor] ?? neighbor)
    }
  }

  print(findStepCount(from: exits[0], to: exits[1], havingVisited: [], withCount: 0, shortest: Int.max) - 2) // 476
}
