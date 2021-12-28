import Extensions
import Algorithms

private struct Path: Hashable {
  var from: Position
  var to: Position

  var reversed: Path { .init(from: to, to: from) }
}


private var distanceCache = [Path: Int]()
struct FirstSolver {
  private let entrance: LocatedItem
  private let grid: [[Item]]
  private let itemToDependants: [LocatedItem: Set<LocatedItem>]

  init(_ grid: [[Item]]) {
    self.grid = grid

    var entrance: LocatedItem!
    var keysToPositions: [Item: Position] = [:]
    for pos in grid.allPositions {
      let item = grid[pos]
      switch item {
        case .vaultEntrance: entrance = LocatedItem(item: .vaultEntrance, position: pos, quadrant: .center)
        case .key: keysToPositions[item] = pos
        default: break
      }
    }
    self.entrance = entrance

    var itemToDependency = Self.buildDependencyGraph(grid: grid, entrance: entrance)
    // remove doors
    itemToDependency = itemToDependency.mapValues {
      guard let key = $0.item.matchingKey else { return $0 }
      return LocatedItem(item: key, position: keysToPositions[key]!, numberOfRows: grid.numberOfRows, numberOfColumns: grid.numberOfColumns)
    }
    itemToDependency = itemToDependency.filter { k, _ in !k.item.isDoor }
    self.itemToDependants = Dictionary(grouping: itemToDependency, by: \.value).mapValues { Set($0.map(\.key)) }
  }

  func distance(from start: Position, to end: Position, cost: Int, visited: Set<Position> = []) -> Int? {
    guard !grid[end].isWall else { fatalError() }
    guard start != end else { return cost }
    guard !grid[start].isWall else { return nil }

    func score(_ pos: Position) -> Int {
      abs(pos.row - end.row) + abs(pos.col - end.col)
    }

    let adjacentPositions = grid.adjacentPositions(of: start).filter { !$0.isIn(visited) }.sorted { score($0) < score($1) }

    for pos in adjacentPositions {
      if let result = distance(from: pos, to: end, cost: cost + 1, visited: visited.inserting(start)) {
        return result
      }
    }
    return nil
  }

  func distanceWithCache(from start: Position, to end: Position, visited: Set<Position> = []) -> Int? {
    let path = Path(from: start, to: end)
    if distanceCache[path] == nil {
      distanceCache[path] = distance(from: start, to: end, cost: 0, visited: visited)
    }
    return distanceCache[path]!
  }

  private func findShortestPath(from start: LocatedItem, previousCost: Int, previousFrontier: Set<LocatedItem>, previouslyVisited: Set<LocatedItem>, shortestPath: Int) -> Int {
    //print("finding shortest from \(grid[start]) with frontier \(frontier) with \(remainingKeys.count) keys left")
    let visited = previouslyVisited.inserting(start)
    let dependants = itemToDependants[start, default: []]
    var frontier = Array(previousFrontier.union(dependants).filter { !$0.isIn(visited) })
    _ = frontier.partition { $0.quadrant != start.quadrant  }

    guard frontier.notEmpty else {
      return previousCost
    }

    var shortestPath = shortestPath
    for key in frontier {
      let totalPathCost = previousCost + distanceWithCache(from: start.position, to: key.position)!
      guard totalPathCost < shortestPath else { continue }
      let newPathCost = findShortestPath(from: key, previousCost: totalPathCost, previousFrontier: Set(frontier), previouslyVisited: visited, shortestPath: shortestPath)
      if newPathCost < shortestPath {
        shortestPath = newPathCost
        print("shortest path found: \(shortestPath)") // not 5986
      }
    }
    return shortestPath
  }

  func findShortestPath() -> Int {
    return findShortestPath(from: entrance, previousCost: 0, previousFrontier: [], previouslyVisited: [], shortestPath: Int.max)
  }

  private static func buildDependencyGraph(grid: [[Item]], entrance: LocatedItem) -> [LocatedItem: LocatedItem] {
    var itemToDependency = [LocatedItem: LocatedItem]()
    var visited = Set<Position>()
    var frontier = [entrance]
    var grid = grid
    while frontier.notEmpty {
      let door = frontier.removeLast()
      grid[door.position] = .passage

      let reachable = reachableItems(in: grid, from: door.position, visited: &visited)
      for item in reachable {
        itemToDependency[item] = door
      }
      frontier.append(contentsOf: reachable.filter(\.item.isDoor))
      for key in reachable.filter(\.item.isKey) {
        grid[key.position] = .passage
      }
    }
    return itemToDependency
  }

  private static func reachableItems(in grid: [[Item]], from pos: Position, visited: inout Set<Position>) -> [LocatedItem] {
    var items = [LocatedItem]()
    var frontier = [pos]

    while frontier.notEmpty {
      let currentPos = frontier.removeLast()
      visited.insert(currentPos)

      let currentItem = grid[currentPos]
      if currentItem.isKey || currentItem.isDoor {
        items.append(LocatedItem(item: currentItem, position: currentPos, numberOfRows: grid.numberOfRows, numberOfColumns: grid.numberOfColumns))
      }

      if !currentItem.isBlocking {
        let newPositions = grid.adjacentPositions(of: currentPos).filter { !$0.isIn(visited) }
        frontier.append(contentsOf: newPositions)
      }
    }
    return items
  }
}
