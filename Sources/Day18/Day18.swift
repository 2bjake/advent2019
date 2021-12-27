import Algorithms
import Extensions

func printDependencies(_ dependencies: [Item: [Item]], dependency: Item) {
  let items = dependencies[dependency] ?? []
  for item in items {
    print("\(dependency) -> \(item);")
  }

  for item in items {
    printDependencies(dependencies, dependency: item)
  }

}

public func partOne() {
  let grid = input.map { Array($0).map(Item.init) }

  var solver = Solver(grid)
  print(solver.shortestPath())
}

public func partTwo() {

}
