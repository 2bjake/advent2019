enum Function: Int {
  case a = 65
  case b = 66
  case c = 67

  var ascii: Int { rawValue }
}

extension Function {
  init(_ source: Substring) {
    switch source {
      case "A": self = .a
      case "B": self = .b
      case "C": self = .c
      default: fatalError()
    }
  }
}

enum Command { case left, right, forward(String) }

extension Command {
  init(_ source: Substring) {
    switch source {
      case "L": self = .left
      case "R": self = .right
      default:
        guard UInt(source) != nil else { fatalError() }
        self = .forward(String(source))

    }
  }

  var ascii: [Int] {
    switch self {
      case .left: return [76]
      case .right: return [82]
      case .forward(let value): return value.map { Int($0.asciiValue!) }
    }
  }
}

enum Section: String { case main, a, b, c, liveFeed }

struct MovementRoutine {
  private let comma = 44
  private let newline = [10]

  private var main: [Function]
  private var a: [Command]
  private var b: [Command]
  private var c: [Command]
  private var liveFeed: Bool = false

  private var liveFeedAscii: [Int] { liveFeed ? [121] : [110] }

  private static func validate(codes: [Section: [Int]]) {
    guard codes[.main, default: []].count <= 20 else { fatalError("main has too many characters")}
    guard codes[.a, default: []].count <= 20 else { fatalError("a has too many characters")}
    guard codes[.b, default: []].count <= 20 else { fatalError("b has too many characters")}
    guard codes[.c, default: []].count <= 20 else { fatalError("c has too many characters")}
  }

  private func intCodes() -> [Section: [Int]] {
    let mainInts = Array(main.map(\.ascii).interspersed(with: comma))
    let aInts = Array(a.map(\.ascii).interspersed(with: [comma]).joined())
    let bInts = Array(b.map(\.ascii).interspersed(with: [comma]).joined())
    let cInts = Array(c.map(\.ascii).interspersed(with: [comma]).joined())
    return [.main: mainInts, .a: aInts, .b: bInts, .c: cInts, .liveFeed: liveFeedAscii ]
  }

  func printEvaluation() {
    let codes = intCodes()

    func printSection(_ section: Section) {
      let code = codes[section, default: []]
      print("\(section.rawValue) is \(code.count) long: \(code)")
    }

    printSection(.main)
    printSection(.a)
    printSection(.b)
    printSection(.c)
    printSection(.liveFeed)
  }

  var intCode: [Int] {
    let codes = intCodes()
    Self.validate(codes: codes)
    return [codes[.main]!, codes[.a]!, codes[.b]!, codes[.c]!, liveFeedAscii].joined(separator: newline) + newline
  }
}

extension MovementRoutine {
  init(main: String, a: String, b: String, c: String, liveFeed: Bool = false) {
    self.main = main.split(separator: ",").map(Function.init)
    self.a = a.split(separator: ",").map(Command.init)
    self.b = b.split(separator: ",").map(Command.init)
    self.c = c.split(separator: ",").map(Command.init)
    self.liveFeed = liveFeed
  }
}
