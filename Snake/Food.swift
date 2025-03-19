import SpriteKit

class Food {
    let position: CGPoint
    let node: SKShapeNode
    private let size: CGFloat = 20
    
    init(at position: CGPoint) {
        self.position = position
        // 创建一个标签节点来显示老鼠emoji
        let labelNode = SKLabelNode(text: "🐁")
        labelNode.fontSize = 30  // 增大字体大小
        labelNode.fontName = "Helvetica-Bold"  // 设置为加粗字体
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        labelNode.position = .zero  // 将位置设置在容器中心
        
        // 创建一个容器节点
        node = SKShapeNode(circleOfRadius: 1)
        node.alpha = 1  // 将 alpha 设为 1
        node.position = position
        node.addChild(labelNode)
    }
    
    func checkCollision(with point: CGPoint) -> Bool {
        let distance = hypot(point.x - position.x, point.y - position.y)
        return distance < size
    }
} 