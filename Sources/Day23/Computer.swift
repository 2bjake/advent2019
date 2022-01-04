import IntCode

struct Packet {
  let x: Int
  let y: Int
}

@available(macOS 12.0.0, *)
actor Computer: Receiver {
  let id: Int
  private var machine: Machine
  private var receiveQueue: [Int]
  private var sendQueue: [Int] = []
  private var halted = false
  private var receiversById = [Int: Receiver]()

  private(set) var isIdle: Bool = false

  init(id: Int, program: [Int]) {
    self.id = id
    self.machine = Machine(program: program)
    self.receiveQueue = [id]
  }

  private func run() {
    Task {
      while !halted {
        let input: Int
        if receiveQueue.notEmpty {
          input = receiveQueue.removeFirst()
          isIdle = false
        } else {
          input = -1
          isIdle = true
        }
        let result = machine.run(input: input)
        switch result {
          case .halted: halted = true
          case .inputNeeded: break
        }
        await Task.sleep(200000000)
      }
    }
  }

  func start(withReceivers receivers: [Int: Receiver]) {
    self.receiversById = receivers
    machine.outputWatcher = send
    run()
  }

  func stop() {
    halted = true
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
