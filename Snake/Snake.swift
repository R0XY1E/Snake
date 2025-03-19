import SpriteKit

enum Direction {
    case up, down, left, right
}

class Snake {
    var body: [SKShapeNode]
    var head: SKShapeNode
    private var direction: Direction = .right
    private let segmentSize: CGFloat = 20
    
    init(at position: CGPoint) {
        head = SKShapeNode(rectOf: CGSize(width: 20, height: 20))
        head.fillColor = .green
        head.strokeColor = .green
        head.position = position
        
        body = [head]
        
        // 添加初始的两个身体段
        for i in 1...2 {
            let segment = SKShapeNode(rectOf: CGSize(width: 20, height: 20))
            segment.fillColor = .green
            segment.strokeColor = .green
            segment.position = CGPoint(x: position.x - CGFloat(i) * segmentSize, y: position.y)
            body.append(segment)
        }
    }
    
    func move() {
        // 保存所有段的当前位置
        var positions = body.map { $0.position }
        
        // 移动头部
        switch direction {
        case .right:
            head.position.x += segmentSize
        case .left:
            head.position.x -= segmentSize
        case .up:
            head.position.y += segmentSize
        case .down:
            head.position.y -= segmentSize
        }
        
        // 移动身体段
        for i in 1..<body.count {
            body[i].position = positions[i - 1]
        }
    }
    
    func changeDirection(_ newDirection: Direction) {
        // 防止180度转向
        switch (direction, newDirection) {
        case (.right, .left), (.left, .right),
             (.up, .down), (.down, .up):
            return
        default:
            direction = newDirection
        }
    }
    
    @discardableResult
    func grow() -> SKShapeNode {
        let newSegment = SKShapeNode(rectOf: CGSize(width: 20, height: 20))
        newSegment.fillColor = .green
        newSegment.strokeColor = .green
        newSegment.position = body.last?.position ?? head.position
        body.append(newSegment)
        return newSegment
    }
} 