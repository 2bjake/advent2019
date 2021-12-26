struct Ingredient {
    let chemical: String
    let amount: Int
}

extension Ingredient {
    init(_ str: String) {
        let parts = str.split(separator: " ")
        amount = Int(parts[0])!
        chemical = String(parts[1])
    }
}

struct Reaction {
    let inputs: [Ingredient]
    let output: Ingredient
}

extension Reaction: CustomStringConvertible {
    var description: String { "\(inputs.map { "\($0.amount) \($0.chemical)" }) => \(output.amount) \(output.chemical)" }
}

func reactionMap(_ str: String) -> [String: Reaction] {
    let reactions: [Reaction] = str.split(separator: "\n").map { line in
        let halves = line.split(separator: ">")

        let inputs = halves[0].split(separator: ",").map {
            Ingredient(String($0))
        }
        let output = Ingredient(String(halves[1]))
        return Reaction(inputs: inputs, output: output)
    }

    return reactions.reduce(into: [:]) {
        $0[$1.output.chemical] = $1
    }
}

let chemToReaction = reactionMap(input)

public func partOne() {
  print(chemToReaction)
}

typealias Store = [String: Int]

func needsIngredients(for reaction: Reaction, store: Store) -> [Ingredient] {
    var result = [Ingredient]()
    for input in reaction.inputs {
        if store[input.chemical, default: 0] < input.amount {
            result.append(input)
        }
    }
    return result
}

func run(reaction: Reaction, store: inout Store) {
    for input in reaction.inputs {
        store[input.chemical]! -= input.amount
    }
    store[reaction.output.chemical, default: 0] += reaction.output.amount
}

struct OutOfOreError: Error {}

func produce(ingredient: Ingredient, store: inout Store) throws {
    if ingredient.chemical == "ORE" && ingredient.amount > store[ingredient.chemical, default: 0] {
        throw OutOfOreError()
    }

    guard let reaction = chemToReaction[ingredient.chemical] else { fatalError() }

    while store[ingredient.chemical, default: 0] < ingredient.amount {
        let ingredientsNeeded = needsIngredients(for: reaction, store: store)
        if ingredientsNeeded.isEmpty {
            run(reaction: reaction, store: &store)
        } else {
            try ingredientsNeeded.forEach { try produce(ingredient: $0, store: &store) }
        }
    }
}

//func part1() {
//    var initialStore = Store()
//    initialStore["ORE"] = 1000000000000
//    try! produce(ingredient: Ingredient(chemical: "FUEL", amount: 1), store: &initialStore)
//    print(1000000000000 - initialStore["ORE"]!)
//}
//part1()

func needsChemicals(for reaction: Reaction, amount: Int, store: Store) -> [(chemical: String, amount: Int)] {
    let times = Int((Double(amount) / Double(reaction.output.amount)).rounded(.up))
    var result = [(String, Int)]()
    for input in reaction.inputs {
        if store[input.chemical, default: 0] < input.amount * times {
            result.append((input.chemical, input.amount * times))
        }
    }
    return result
}

func run(reaction: Reaction, for amount: Int, store: inout Store) {
    let times = Int((Double(amount) / Double(reaction.output.amount)).rounded(.up))
    for input in reaction.inputs {
        store[input.chemical]! -= input.amount * times
    }
    store[reaction.output.chemical, default: 0] += reaction.output.amount * times
}

//func produce(chemical: String, amount: Int, store: inout Store) throws {
//    if chemical == "ORE" && amount > store[chemical, default: 0] {
//        throw OutOfOreError()
//    }
//
//    guard let reaction = chemToReaction[chemical] else { fatalError() }
//
//    while store[chemical, default: 0] < amount {
//        let chemicalsNeeded = needsChemicals(for: reaction, amount: amount, store: store)
//        if chemicalsNeeded.isEmpty {
//            run(reaction: reaction, for: amount, store: &store)
//        } else {
//            let (neededChemical, chemicalAmountNeeded) = chemicalsNeeded.first!
//            try produce(chemical: neededChemical, amount: chemicalAmountNeeded, store: &store)
//        }
//    }
//}

func produce(chemical: String, amount: Int, store: inout Store) throws {
    if chemical != "ORE" {
        guard let reaction = chemToReaction[chemical] else { fatalError() }
        let times = Int((Double(amount) / Double(reaction.output.amount)).rounded(.up))
        for input in reaction.inputs {
            try produce(chemical: input.chemical, amount: input.amount * times, store: &store)
        }
    } else if chemical == "ORE" && amount > store[chemical, default: 0] {
        throw OutOfOreError()
    } else {
        store["ORE"]! -= amount
    }
}

//func runRecursive(chemical: String, amount: Int, store: inout Store)

public func partTwo() {
    var initialStore = Store()
    initialStore["ORE"] = 1000000000000
    let amount = 3568888
    try! produce(chemical: "FUEL", amount: amount, store: &initialStore)
}

