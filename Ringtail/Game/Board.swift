
import UIKit

class Board {
    
    let widthInCells: Double = 11
    
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
    
    struct Position {
        var row: Int
        var column: Int
        
        var boardWidth: Int {
            return 11
        }
        
        var column_f:Double {
            return Double(column)
        }
        
        var row_f:Double {
            return Double(row)
        }
        
        var adjecentPositions: [Position] {
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
            
            return positions.filter { self.inBounds($0) }
        }
        
        func inBounds(position: Position) -> Bool {
            return (position.row < boardWidth && position.row >= 0) && (position.column < boardWidth && position.column >= 0)
        }
        
        func point(frame: CGRect) -> CGPoint {
            return point(frame).point
        }
        
        func point(frame: CGRect) -> (point: CGPoint, size: CGSize) {
            let xCorrection: CGFloat = 1.9
            let yCorrection: CGFloat = 1.5
            let radius: CGFloat = min(frame.size.width / CGFloat(boardWidth) , frame.size.height / CGFloat(boardWidth))
            let x = radius * xCorrection * CGFloat(column) + radius * CGFloat(row % 2)
            let y = radius + radius * yCorrection * CGFloat(row)
            return (CGPoint(x: x, y: y), CGSize(width: radius * 2, height: radius * 2))
        }
    }
    
    enum State {
        case Illigal
        case Empty
        case Occupied(base: Base)
        
        func getLogicValue() -> Bool {
            switch self {
            case Occupied(let base):
                return true
            default:
                return false
            }
        }
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
    
    var positions = Dictionary<Position, State>()
    
    var currentBase:Base {
        return bases[0]
    }
    
    var currentPlayer:Player {
        return players[0]
    }
    
    let players: [Player]
    
    var playablePositions: [Position] {
        var result = [Position]()
        for row in (0...Int(widthInCells)) {
            for column in (0...Int(widthInCells)) {
                let position = Position(row: row, column: column)
                if (isPlayablePosition(position)) {
                    result.append(position)
                }
            }
        }
        return result
    }
    
    init(players: [Player] = [Player(), Player(), Player()]) {
        self.players = players
        self.bases = basePositions.map {
            (var position) -> Base in
            return Base(player: Player(), position: position)
        }
        
        for position in basePositions {
            let base = Base(player: Player(), position: position)
            self[position] = State.Occupied(base: base)
        }
    }
    
    subscript(position: Position) -> State {
        get {
            if isPlayablePosition(position) == true {
                if let state = positions[position] {
                    return state
                }
                return State.Empty
            }
            return State.Illigal
        }
        
        set(state) {
            if isPlayablePosition(position) != true {
                return
            }
            
            switch state {
            case .Empty:
                positions[position] = nil
            case .Occupied:
                positions[position] = state
            case .Illigal:
                println("Can not set state to illigal")
            default:
                println("Unkown state provided: \(state)")
            }
        }
    }
    
    subscript(row: Int, column: Int) -> State {
        get {
            return self[Position(row: row, column: column)]
        }
        
        set(state) {
            self[Position(row: row, column: column)] = state
        }
    }
    
    func isOutOffBounds(position: Position) -> Bool {
        let missingCells = abs(position.row_f - 5)
        let missingAnte = ceil(missingCells / 2.0)
        let missingPost = floor(missingCells / 2.0);
        
        return (position.column_f < missingAnte || position.column_f >= widthInCells - missingPost)
    }
    
    func isGapPosition(position: Position) -> Bool {
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
        return !isGapPosition(position) && !isOutOffBounds(position)
    }
    
    func play(position: Position) -> Bool {
        return false
    }
    
    func mapPositions<T>(block: (Position) -> T) -> [T] {
        return playablePositions.map(block)
    }
}


extension Board.Position: Hashable, Equatable {
    var hashValue: Int {
        get {
            return (row * 10000) + (column)
        }
    }
}

func ==(lhs: Board.Position, rhs: Board.Position) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}
