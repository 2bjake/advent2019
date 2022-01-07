import IntCode
import Algorithms

func printAscii(_ value: Int) {
  print(Character(UnicodeScalar(value)!), terminator: "")
}

let script = """
south
south
south
take fixed point
west
take asterisk
east
south
take festive hat
west
west
take jam
south
take easter egg
north
east
east
north
north
west
north
north
take tambourine
south
south
east
north
west
south
take antenna
north
west
west
take space heater
west

""".map { Int($0.asciiValue!) }

enum Item: String, CaseIterable {
  case fixedPoint = "fixed point"
  case asterisk
  case festiveHat = "festive hat"
  case jam
  case easterEgg = "easter egg"
  case tambourine
  case antenna
  case spaceHeater = "space heater"
}


func play(_ script: [Int] = [], startingMachine: Machine? = nil) -> Machine? {
  var commands = [String]()
  var machine = startingMachine ?? Machine(program: input)
  machine.outputWatcher = printAscii
  _ = machine.run(initialInputs: script)
  var input = [Int]()
  var isHalted = false
  while !isHalted {
    switch machine.run(initialInputs: input) {
      case .halted: isHalted = true
      case .inputNeeded:
        var command = readLine()!
        switch command {
          case "s": command = "south"
          case "n": command = "north"
          case "w": command = "west"
          case "e": command = "east"
          case "p": print(commands.joined())
          case "t": return machine
          default: break
        }
        command.append("\n")
        commands.append(command)
        input = command.map { Int($0.asciiValue!) }
    }
  }
  print(commands.joined())
  return nil
}

func action(_ action: String, on item: Item, machine: inout Machine) {
  let input = "\(action) \(item.rawValue)\n".map { Int($0.asciiValue!) }
  _ = machine.run(initialInputs: input)
}

func take(_ item: Item, machine: inout Machine) {
  action("take", on: item, machine: &machine)
}

func drop(_ item: Item, machine: inout Machine) {
    action("drop", on: item, machine: &machine)
}

func dropAll(machine: inout Machine) {
  Item.allCases.forEach { drop($0, machine: &machine) }
}

enum WeightResult {
  case tooHeavy
  case tooLight
  case success
}

func tryItems(_ items: [Item], machine: inout Machine) -> WeightResult {
  dropAll(machine: &machine)
  items.forEach { take($0, machine: &machine) }
  let input = "west\n".map { Int($0.asciiValue!) }
  let result = machine.run(initialInputs: input)

  let str = String(result.output.map { Character(UnicodeScalar($0)!) })
  if str.contains("lighter") { return .tooHeavy }
  if str.contains("heavier") { return .tooLight }
  return .success
}

private func intToBitMap(_ int: Int) -> [Bool] {
  let binaryStr = String(int, radix: 2)
  let unpadded = binaryStr.map { $0 == "1" }
  return repeatElement(false, count: 8 - unpadded.count) + unpadded
}

private func bitMapToItems(_ bitMap: [Bool]) -> [Item] {
  let allItems = Item.allCases
  var result = [Item]()
  for i in bitMap.indices where bitMap[i] {
    result.append(allItems[i])
  }
  return result
}

public func partOne() {
  var machine = play(script)!
  for bitMap in (0...255).map(intToBitMap) {
    let items = bitMapToItems(bitMap)
    let result = tryItems(items, machine: &machine)
    if result == .success {
      print(items)
    }
  }
}

public func partTwo() {

}
