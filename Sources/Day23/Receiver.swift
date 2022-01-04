@available(macOS 12.0.0, *)
protocol Receiver {
  func receive(_ packet: Packet) async
}

class PrintReceiver: Receiver {
  func receive(_ packet: Packet) {
    print("Received x=\(packet.x) y=\(packet.y)")
  }
}

@available(macOS 12.0.0, *)
actor NATReceiver: Receiver {
  private var lastPacket: Packet?
  private var computers: [Computer]

  private var sentYs = Set<Int>()

  init(computers: [Computer]) {
    self.computers = computers
  }

  func run() {
    Task {
      while true {
        var isIdle = true
        for computer in computers {
          if await !computer.isIdle {
            isIdle = false
            break
          }
        }

        if let lastPacket = lastPacket, isIdle {
          print("Sending y=\(lastPacket.y) to address 0")
          if sentYs.contains(lastPacket.y) {
            print("Sending \(lastPacket.y) a second time")
          } else {
            sentYs.insert(lastPacket.y)
          }
          await computers[0].receive(lastPacket)
        }
        
        await Task.sleep(500000000)
      }
    }
  }

  func receive(_ packet: Packet) async {
    lastPacket = packet
  }
}
