import Extensions

func hasGrouping(where sizePredicate: @escaping (Int) -> Bool) -> (String) -> Bool {
  return {
    var sub = Substring($0)
    while !sub.isEmpty {
      let count = sub.count
      let first = sub.first
      while sub.first == first {
        sub = sub.dropFirst()
      }
      if sizePredicate(count - sub.count) { return true }
    }
    return false
  }
}

let passwords = (256666...699999).map(String.init).filter { $0.isSorted() }

public func partOne() {
  let hasAdjacentDuplicates = hasGrouping { $0 > 1 }
  print(passwords.filter(hasAdjacentDuplicates).count) //979
}

public func partTwo() {
  let hasAdjacentDuo = hasGrouping { $0 == 2 }
  print(passwords.filter(hasAdjacentDuo).count) //635
}

