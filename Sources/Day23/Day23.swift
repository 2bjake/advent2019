import Darwin

@available(macOS 12.0.0, *)
func runWith(computers: [Computer], receiver: Receiver) {
  var receiverById: [Int: Receiver] = computers.reduce(into: [:]) { result, computer in
    result[computer.id] = computer
  }
  receiverById[255] = receiver

  Task { [receiverById] in
    await withTaskGroup(of: Void.self) { group in
      for computer in computers {
        group.addTask { await computer.start(withReceivers: receiverById) }
      }
    }
  }

  while true {
    sleep(5000)
  }
}

@available(macOS 12.0.0, *)
public func partOne() {
//  let computers = (0...49).map { Computer(id: $0, program: input) }
//  runWith(computers: computers, receiver: PrintReceiver()) // 19530
}

@available(macOS 12.0.0, *)
public func partTwo() {
  let computers = (0...49).map { Computer(id: $0, program: input) }
  let nat = NATReceiver(computers: computers)
  Task { await nat.run() }
  runWith(computers: computers, receiver: nat) // 12725
}
