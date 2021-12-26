import IntCode

enum Direction: Int {
    case north = 1
    case south
    case west
    case east
}

extension Direction: CaseIterable { }

extension Direction {
    var next: Direction {
        switch self {
        case .north: return .east
        case .east: return .south
        case .south: return .west
        case .west: return .north
        }
    }

    var prev: Direction {
        switch self {
        case .north: return .west
        case .west: return .south
        case .south: return .east
        case .east: return .north
        }
    }
}

enum Result: Int {
    case hitWall = 0
    case moved
    case movedToOxygenSensor
}

extension Result {
    var didMove: Bool { self == .movedToOxygenSensor || self == .moved }
}

struct Point {
    var x: Int
    var y: Int
}

extension Point: Hashable { }

extension Point {
    func afterMove(_ direction: Direction) -> Point {
        switch direction {
        case .north: return Point(x: x, y: y + 1)
        case .south: return Point(x: x, y: y - 1)
        case .west: return Point(x: x - 1, y: y)
        case .east: return Point(x: x + 1, y: y)
        }
    }
}

struct Robot {
    var brain = Machine(program: input)
    var position = Point(x: 20, y: 20)
    var direction = Direction.west
    var oxygenSensorLocation: Point?

    var neighbors: [Robot] {
        var result = [Robot]()

        for direction in Direction.allCases {
            var copy = self
            if copy.move(direction).didMove {
                result.append(copy)
            }
        }

        return result
    }

//    var neighbors: [(point: Point, robot: Robot)] {
//        var result = [(Point, Robot)]()
//
//        for direction in Direction.allCases {
//            var copy = self
//            if copy.move(direction).didMove {
//                result.append((copy.position, copy))
//            }
//        }
//
//        return result
//    }

    func copy() -> Robot {
        let c = self
        return c
    }

    // coded this up by following the pseudocode on wikipedia
    mutating func aStarMove(to goal: Point) -> Int {
        func h(_ start: Point) -> Int {
            abs(start.x - goal.x) + abs(start.y - goal.y)
        }

        var openSet = [position: copy()]
        var cameFrom = [Point: Point]()

        var gScore = [position: 0]
        var fScore = [position: h(position)]

        func stepCount(_ from: Point) -> Int {
            var current = from
            var totalPath = [current]
            while let next = cameFrom[current] {
                totalPath.append(next)
                current = next
            }
            return totalPath.count - 1
        }

        while !openSet.isEmpty {
            let current = openSet.keys.max { fScore[$0]! < fScore[$1]! }!
            let currentRobot = openSet[current]!
            if current == goal {
                return stepCount(current)
            }
            openSet[current] = nil
            for neighbor in currentRobot.neighbors {
                let pos = neighbor.position
                let tentativeGScore = gScore[current, default: Int.max] + 1
                if tentativeGScore < gScore[pos, default: Int.max] {
                    cameFrom[pos] = current
                    gScore[pos] = tentativeGScore
                    fScore[pos] = tentativeGScore + h(pos)
                    if openSet[pos] == nil {
                        openSet[pos] = neighbor
                    }
                }
            }
        }
        fatalError("no path found")
    }

    mutating func move(_ direction: Direction) -> Result {
        self.direction = direction
        return move()
    }

    mutating func move() -> Result {
        guard let output = brain.run(initialInputs: [direction.rawValue]).output.first else {
            fatalError()
        }
        guard let result = Result(rawValue: output) else { fatalError() }
        if result.didMove {
            position = position.afterMove(direction)
            direction = direction.prev
        } else {
            direction = direction.next
        }

        if result == .movedToOxygenSensor {
            oxygenSensorLocation = position
        }
        return result
    }
}

func part1_1() -> Robot {
    var robot = Robot()
    while robot.oxygenSensorLocation == nil {
        _ = robot.move()
    }
    return robot
}

func part1_2(_ point: Point) {
    var robot = Robot()
    print(robot.aStarMove(to: point))
}

public func partOne() {
  let point = part1_1().oxygenSensorLocation!
  part1_2(point) //282
}

public func partTwo() {
    let robot = part1_1()
    var oxygenated: Set<Point> = [robot.position]
    var minutes = 0
    var curRobots = [robot]
    while !curRobots.isEmpty {
        var nextRobots = [Robot]()
        for curRobot in curRobots {
            for nextRobot in curRobot.neighbors {
                if !oxygenated.contains(nextRobot.position) {
                    oxygenated.insert(nextRobot.position)
                    nextRobots.append(nextRobot)
                }
            }
        }
        if !nextRobots.isEmpty {
            minutes += 1
        }

        curRobots = nextRobots
    }
    print(minutes)
}
