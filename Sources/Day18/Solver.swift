import Extensions

struct Solver {
  let vaultEntrance: LocatedItem

  init(_ grid: [[Item]]) {
    let vaultEntrancePos = grid.allPositions.filter { grid[$0].isVaultEntrance }.first!
    vaultEntrance = LocatedItem(item: .vaultEntrance, position: vaultEntrancePos, quadrant: .center)

    let dependencies = Self.buildDependencyGraph(grid: grid, vaultEntrance: vaultEntrance)
    Self.printDependencies(dependencies, dependency: vaultEntrance)
  }
}

extension Solver {
  private static func buildDependencyGraph(grid: [[Item]], vaultEntrance: LocatedItem) -> [LocatedItem: Set<LocatedItem>] {
    var itemToDependency = [LocatedItem: LocatedItem]()
    var visited = Set<Position>()
    var frontier = [vaultEntrance]
    var grid = grid

    let keysToPositions: [Item: Position] = grid.allPositions
      .filter { grid[$0].isKey }
      .reduce(into: [:]) { result, pos in
        result[grid[pos]] = pos
      }

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

    itemToDependency = itemToDependency.mapValues {
      guard let key = $0.item.matchingKey else { return $0 }
      return LocatedItem(item: key, position: keysToPositions[key]!, numberOfRows: grid.numberOfRows, numberOfColumns: grid.numberOfColumns)
    }
    itemToDependency = itemToDependency.filter { k, _ in !k.item.isDoor }
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
