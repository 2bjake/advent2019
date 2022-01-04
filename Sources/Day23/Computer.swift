import IntCode

struct Packet {
  let x: Int
  let y: Int
}

actor Computer: Receiver {
  let id: Int
  private var machine: Machine
  private var receiveQueue: [Int]
  private var sendQueue: [Int] = []
  private var receiversById = [Int: Receiver]()

  private var idleCount = 0
  var isIdle: Bool { idleCount > 100 }

  init(id: Int, program: [Int]) {
    self.id = id
    self.machine = Machine(program: program)
    self.receiveQueue = [id]
  }

  func run() async {
    while !Task.isCancelled {
      let input: Int
      if receiveQueue.notEmpty {
        input = receiveQueue.removeFirst()
        idleCount = 0
      } else {
        input = -1
        idleCount += 1
      }
      _ = machine.run(input: input)
      await Task.sleep(1)
    }
  }

  func prepare(withReceivers receivers: [Int: Receiver]) {
    self.receiversById = receivers
    machine.outputWatcher = send
  }

  private func send(_ value: Int) {
    sendQueue.append(value)
    guard sendQueue.count == 3 else { return }

    let address = sendQueue[0]
    let packet = Packet(x: sendQueue[1], y: sendQueue[2])
    Task { await receiversById[address]!.receive(packet) }
    sendQueue = []
  }

  func receive(_ packet: Packet) async {
    receiveQueue.append(contentsOf: [packet.x, packet.y])
  }
}
