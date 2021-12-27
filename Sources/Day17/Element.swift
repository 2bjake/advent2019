enum Element: Character {
  case scaffold = "#"
  case empty = "."
  case up = "^"
  case down = "v"
  case left = "<"
  case right = ">"
  case falling = "X"
}

extension Element {
  init?(_ source: Int) {
    self.init(rawValue: Character(UnicodeScalar(source)!))
  }
}

func print(_ grid: [[Element]]) {
  for line in grid {
    print(String(line.map(\.rawValue)))
  }
}

func buildPicture(_ output: [Int]) -> [[Element]] {
  output.map(Element.init).split(separator: nil).map { Array($0.compacted()) }
}

func printPicture(_ output: [Int]) {
  print(buildPicture(output))
}

