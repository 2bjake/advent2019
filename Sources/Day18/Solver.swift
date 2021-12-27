import Extensions

private struct Path: Hashable {
  var from: Position
  var to: Position

  var reversed: Path { .init(from: to, to: from) }
}


private var distanceCache = [Path: Int]()
struct Solver {
  private let keysToPositions: [Item: Position]
  private let entrance: LocatedItem
  private let grid: [[Item]]
  private let itemToDependants: [Item: Set<Item>]

  init(_ grid: [[Item]]) {
    self.grid = grid

    var entrance: LocatedItem!
    var keysToPositions: [Item: Position] = [:]
    for pos in grid.allPositions {
      let item = grid[pos]
      switch item {
        case .entrance: entrance = LocatedItem(item: .entrance, position: pos)
        case .key: keysToPositions[item] = pos
        default: break
      }
    }
    self.entrance = entrance
    self.keysToPositions = keysToPositions

    var itemToDependency = Self.buildDependencyGraph(grid: grid, entrance: entrance)
    // remove doors
    itemToDependency = itemToDependency.mapValues {
      guard let key = $0.matchingKey else { return $0 }
      return key
    }
    itemToDependency = itemToDependency.filter { k, _ in !k.isDoor }
    self.itemToDependants = Dictionary(grouping: itemToDependency, by: \.value).mapValues { Set($0.map(\.key)) }
  }

  func distance(from start: Position, to end: Position, cost: Int = 0, visited: Set<Position> = []) -> Int? {
    guard !grid[end].isWall else { fatalError() }
    guard start != end else { return cost }
    guard !grid[start].isWall else { return nil }

    for pos in grid.adjacentPositions(of: start) where !pos.isIn(visited) {
      if let result = distance(from: pos, to: end, cost: cost + 1, visited: visited.inserting(start)) {
        return result
      }
    }
    return nil
  }

  func distanceWithCache(from start: Position, to end: Position, cost: Int = 0, visited: Set<Position> = []) -> Int? {
    let path = Path(from: start, to: end)
    if distanceCache[path] == nil {
      distanceCache[path] = distance(from: start, to: end, cost: cost, visited: visited)
    }
    return distanceCache[path]!
  }


//  func distance(from start: Position, to end: Position, cost: Int = 0, visited: Set<Position> = []) -> Int? {
//    guard !grid[end].isWall else { fatalError() }
//    guard start != end else { return cost }
//    guard !grid[start].isWall else { return nil }
//
//    if distanceCache[[start, end]] == nil {
//      let value: Int? = {
//        for pos in grid.adjacentPositions(of: start) where !pos.isIn(visited) {
//          if let result = distance(from: pos, to: end, cost: cost + 1, visited: visited.inserting(start)) {
//            return result
//          }
//        }
//        return nil
//      }()
//
//      if value != nil {
//        distanceCache[[start, end]] = value
//        distanceCache[[end, start]] = value
//      }
//    }
//    return distanceCache[[start, end]]
//  }

  private func shortestPath(from start: Position, frontier: Set<Item>, remainingKeys: Set<Item>) -> Int {
    print("finding shortest from \(grid[start]) with frontier \(frontier) with \(remainingKeys.count) keys left")
    guard frontier.notEmpty else {
      return 0
    }

    var shortest = Int.max
    for key in frontier {
      let pos = keysToPositions[key]!
      let newFrontier = frontier.subtracting(key).union(itemToDependants[key] ?? [])
      let newRemainingKeys = remainingKeys.subtracting(key)
      let newDistance = distanceWithCache(from: start, to: pos)! + shortestPath(from: pos, frontier: newFrontier, remainingKeys: newRemainingKeys)
      shortest = min(shortest, newDistance)
    }
    return shortest
  }

  func shortestPath() -> Int {
    let allKeys = Set(keysToPositions.keys)
    return shortestPath(from: entrance.position, frontier: itemToDependants[.entrance]!, remainingKeys: allKeys)
  }

  private static func buildDependencyGraph(grid: [[Item]], entrance: LocatedItem) -> [Item: Item] {
    var itemToDependency = [Item: Item]()
    var visited = Set<Position>()
    var frontier = [entrance]
    var grid = grid
    while frontier.notEmpty {
      let door = frontier.removeLast()
      grid[door.position] = .passage

      let reachable = reachableItems(in: grid, from: door.position, visited: &visited)
      for item in reachable {
        itemToDependency[item.item] = door.item
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
        items.append(LocatedItem(item: currentItem, position: currentPos))
      }

      if !currentItem.isBlocking {
        let newPositions = grid.adjacentPositions(of: currentPos).filter { !$0.isIn(visited) }
        frontier.append(contentsOf: newPositions)
      }
    }
    return items
  }
}
