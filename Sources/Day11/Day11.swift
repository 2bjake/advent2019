import IntCode

struct Tile: Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

extension Tile: CustomStringConvertible {
    var description: String { "(\(x), \(y))" }
}

enum Direction {
    case up, left, down, right
}

enum Turn: Int {
    case left = 0
    case right = 1
}

extension Direction {
    func turn(_ turn: Turn) -> Direction {
        switch (self, turn) {
        case (.up, .left), (.down, .right): return .left
        case (.down, .left), (.up, .right): return .right
        case (.right, .left), (.left, .right): return .up
        case (.left, .left), (.right, .right): return .down
        }
    }
}

extension Tile {
    func tile(at direction: Direction) -> Tile {
        switch direction {
        case .up: return Tile(x, y + 1)
        case .down: return Tile(x, y - 1)
        case .left: return Tile(x - 1, y)
        case .right: return Tile(x + 1, y)
        }
    }
}

class Floor {
    var whiteTiles: Set<Tile>

    init(whiteTiles: Set<Tile> = []) {
        self.whiteTiles = whiteTiles
    }
}

class Robot {
    var brain = Machine(program: input)
    var position = Tile(0, 0)
    var direction = Direction.up
    var paintedTiles = Set<Tile>()
    var floor: Floor

    enum Color: Int {
        case black = 0
        case white = 1
    }

    init(floor: Floor = Floor()) {
        self.floor = floor
    }

    func colorAtPosition() -> Color {
        floor.whiteTiles.contains(position) ? .white : .black
    }

    func paintTile(_ color: Color) {
        paintedTiles.insert(position)
        switch color {
        case .black: floor.whiteTiles.remove(position)
        case .white: floor.whiteTiles.insert(position)
        }
    }

    func move(afterTurn turn: Turn) {
        direction = direction.turn(turn)
        position = position.tile(at: direction)
    }

    func handleOutput(_ output: [Int]) {
        guard output.count == 2,
            let color = Color(rawValue: output[0]),
            let turn = Turn(rawValue: output[1]) else { fatalError() }
        paintTile(color)
        move(afterTurn: turn)
    }

    func start() {
        while true {
            let input = colorAtPosition().rawValue
            let result = brain.run(input: input)
            switch result {
            case .halted: return
            case let .inputNeeded(output): handleOutput(output)
            }
        }
    }
}

public func partOne() {
    let robot = Robot()
    robot.start()
    print(robot.paintedTiles.count) // 2322
}

public func partTwo() {
    let floor = Floor(whiteTiles: [Tile(0, 0)])
    let robot = Robot(floor: floor)
    robot.start()

    let rowToColumns: [Int: [Int]] = floor.whiteTiles.reduce(into: [:]) { result, tile in
        result[-tile.y, default: []].append(tile.x)
    }

    func printRow(_ whites: [Int]) {
        var chars = Array<Character>(repeating: " ", count: 40)
        for white in whites {
            chars[white] = "■"
        }
        print(String(chars))
    }

    for i in 0...5 {
        printRow(rowToColumns[i]!)
    } // JHARBGCU
}
