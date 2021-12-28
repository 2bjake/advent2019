import Algorithms
import Extensions

public func partOne() {
  let grid = input.map { Array($0).map(Item.init) }

  let solver = Solver(grid)
  print(solver.findShortestPath())
}

public func partTwo() {

}
