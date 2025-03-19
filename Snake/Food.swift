import SpriteKit

class Food {
    let position: CGPoint
    let node: SKShapeNode
    private let size: CGFloat = 20
    
    init(at position: CGPoint) {
        self.position = position
        node = SKShapeNode(circleOfRadius: 10)
        node.fillColor = .red
        node.strokeColor = .red
        node.position = position
    }
    
    func checkCollision(with point: CGPoint) -> Bool {
        let distance = hypot(point.x - position.x, point.y - position.y)
        return distance < size
    }
} 