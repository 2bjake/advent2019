import Extensions

enum Item: Hashable {
  case wall
  case vaultEntrance
  case quadrantEntrance
  case passage
  case key(Character)
  case door(Character)
}

extension Item: CustomStringConvertible {
  var description: String {
    switch self {
      case .wall: return "#"
      case .vaultEntrance: return "@"
      case .quadrantEntrance: return "$"
      case .passage: return "."
      case .key(let char): return String(char)
      case .door(let char): return String(char)
    }
  }
}

extension Item {
  var matchingDoor: Item? {
    guard case .key(let keyChar) = self else { return nil }
    return .init(keyChar.uppercased())
  }

  var matchingKey: Item? {
    guard case .door(let doorChar) = self else { return nil }
    return .init(doorChar.lowercased())
  }

  var isDoor: Bool {
    if case .door = self { return true }
    return false
  }

  var isWall: Bool {
    if case .wall = self { return true }
    return false
  }

  var isKey: Bool {
    if case .key = self { return true }
    return false
  }

  var isPassage: Bool {
    if case .passage = self { return true }
    return false
  }

  var isQuadrantEntrance: Bool {
    if case .quadrantEntrance = self { return true }
    return false
  }

  var isVaultEntrance: Bool {
    if case .vaultEntrance = self { return true }
    return false
  }

  var isBlocking: Bool { isWall || isDoor }
}

extension Item {
  init(_ source: String) {
    guard source.count == 1 else { fatalError() }
    self.init(source.first!)
  }

  init(_ source: Character) {
    switch source {
      case "#": self = .wall
      case "@": self = .vaultEntrance
      case "$": self = .quadrantEntrance
      case ".": self = .passage
      case "a"..."z": self = .key(source)
      case "A"..."Z": self = .door(source)
      default: fatalError()
    }
  }
}

enum Quadrant {
  case upperLeft, upperRight, lowerLeft, lowerRight, center
}

struct LocatedItem: Hashable {
  var item: Item
  var position: Position
  var quadrant: Quadrant
}

extension LocatedItem {
  init(item: Item, position: Position, numberOfRows: Int, numberOfColumns: Int) {
    self.item = item
    self.position = position

    let rowMid = numberOfRows / 2
    let colMid = numberOfColumns / 2

    switch (position.row, position.col) {
      case (0..<rowMid, 0..<colMid): quadrant = .upperLeft
      case (0..<rowMid, colMid..<numberOfColumns): quadrant = .lowerLeft
      case (rowMid..<numberOfRows, 0..<colMid): quadrant = .upperRight
      case (rowMid..<numberOfRows, colMid..<numberOfColumns): quadrant = .lowerRight
      default: quadrant = .center
    }
  }
}
