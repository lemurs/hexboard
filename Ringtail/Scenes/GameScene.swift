
import UIKit
import SpriteKit

class GameScene: SKScene {
   
    var boardNode: SKNode {
        return childNodeWithName("board")!
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        println("Scene init \(boardNode)")
    }
    
}
