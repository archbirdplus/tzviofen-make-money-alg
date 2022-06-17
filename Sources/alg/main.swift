import Foundation
import Game

var games = 0
var maxMoney = 0
var minDepthCompleted: Int? = nil

var start = Date()

func solveBestMoves(game prev: Game, depth: Int = 0) -> ([[Input]], Game) {
    guard prev.time <= 20833 else {
        games += 1
        if games == 100000 {
            print("time to 100k games: \(Date().timeIntervalSince(start))")
        }
        if prev.money > maxMoney {
            maxMoney = prev.money
            print("new record: $\(prev.money) (\(games)th game)")
        }
        return ([], prev)
    }
    // allow up to n cycles before shutting off and waiting for the end
    let n = 18
    guard prev.time < 33 + 200 * n else {
        return solveBestMoves(game: prev.advanced(), depth: depth+1)
    }
    let paths = prev.paths()
    var bestSubPaths: [([[Input]], Game)] = []
    bestSubPaths.reserveCapacity(paths.count)
    // loop instead of map because it lets profilers do flatten recursion
    for (inputs, game) in paths {
        let (i, g) = solveBestMoves(game: game.advanced(), depth: depth+1)
        bestSubPaths.append(([inputs] + i, g))
    }
    let bestSubPath = bestSubPaths.max { a, b in a.1.money < b.1.money }!
    let best = (bestSubPath.0, bestSubPath.1)
    if minDepthCompleted == nil {
        print("max depth \(depth)? (\(games) games)")
        minDepthCompleted = depth
    } else if depth < minDepthCompleted! {
        minDepthCompleted = depth
        print("new depth completed \(depth) (\(games) games)")
    }
    return best
}

printpath(solveBestMoves(game: Game()))
print("this all after \(games) games completed in \(Date().timeIntervalSince(start))")

