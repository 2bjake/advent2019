import Extensions
struct Section {
  let entrancePosition: Position
  let keys: [LocatedItem]
  let distanceByKey: [LocatedItem: Int]
}

extension Section {
  init(entrancePosition: Position, keys: [LocatedItem]) {
    self.entrancePosition = entrancePosition
    self.keys = keys
    // TODO: calculate distance from entrance to all keys
    distanceByKey = [:]
  }
}
