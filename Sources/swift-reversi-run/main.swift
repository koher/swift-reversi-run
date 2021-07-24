import Foundation
import SwiftyReversi
import SwiftShell

let arguments = CommandLine.arguments
guard arguments.count == 3 else {
    print("The number of arguments must be 3: CommandLine.arguments.count = \(arguments.count)")
    exit(1)
}

let programID1: String = arguments[1]
let programID2: String = arguments[2]

var game: Game = .init()
var moveCount: Int = 1

let runPath: String = ((#file as NSString).deletingLastPathComponent as NSString).appendingPathComponent("run")

print(game.board.description)
print()
print("x: \(game.board.count(of: .dark)), o: \(game.board.count(of: .light))")
print()
print("-----")
print()

while case .beingPlayed(let turn) = game.state {
    print("\(moveCount): \(turn)")
    print()
    
    let programID: String
    let board: Board
    switch turn {
    case .dark:
        programID = programID1
        board = game.board
    case .light:
        programID = programID2
        board = game.board.flipped()
    }
    if board.validMoves(for: .dark).isEmpty {
        try! game.pass()
        continue
    }
    
    if programID == "manual" {
        while true {
            let rawOutput = readLine()!
            
            print("output:", rawOutput)
            let components = rawOutput.split(separator: " ")
            guard components.count == 2, let x = Int(components[0]), let y = Int(components[1]) else {
                print("Illegal output")
                continue
            }
            
            do {
                try game.placeDiskAt(x: x, y: y)
            } catch {
                print("Illegal move")
                continue
            }
            
            break
        }
    } else {
        let result = run(runPath, [programID, board])
        
        guard result.exitcode == 0 else {
            print(result.stderror)
            print("Winner: \(turn.flipped)")
            break
        }
        
        let rawOutput = result.stdout
        
        print("output:", rawOutput)
        let components = rawOutput.split(separator: " ")
        guard components.count == 2, let x = Int(components[0]), let y = Int(components[1]) else {
            print("Illegal output")
            print("Winner: \(turn.flipped)")
            break
        }
        
        do {
            try game.placeDiskAt(x: x, y: y)
        } catch {
            print("Illegal move")
            print("Winner: \(turn.flipped)")
            break
        }
    }

    print()
    print(game.board.description)
    print()
    print("x: \(game.board.count(of: .dark)), o: \(game.board.count(of: .light))")
    print()
    
    if case .over(let winner) = game.state {
        if let winner = winner {
            print("Winner: \(winner)")
        } else {
            print("Draw")
        }
    } else {
        print("-----")
        print()
    }

    moveCount += 1
}
