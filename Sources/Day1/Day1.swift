let masses = input.split(separator: "\n").compactMap { Int($0) }

let fuelFor = { $0 / 3 - 2 }

// part 1
public func partOne() {
  print(masses.map(fuelFor).reduce(0, +)) // 3427947
}

// part 2
public func partTwo() {
  let isPositive = { $0 > 0 }
  
  var remaining = masses
  var total = 0
  while !remaining.isEmpty {
    remaining = remaining.map(fuelFor).filter(isPositive)
    total = remaining.reduce(total, +)
  }
  print(total) // 5139037
}

