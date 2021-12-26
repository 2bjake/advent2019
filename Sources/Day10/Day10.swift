import simd // for atan

func astroidsForData(_ data: String) -> [Point] {
  let grid = data.split(separator: "\n").map { substr in
    substr.map { $0 }
  }

  var astroids = [Point]()
  for i in 0..<grid.count {
    for j in 0..<grid[i].count {
      if grid[j][i] == "#" {
        astroids.append(Point(x: i, y: j))
      }
    }
  }
  return astroids
}

func gcd(_ a: Int, _ b: Int) -> Int {

  func _gcd(_ a: Int, _ b: Int) -> Int {
    let c = a % b
    return c == 0 ? b : _gcd(b, c)
  }

  if a == 0 && b == 0 {
    return 1
  } else if a == 0 {
    return b
  } else if b == 0 {
    return a
  } else {
    return _gcd(a, b)
  }
}

struct Slope: Hashable {
  let run: Int
  let rise: Int

  var quadrantAngle: Double { atan(Double(abs(rise)) / Double(abs(run))) }

  init(run: Int, rise: Int) {
    let divisor = abs(gcd(rise, run))
    self.rise = rise / divisor
    self.run = run / divisor
  }
}

struct Point: Equatable {
  let x: Int
  let y: Int
}

extension Point {
  func slopeTo(_ other: Point) -> Slope {
    Slope(run: other.x - x, rise: y - other.y)
  }

  func distanceTo(_ other: Point) -> Int {
    abs(x - other.x) + abs(y - other.y)
  }
}

public func partOne() {
  let astroids = astroidsForData(input)
  let viewCounts: [(astroid: Point, viewCount: Int)] = astroids.map { candidate in
    var viewingSlopes = Set<Slope>()
    astroids.forEach { other in
      if candidate != other {
        viewingSlopes.insert(candidate.slopeTo(other))
      }
    }
    return (candidate, viewingSlopes.count)
  }

  let max = viewCounts.max { $0.viewCount < $1.viewCount }

  print(max!) // (astroid: Day10.Point(x: 23, y: 19), viewCount: 278)
}

enum Region: CaseIterable {
  case up, upperRight, right, lowerRight, down, lowerLeft, left, upperLeft

  static func region(for slope: Slope) -> Region {
    switch (slope.rise, slope.run) {
      case let (0, run): return run > 0 ? .right : .left
      case let (rise, 0): return rise > 0 ? .up : .down
      case let (rise, run):
        if rise > 0 {
          return run > 0 ? .upperRight : .upperLeft
        } else {
          return run > 0 ? .lowerRight : .lowerLeft
        }
    }
  }
}

extension Sequence {
  func sorted<V: Comparable>(by keyPath: KeyPath<Self.Element, V>) -> [Self.Element] {
    return sorted {
      $0[keyPath: keyPath] < $1[keyPath: keyPath]
    }
  }
}

func part2(astroids: [Point], station: Point) {
  let slopeToNearestAstroid: [Slope: Point] = astroids.reduce(into: [:]) { result, astroid in
    guard astroid != station else { return }
    let slope = station.slopeTo(astroid)
    if station.distanceTo(astroid) <= station.distanceTo(result[slope] ?? astroid) {
      result[slope] = astroid
    }
  }

  let regionToSlopes: [Region: [Slope]] = slopeToNearestAstroid.keys.reduce(into: [:]) { result, slope in
    let region = Region.region(for: slope)
    result[region, default: []].append(slope)

  }

  var remaining = 200
  var finalRegion: Region?

  for region in Region.allCases {
    if let slopes = regionToSlopes[region], slopes.count < remaining {
      remaining -= slopes.count
    } else {
      finalRegion = region
      break
    }
  }

  if let finalRegion = finalRegion, let slopes = regionToSlopes[finalRegion] {
    let sortedSlopes = slopes.sorted(by: \.quadrantAngle)
    let finalSlope = sortedSlopes[remaining - 1]
    print(slopeToNearestAstroid[finalSlope]!) //Point(x: 14, y: 17)
  }
}

public func partTwo() {
  part2(astroids: astroidsForData(input), station: Point(x: 23, y: 19))
}
