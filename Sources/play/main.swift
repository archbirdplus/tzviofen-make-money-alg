import Foundation
import Game

var game = Game()

func printout() {
    if let v = game.vehicle {
        let name = [VehicleType.truck: "truck", .crane: "crane", .heli: "heli"][v.type]!
        print("$\(game.money) T-\(20833-game.time) \(name)/\(String(format: "%.1f", v.time))")
    } else {
        print("$\(game.money) T-\(20833-game.time)")
    }
    game.buildings.enumerated().forEach { n, x in
        let name = [BuildingType.glass: "glass", .bronze: "bronze", .silver: "silver", .gold: "gold"][x.type]!
        if let (_, cost, upgrade) = x.upgrade() {
            print("building \(n): \(name)-\(x.level) ($\(x.prof)) $\(cost) -> $\(upgrade.prof)")
        } else {
            print("building \(n): \(name)-\(x.level) ($\(x.prof)) MAX")
        }
    }
}

print("blank line: skip turn")
print("g/b/s/G: create building")
print("t/c/h: rent vehicle")
print("<N>: upgrade")

while true {
    printout()
    while let line = readLine(), line != "" {
        if let buildType = ["g": BuildingType.glass, "b": .bronze, "s": .silver, "G": .gold][line] {
            if let next = game.havingBuilt(buildType) {
                game = next
            } else { print("building cannot be bought") }
        } else if let vehicleType = ["t": VehicleType.truck, "c": .crane, "h": .heli][line] {
            if let next = game.havingRented(vehicleType) {
                game = next
            } else { print("vehicle cannot be bought") }
        } else if let i = Int(line) {
            if let next = game.havingUpgraded(i) {
                game = next
            } else { print("building could not be upgraded") }
        } else { print("please speak in gbsGtch<N>") }
    }
    let next = game.advanced()
    if(next.time > 20833) { break } else { game = next }
}

printout()

