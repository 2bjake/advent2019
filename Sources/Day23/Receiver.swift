protocol Receiver {
  func run() async
  func receive(_ packet: Packet) async
}

class PrintReceiver: Receiver {
  var hasReceived = false

  func run() async {
    while !hasReceived {
      await Task.sleep(1)
    }
  }

  func receive(_ packet: Packet) {
    print("Received x=\(packet.x) y=\(packet.y)")
    hasReceived = true
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
      await Task.sleep(1)

      var isIdle = true
      for computer in computers {
        if await !computer.isIdle {
          isIdle = false
          break
        }
      }

      if let lastPacket = lastPacket, isIdle {
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

  func receive(_ packet: Packet) async {
    lastPacket = packet
  }
}
