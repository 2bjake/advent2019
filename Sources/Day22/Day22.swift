import Algorithms

enum Technique {
  case reverse
  case cut(Int)
  case increment(Int)
}

extension Technique {
  init(_ source: Substring) {
    let parts = source.split(separator: " ")
    guard let value = Int(parts.last!) else {
      self = .reverse
      return
    }

    if parts.first == "cut" {
      self = .cut(value)
    } else {
      self = .increment(value)
    }
  }
}

func shuffle(_ deck: inout [Int], with techniques: [Technique]) {
  for technique in techniques {
    switch technique {
      case .reverse:
        deck.reverse()
      case .cut(var value):
        if value < 0 { value += deck.count }
        deck.rotate(toStartAt: value)
      case .increment(let value):
        var newDeck = Array(repeating: 0, count: deck.count)
        var idx = 0
        for card in deck {
          newDeck[idx] = card
          idx = (idx + value) % deck.count
        }
        deck = newDeck
    }
  }
}

public func partOne() {
  var deck = Array(0...10006)

  shuffle(&deck, with: input.map(Technique.init))
  print(deck.firstIndex(of: 2019)!)
}

public func partTwo() {

}
