import Extensions

struct Solver {
  private let vaultEntrance: LocatedItem
  private let itemToDependants: [LocatedItem: Set<LocatedItem>]
  private let quadrants: [Quadrant: Section]

  init(_ grid: [[Item]]) {
    vaultEntrance = Self.locatedItems(in: grid, matching: \.isVaultEntrance).first!
    let keys = Self.locatedItems(in: grid, matching: \.isKey)

    itemToDependants = Self.buildDependencyGraph(grid: grid, keys: keys, vaultEntrance: vaultEntrance)

    let quadrantEntrances = Self.locatedItems(in: grid, matching: \.isQuadrantEntrance)
    quadrants = quadrantEntrances.reduce(into: [:]) { result, entrance in
      let keys = Set(keys.filter { $0.quadrant == entrance.quadrant })
      result[entrance.quadrant] = Section(entrance: entrance, keys: keys, grid: grid)
    }
  }

  func findDistance(from start: LocatedItem, to end: LocatedItem) -> Int {
    if start.quadrant == end.quadrant {
      return quadrants[start.quadrant]!.distance(from: start, to: end)
    } else if start.quadrant == .center {
      return 2 + quadrants[end.quadrant]!.distanceToEntrance(from: end)
    } else {
      let firstLeg = quadrants[start.quadrant]!.distanceToEntrance(from: start)
      let lastLeg = quadrants[end.quadrant]!.distanceToEntrance(from: end)
      return firstLeg + lastLeg + distanceBetween(start.quadrant, end.quadrant)
    }
  }

  private func findShortestPath(from start: LocatedItem, previousCost: Int, previousFrontier: Set<LocatedItem>, previouslyVisited: Set<LocatedItem>, shortestPath: Int) -> Int {
    let visited = previouslyVisited.inserting(start)
    let dependants = itemToDependants[start, default: []]
    var frontier = Array(previousFrontier.union(dependants).filter { !$0.isIn(visited) })
    _ = frontier.partition { $0.quadrant != start.quadrant  }

    guard frontier.notEmpty else {
      return previousCost
    }

    var shortestPath = shortestPath
    for key in frontier {
      let totalPathCost = previousCost + findDistance(from: start, to: key)
      guard totalPathCost < shortestPath else { continue }
      let newPathCost = findShortestPath(from: key, previousCost: totalPathCost, previousFrontier: Set(frontier), previouslyVisited: visited, shortestPath: shortestPath)
      if newPathCost < shortestPath {
        shortestPath = newPathCost
        print("shortest path found: \(shortestPath)") // not 5986 or 5940
      }
    }
    return shortestPath
  }

  func findShortestPath() -> Int {
    return findShortestPath(from: vaultEntrance, previousCost: 0, previousFrontier: [], previouslyVisited: [], shortestPath: 5458)
  }
}

private func distanceBetween(_ a: Quadrant, _ b: Quadrant) -> Int {
  switch (a, b) {
    case (.upperLeft, .lowerRight), (.lowerRight, .upperLeft), (.upperRight, .lowerLeft), (.lowerLeft, .upperRight):
      return 4
    default: return 2
  }
}

extension Solver {
  private static func locatedItems(in grid: [[Item]], matching: (Item) -> Bool) -> [LocatedItem] {
    grid.allPositions.filter { matching(grid[$0]) }.map {
      LocatedItem(item: grid[$0], position: $0, numberOfRows: grid.numberOfRows, numberOfColumns: grid.numberOfColumns)
    }
  }

  private static func buildDependencyGraph(grid: [[Item]], keys: [LocatedItem], vaultEntrance: LocatedItem) -> [LocatedItem: Set<LocatedItem>] {
    let keyMap: [Item: LocatedItem] = keys.reduce(into: [:]) { result, locatedItem in
      result[locatedItem.item] = locatedItem
    }

    var itemToDependency = [LocatedItem: LocatedItem]()
    var visited = Set<Position>()
    var frontier = [vaultEntrance]
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

    // remove doors
    itemToDependency = itemToDependency
      .mapValues {
        guard let key = $0.item.matchingKey else { return $0 }
        return keyMap[key]!
      }
      .filter { k, _ in !k.item.isDoor }

    // flip to a multimap
    return Dictionary(grouping: itemToDependency, by: \.value).mapValues { Set($0.map(\.key)) }
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

  static func printDependencies(_ dependencies: [LocatedItem: Set<LocatedItem>], dependency: LocatedItem) {
    let items = dependencies[dependency] ?? []
    for item in items {
      print("\(dependency.item) -> \(item.item);")
    }

    for item in items {
      printDependencies(dependencies, dependency: item)
    }
  }
}
