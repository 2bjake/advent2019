import Extensions
import Algorithms

struct Path: Hashable {
  var from: LocatedItem
  var to: LocatedItem

  var reversed: Path { .init(from: to, to: from) }
}

struct Section {
  let entrance: LocatedItem
  let keys: Set<LocatedItem>
  let distances: [Path: Int]


  func distance(from start: LocatedItem, to end: LocatedItem) -> Int {
    guard start.quadrant == end.quadrant else { fatalError() }
    return distances[Path(from: start, to: end)]!
  }

  func distanceToEntrance(from start: LocatedItem) -> Int {
    distance(from: start, to: entrance)
  }
}

extension Section {
  init(entrance: LocatedItem, keys: Set<LocatedItem>, grid: [[Item]]) {
    self.entrance = entrance
    self.keys = keys

    let centerPaths = centerPaths(adjacentTo: entrance)
    var distances = [Path: Int]()

    distances = keys.inserting(entrance).combinations(ofCount: 2).reduce(into: [:]) { result, pair in
      let distance = findDistance(in: grid, from: pair[0].position, to: pair[1].position, cost: 0, visited: centerPaths)!
      let path = Path(from: pair[0], to: pair[1])
      result[path] = distance
      result[path.reversed] = distance
    }
    self.distances = distances
  }
}

private func centerPaths(adjacentTo entrance: LocatedItem) -> Set<Position> {
  let pos = entrance.position
  switch entrance.quadrant {
    case .upperLeft: return [pos.moved(.right), pos.moved(.down)]
    case .upperRight: return [pos.moved(.left), pos.moved(.down)]
    case .lowerLeft: return [pos.moved(.right), pos.moved(.up)]
    case .lowerRight: return [pos.moved(.left), pos.moved(.up)]
    case .center: fatalError()
  }
}


private func findDistance(in grid: [[Item]], from start: Position, to end: Position, cost: Int, visited: Set<Position>) -> Int? {
  guard !grid[end].isWall else { fatalError() }
  guard start != end else { return cost }
  guard !grid[start].isWall else { return nil }

  func score(_ pos: Position) -> Int {
    abs(pos.row - end.row) + abs(pos.col - end.col)
  }

  let adjacentPositions = grid.adjacentPositions(of: start).filter { !$0.isIn(visited) }.sorted { score($0) < score($1) }

  for pos in adjacentPositions {
    if let result = findDistance(in: grid, from: pos, to: end, cost: cost + 1, visited: visited.inserting(start)) {
      return result
    }
  }
  return nil
}
