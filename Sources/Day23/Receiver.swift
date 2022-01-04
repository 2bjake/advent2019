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
class NATReceiver: Receiver {
  var lastPacket: Packet!
  var computers: [Computer]

  init(computers: [Computer]) {
    self.computers = computers
  }

  func run() {
    Task {
      while true {
        //TODO

        await Task.sleep(200000000)
      }
    }
  }

  func receive(_ packet: Packet) async {
    lastPacket = packet
  }
}
