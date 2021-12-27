import Extensions

enum Item: Hashable {
  case wall
  case entrance
  case passage
  case key(Character)
  case door(Character)
}

extension Item: CustomStringConvertible {
  var description: String {
    switch self {
      case .wall: return "#"
      case .entrance: return "@"
      case .passage: return "."
      case .key(let char): return String(char)
      case .door(let char): return String(char)
    }
  }
}

extension Item {
//  var letter: Character? {
//    switch self {
//      case .key(let char), .door(let char): return char
//      default: return nil
//    }
//  }

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

  var isEntrance: Bool {
    if case .entrance = self { return true }
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
      case "@": self = .entrance
      case ".": self = .passage
      case "a"..."z": self = .key(source)
      case "A"..."Z": self = .door(source)
      default: fatalError()
    }
  }
}

struct LocatedItem: Hashable {
  var item: Item
  var position: Position
}
