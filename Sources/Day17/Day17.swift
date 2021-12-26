import IntCode
import Extensions

let program = input.split(separator: ",").compactMap(Int.init)

public func partOne() {
  var machine = Machine(program: program)
  let output = machine.run()
  print(output)
}

public func partTwo() {

}
