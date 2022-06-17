import XCTest
@testable import Game

final class gameTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //XCTAssertEqual(tzviofen_make_money_alg().text, "Hello, World!")
        var game = Game()
        while true {
            let next = game.advanced()
            if next.time > 20833 { break } else { game = next }
        }
        XCTAssertEqual(game.money, 5080)
    }
}
