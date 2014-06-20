
import UIKit
import SpriteKit

class GameViewController: UIViewController {

    // #pragma mark - Outlets
    
    @IBOutlet var sceneView: SKView?
    
    lazy var board = Board()

    
    // #pragma mark - Initializers
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    // #pragma mark - UIViewController

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        println("Memory pressure")
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = unarchiveScene()
        sceneView?.presentScene(scene)
        
        let sprites: [PositionNode] = board.mapPositions {
            (position: Board.Position) -> PositionNode in
            let (point: CGPoint, size: CGSize) = position.point(self.sceneView!.frame)
            println("Point: \(point) size: \(size)")
            let node = PositionNode(size: size)
            node.position = point
            node.userInteractionEnabled = true
            return node
        }
        
        for node in sprites {
            scene?.addChild(node)
            scene?.scaleMode = .AspectFit
            node.render()
        }
    }
    
    func unarchiveScene() -> GameScene? {
        let scenePath = NSBundle.mainBundle().pathForResource("GameScene", ofType: "sks")
        let sceneData = NSData(contentsOfFile: scenePath!)
        let unarchiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
        
        unarchiver.setClass(GameScene.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = unarchiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
        unarchiver.finishDecoding()
        
        return scene
    }
}
