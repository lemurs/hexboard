
import UIKit
import XCPlayground

/**
 * Game Logic
 */

class Game {
    
    let boardWidthInCells: Double = 11
    
    class Player {
        var identifier: NSUUID
        
        init(identifier: NSUUID = NSUUID()) {
            self.identifier = identifier
        }
    }
    
    class Base {
        let player: Player
        let positon: Position
        
        init(player: Player, position: Position) {
            self.player = player
            self.positon = position
        }
    }
    
    struct Position: Equatable {
        var row: Int
        var column: Int
        var column_f:Double {
            return Double(column)
        }
        
        var row_f:Double {
            return Double(row)
        }
    
        var adjecentPositions: [Position] {
            let sizeInCells: Int = 11
            let rowOffset = (row % 2 == 1 ? 1 : -1)
            var positions = [Position]()
            
            // Same row
            positions.append(Position(row: row, column: column + 1))
            positions.append(Position(row: row, column: column - 1))
            
            // Row above
            positions.append(Position(row: row + 1, column: column))
            positions.append(Position(row: row + 1, column: column + rowOffset))

            // Row below
            positions.append(Position(row: row - 1, column: column))
            positions.append(Position(row: row - 1, column: column + rowOffset))
            
            return positions.filter { self.inBounds($0, size: sizeInCells) }
        }
        
        func inBounds(position: Position, size:Int = 11) -> Bool {
            return (position.row < size && position.row >= 0) && (position.column < size && position.column >= 0)
        }
    }
    
    enum PositionState {
        case Illigal
        case Empty
        case Occupied(base: Base)
    }
    
    let bases: [Base]
    
    let basePositions = [
        Position(row: 0, column: 3),
        Position(row: 5, column: 0),
        Position(row: 10, column: 3),
        Position(row: 10, column: 8),
        Position(row: 5, column: 10),
        Position(row: 5, column: 10),
        Position(row: 0, column: 8)
    ]
    
    var positions = Dictionary<Position, PositionState>()
    
    var currentBase:Base {
        return bases[0]
    }
    
    var currentPlayer:Player {
        return players[0]
    }
    
    let players: [Player]
    
    init(players: [Player] = [Player(), Player(), Player()]) {
        self.players = players
        self.bases = basePositions.map {
          (var position) -> Base in
            return Base(player: Player(), position: position)
        }
        
        for position in basePositions {
            let base = Base(player: Player(), position: position)
            self[position] = PositionState.Occupied(base: base)
        }
    }
    
    subscript(position: Position) -> PositionState {
        get {
            if isPlayablePosition(position) == true {
                if let state = positions[position] {
                    return state
                }
                return PositionState.Empty
            }
            return PositionState.Illigal
        }
        
        set(newState) {
            if isPlayablePosition(position) == true {
                positions[position] = newState
            }
        }
    }
    
    func isOutOffBounds(position: Position) -> Bool {
        let missingCells = abs(position.row_f - 5)
        let missingAnte = ceil(missingCells / 2.0)
        let missingPost = floor(missingCells / 2.0);
        
        return (position.column_f < missingAnte || position.column_f >= boardWidthInCells - missingPost)
    }
    
    func isEmpty(position: Position) -> Bool {
        if position.row % 2 == 1 {
            if position.column == 2 || position.column == 5 || position.column == 8 {
                return true
            }
        } else if position.column == 1 || position.column == 4 || position.column == 7 || position.column == 10 {
            return true
        }
        return false
    }
    
    func isPlayablePosition(position: Position) -> Bool {
        return !isEmpty(position) && !isOutOffBounds(position)
    }
    
    func play(position: Position) -> Bool {
        return false
    }
}

func ==(lhs: Game.Position, rhs: Game.Position) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}

extension Game.Position: Hashable {
    var hashValue: Int {
        get {
            return (row * 10000) + (column)
        }
    }
}


/**
 * Game Scene
 */

import SpriteKit

extension Game {
    class Scene: SKScene {
        override func didMoveToView(view: SKView) {
            let node = SKShapeNode(circleOfRadius: 100.0)
            node.strokeColor = UIColor.redColor()
            node.fillColor = UIColor.blueColor()
            addChild(node)
            
            super.didMoveToView(view)
        }
        
        class func unarchiveFromFile(file : NSString) -> SKNode? {
            let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks")
            let sceneData = NSData.dataWithContentsOfFile(path!, options: .DataReadingMappedIfSafe, error: nil)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)

            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as Game.Scene
            archiver.finishDecoding()
            
            return scene
        }
    }
}

let gameFrame = CGRect(x: 0, y: 0, width: 400, height: 300)
let gameView = SKView(frame: gameFrame)
let gameScene = Game.Scene.unarchiveFromFile("GameScene") as Game.Scene



gameView.presentScene(gameScene)
gameView

XCPShowView("New Lemurs Hex Game", gameView);

/**
 * Playing the game
 **/

// Playing a game

let players = [Game.Player(), Game.Player(), Game.Player()]
let game = Game(players: players)

var player = game.currentPlayer
var base = game.currentBase

if game.play(Game.Position(row: 10, column: 10)) {
    println("Played position")
} else {
    println("Could not play position")
}

XCPShowView("New Lemurs Hex Game 2", gameView);

game.currentBase.positon.adjecentPositions.map {
    "Adject positin: \($0.row) - \($0.column)"
}.map(println)


for position in game.currentBase.positon.adjecentPositions {
    println("Adject positin: \(position.row) - \(position.column)")
}

for position in base.positon.adjecentPositions {
    println("Position \(position.row) - \(position.column)")
    switch game[position] {
        case .Illigal:
            println("Not playable")
        case .Occupied(let base):
            let theBase = base // NOTE: Not sure why I only get access to the properties when reassigning
            println("This position is taken by \(theBase.player.identifier.UUIDString)")
        case .Empty:
            println("This position is empty")
        default:
            println("Unknown type, should not happen")
    }

}

for (position, state) in game.positions {
    switch state {
        case .Illigal:
            println("Something invalid!")
        case .Occupied(let base):
            let theBase = base // NOTE: Not sure why I only get access to the properties when reassigning
            println("This position is taken by \(theBase.player.identifier.UUIDString)")
        case .Empty:
            println("This position is empty")
        default:
            println("Unknown type, should not happen")
    }
    
    println("Adjecent to position: \(position.row) - \(position.column)")
    for position in position.adjecentPositions {
        println("Adjecent: \(position.row) - \(position.column)")
    }
}

XCPShowView("New Lemurs Hex Game 2", gameView);
