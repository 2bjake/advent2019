protocol Receiver: Actor {
  func run() async
  func receive(_ packet: Packet)
}

actor PrintReceiver: Receiver {
  var hasReceived = false

  func run() async {
    while !hasReceived {
      try? await Task.sleep(nanoseconds: 1)
    }
  }

  func receive(_ packet: Packet) {
    print("Received x=\(packet.x) y=\(packet.y)")
    hasReceived = true
  }
}

// is this a good idea?
extension Sequence {
  func allSatisfy(_ predicate: @escaping (Element) async throws -> Bool) async rethrows -> Bool {
    try await withThrowingTaskGroup(of: Bool.self) { group in
      for element in self {
        group.addTask { try await predicate(element) }
      }
      return try await group.allSatisfy { $0 }
    }
  }
}

actor NATReceiver: Receiver {
  private var lastPacket: Packet?
  private var computers: [Computer]

  private var sentYs = Set<Int>()
  private var hasSentTwice = false

  init(computers: [Computer]) {
    self.computers = computers
  }

  func run() async {
    while !hasSentTwice {
      try? await Task.sleep(nanoseconds: 1)
//      var allIdle = true
//      for computer in computers {
//        if await !computer.isIdle {
//          allIdle = false
//          break
//        }
//      }

      let allIdle: Bool = await withTaskGroup(of: Bool.self) { group in
        for computer in computers {
          group.addTask { await computer.isIdle }
        }

        return await group.allSatisfy { $0 }
      }

      try? await Task.sleep(nanoseconds: 1)
      if let lastPacket = lastPacket, allIdle {
        if sentYs.contains(lastPacket.y) {
          print("Sending \(lastPacket.y) a second time")
          hasSentTwice = true
        } else {
          sentYs.insert(lastPacket.y)
        }
        await computers[0].receive(lastPacket)
      }
    }
  }

  func receive(_ packet: Packet) {
    lastPacket = packet
  }
}
