import Foundation
import Game

extension Array {
    func indices(where predicate: (Element) -> Bool) -> [Int] {
        self.enumerated().filter { _, x in predicate(x) }.map { n, x in n }
    }
}

enum Input {
    case build(BuildingType)
    case rent(VehicleType)
    case upgrade(Int)
}

extension VehicleType {
    var name: String { [VehicleType.truck: "truck", .crane: "crane", .heli: "heli"][self]! }
}

extension BuildingType {
    static var all: [Self] { [.glass, .bronze, .silver, .gold] }

    var name: String { [BuildingType.glass: "glass", .bronze: "bronze", .silver: "silver", .gold: "gold"][self]! }
}

extension Game {
    func buildPaths(for type: BuildingType) -> [([Input], Game)] {
        let (cost, _) = Building.create(type)
        let max = money/cost
        var currGame = self
        var currInputs: [Input] = []
        var paths: [([Input], Game)] = [(currInputs, currGame)]
        for _ in 0..<max {
            currInputs.append(.build(type))
            currGame = currGame.havingBuilt(type)!
            paths.append((currInputs, currGame))
        }
        return paths
    }

    func buildPaths() -> [([Input], Game)] {
        let types = BuildingType.all
        return types.reduce([([], self)]) { r, x in
            r.flatMap { (inputs, game) in
                return game.buildPaths(for: x)
                    .map { i, g in (inputs + i, g) }
            }
        }
    }

    func upgradePaths(for type: VehicleType, min: Int = 0) -> [([Input], Game)] {
        let matching = buildings
            .indices { $0.type.upgradeVehicle == type }
            .filter { $0 >= min } // combinations, not permutations
        let upgradedPaths: [(Int, Game)] = matching.compactMap { i in
            if let u = self.havingUpgraded(i) {
                return (i, u)
            } else { return nil }
        }
        return upgradedPaths.map { (i, g) in ([Input.upgrade(i)], g) }
            + upgradedPaths.flatMap { (index, game) in
                game.upgradePaths(for: type, min: index).map { (i, g) in
                    ([Input.upgrade(index)] + i, g)
                }
            }
    }

    func upgradePaths() -> [([Input], Game)] {
        // if we already have a vehicle, save by upgrading its buildings first
        let order: [VehicleType] = [VehicleType.truck, .crane, .heli]
            .sorted { a, b in b != vehicle?.type }
        //return order.reduce([([], self)]) { r, v in
        return order.reduce(into: [([], self)]) { r, v in
            let new: [[([Input], Game)]] = r.compactMap { (inputs, game) in
                let prefix = game.vehicle?.type == v ? inputs : inputs+[.rent(v)]
                return game
                    .havingRented(v)?
                    .upgradePaths(for: v)
                    .map { i, g in return (prefix + i, g) }
            }
            r.append(contentsOf: new.flatMap { $0 })
        }
    }

    func paths() -> [([Input], Game)] {
        return buildPaths().flatMap { inputs, game in
            game.upgradePaths().map { (i, g) in
                (inputs + i, g)
            }
        }
    }
}

func printout(_ game: Game) {
    if let v = game.vehicle {
        let name = v.type.name
        print("$\(game.money) T-\(20833-game.time) \(name)/\(String(format: "%.1f", v.time))")
    } else {
        print("$\(game.money) T-\(20833-game.time)")
    }
    game.buildings.enumerated().forEach { n, x in
        let name = x.type.name
        if let (_, cost, upgrade) = x.upgrade() {
            print("    building \(n): \(name)-\(x.level) ($\(x.prof)) $\(cost) -> $\(upgrade.prof)")
        } else {
            print("    building \(n): \(name)-\(x.level) ($\(x.prof)) MAX")
        }
    }
}

func printinputs(_ inputs: [Input]) {
    print(inputs.map { input in
        switch input {
        case .build(let type):
            return "build \(type.name)"
        case .rent(let type):
            return "rent \(type.name)"
        case .upgrade(let i):
            return "upgrade \(i)"
        }
    }.joined(separator: ", "))
}

func printpath(_ path: ([Input], Game)) {
    printinputs(path.0)
    printout(path.1)
}

func printinputss(_ inputs: [[Input]]) {
    print(inputs.map { group in group.map { i in
        switch i {
        case .build(let type):
            return [BuildingType.glass: "g", .bronze: "b", .silver: "s", .gold: "G"][type]!
        case .rent(let type):
            return [VehicleType.truck: "t", .crane: "c", .heli: "h"][type]!
        case .upgrade(let i):
            return String(i)
        }
    }.joined() }.joined(separator: ";"))
}

func printpath(_ path: ([[Input]], Game)) {
    printinputss(path.0)
    printout(path.1)
}

