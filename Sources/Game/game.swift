
public typealias Money = Int

public enum VehicleType {
    case truck
    case crane
    case heli

    func map<R>(truck t: R, crane c: R, heli h: R) -> R {
        switch self {
        case .truck:
            return t
        case .crane:
            return c
        case .heli:
            return h
        }
    }
}

public struct Vehicle {
    public let type: VehicleType
    public let time: Double

    public static func create(_ type: VehicleType) -> (Money, Vehicle) {
        let cost = type.map(truck: 200, crane: 1200, heli: 300)
        return (cost, Vehicle(type))
    }

    init(_ type: VehicleType, _ time: Double = 125) {
        self.type = type
        self.time = time
    }

    public func advanced(t: Int) -> Vehicle? {
        let nextTime = time - Double(t)*0.2
        return nextTime >= -5 ? Vehicle(type, nextTime) : nil
    }

    func nextEvent() -> Int {
        Int((time+5) / 0.2)+1
    }
}

public enum BuildingType: Hashable {
    case glass
    case bronze
    case silver
    case gold

    func map<R>(glass g: R, bronze b: R, silver s: R, gold G: R) -> R {
        switch self {
        case .glass:
            return g
        case .bronze:
            return b
        case .silver:
            return s
        case .gold:
            return G
        }
    }

    public var upgradeVehicle: VehicleType {
        self.map(glass: VehicleType.truck,
            bronze: .crane,
            silver: .heli,
            gold: .heli)
    }
        
}

public struct Building {
    public let type: BuildingType
    public let level: Int
    public let moomoo: Int

    public var prof: Money {
        return type.map(glass: [20, 40, 60, 80, 100],
                        bronze: [70, 150, 250, 380, 500],
                        silver: [700, 1300, 1700, 3400, 4400],
                        gold: [900, 1800, 3700, 400, 5000])[level]
    }

    private init(_ type: BuildingType, _ level: Int = 0, _ moomoo: Int = 1) {
        self.type = type
        self.level = level
        self.moomoo = moomoo
    }

    public static func create(_ type: BuildingType) -> (Money, Building) {
        let cost = type.map(glass: 2000,
                            bronze: 5000,
                            silver: 20_000,
                            gold: 40_000)
        return (cost, Building(type))
    }

    public func upgrade() -> (VehicleType, Money, Building)? {
        guard level < 4 else { return nil }
        let vehicle = type.upgradeVehicle
        let cost = type.map(glass: [200, 400, 900, 1500],
                            bronze: [550, 1000, 1800, 300],
                            silver: [3_000, 10_000, 15_000, 25_000],
                            gold: [10_000, 20_000, 35_000, 60_000])[level]
        return (vehicle, cost, Building(type, level+1, moomoo))
    }

    func advanced(t: Int) -> (Building, Money) {
        let newmoo = moomoo + t
        return (Building(type, level, newmoo), newmoo % 200 == 0 ? prof : 0)
    }

    func nextEvent() -> Int {
        let speed = 200 // uniformly set in the original game
        // profits on frame moomoo%speed = 0
        // moomoo = speed
        return speed - (moomoo % speed) // 200 - 199 = 1
    }
}

public struct Game {
    public let money: Money
    public let buildings: [Building]
    public let vehicle: Vehicle?
    public let time: Int

    public init() {
        self.init(money: 3000, buildings: [Building.create(.glass).1], vehicle: nil, time: 0)
    }

    init(money: Money, buildings: [Building], vehicle: Vehicle?, time: Int) {
        self.money = money
        self.buildings = buildings
        self.vehicle = vehicle
        self.time = time
    }

    public func havingBuilt(_ type: BuildingType) -> Game? {
        let (cost, building) = Building.create(type)
        guard money >= cost else { return nil }
        return Game(money: money-cost, buildings: buildings + [building], vehicle: vehicle, time: time)
    }

    public func havingRented(_ type: VehicleType) -> Game? {
        let (cost, new) = Vehicle.create(type)
        guard money >= cost else { return nil }
        return Game(money: money-cost, buildings: buildings, vehicle: new, time: time)
    }

    public func havingUpgraded(_ i: Int) -> Game? {
        guard i < buildings.count else { print("no building \(i)"); return nil }
        let b = buildings[i]
        guard let (type, cost, building) = b.upgrade() else { return nil }
        guard vehicle?.type == type else { return nil }
        guard money >= cost else { return nil }
        var tmp = buildings
        tmp[i] = building
        return Game(money: money-cost, buildings: tmp, vehicle: vehicle, time: time)
    }

    // time checks are hard, and delete the game before it can be known to check
    public func advanced() -> Game {
        let nextEvent = buildings.reduce(200) { r, x in min(r, x.nextEvent()) }
        var profits = 0
        let nbuildings: [Building] = buildings.map {
            let pair = $0.advanced(t: nextEvent) // building, money
            profits += pair.1
            return pair.0
        }
        return Game(money: money + profits,
            buildings: nbuildings,
            vehicle: vehicle?.advanced(t: nextEvent),
            time: time + nextEvent)
    }

}

