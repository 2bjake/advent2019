// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// if a specific day needs additional dependencies, add them here. For example:
// [6 : [.product(name: "Collections", package: "swift-collections")]]
let dayDependencies: [Int: [Target.Dependency]] = [
  15: ["IntCode"]
]

let dayTargets: [Target] = (1...25).map {
  .target(
    name: "Day\($0)",
    dependencies: [
      "Extensions",
      .product(name: "Algorithms", package: "swift-algorithms")
    ] + dayDependencies[$0, default: []])
}

let package = Package(
  name: "AdventOfCode",
  products: [
    .executable(name: "Main", targets: ["Main"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
  ],
  targets: [
    .executableTarget(
      name: "Main",
      dependencies: (1...25).map { .byName(name: "Day\($0)") }
    ),
    .target(
      name: "Extensions",
      dependencies: [.product(name: "Algorithms", package: "swift-algorithms")]
    ),
    .target(
      name: "IntCode",
      dependencies: []
    )
  ] + dayTargets
)
