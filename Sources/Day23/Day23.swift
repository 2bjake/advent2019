import Foundation

func runWith(computers: [Computer], receiver: Receiver) async {
  var receiverById: [Int: Receiver] = computers.reduce(into: [:]) { result, computer in
    result[computer.id] = computer
  }
  receiverById[255] = receiver

  await withTaskGroup(of: Void.self) { group in
    for computer in computers {
      await computer.prepare(withReceivers: receiverById)
      group.addTask { await computer.run() }
    }

    await receiver.run()
    group.cancelAll()
  }
}

public func partOne() async {
  let computers = (0...49).map { Computer(id: $0, program: input) }
  await runWith(computers: computers, receiver: PrintReceiver()) // 19530
}

public func partTwo() async {
  let computers = (0...49).map { Computer(id: $0, program: input) }
  let nat = NATReceiver(computers: computers)
  await runWith(computers: computers, receiver: nat) // 12725
}
