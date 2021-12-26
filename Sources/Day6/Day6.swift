class Node {
  let name: String
  weak var parent: Node? = nil
  var children: [Node] = []

  init(name: String) {
    self.name = name
  }
}

var nodeMap: [String: Node] = [:]

typealias OrbitPair = (parent: String, child: String)

let pairs: [OrbitPair] = input.split(separator: "\n").map {
  let parts = $0.split(separator: ")")
  return (String(parts[0]), String(parts[1]))
}

public func partOne() {
  pairs.forEach { parent, child in
    let parentNode = nodeMap[parent, default: Node(name: parent)]
    let childNode = nodeMap[child, default: Node(name: child)]

    childNode.parent = parentNode
    parentNode.children.append(childNode)

    nodeMap[parent] = parentNode
    nodeMap[child] = childNode
  }

  func countOrbits(_ node: Node, _ curDepth: Int) -> Int {
    var result = curDepth
    for child in node.children {
      result += countOrbits(child, curDepth + 1)
    }
    return result
  }

  print(countOrbits(nodeMap["COM"]!, 0)) //140608
}

// part 2

func pathFromCOM(to node: Node) -> [Node] {
  var path = [Node]()
  var cur = node
  while let parent = cur.parent {
    path.append(parent)
    cur = parent
  }
  return path.reversed()
}

public func partTwo() {
  let comToYou = pathFromCOM(to: nodeMap["YOU"]!)
  let comToSanta = pathFromCOM(to: nodeMap["SAN"]!)

  var i = 0

  while comToYou[i].name == comToSanta[i].name {
    i += 1
  }

  print(comToYou.count - i + comToSanta.count - i) // 337
}
