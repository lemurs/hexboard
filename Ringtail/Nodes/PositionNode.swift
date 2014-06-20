
import UIKit
import SpriteKit

class PositionNode: SKNode {
    
    enum State {
        case Free
        case Occupied(base: Board.Base)
    }
    
    var state: State = .Free {
        didSet(previousState) {
            println("Did change to state: \(state)")
        }
    }
    
    var isBase: Bool = false {
        didSet(old) {
            println("Is base: \(isBase)")
        }
    }
    
    var shapeNode: SKShapeNode {
        if let node = childNodeWithName("shape") as? SKShapeNode {
            return node
        } else {
            let node = SKShapeNode(ellipseOfSize: size)
            node.name = "shape"
            node.fillColor = color
            addChild(node)
            return node
        }
    }
    
    var size: CGSize
    
    lazy var color: SKColor = SKColor.redColor()
    
    init(size: CGSize) {
        self.size = size
        super.init()
    }
 
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    func render() {
        shapeNode.fillColor = color
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        print(self.position)
        shapeNode.fillColor = SKColor.blueColor()
    }
}
