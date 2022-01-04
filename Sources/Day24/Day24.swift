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
  print(rating(of: match!))
}

public func partTwo() {

}
