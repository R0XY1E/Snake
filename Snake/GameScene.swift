import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var snake: Snake?
    private var food: Food?
    private var gameTimer: Timer?
    private var score: Int = 0
    private var scoreLabel: SKLabelNode?
    private var walls: [SKShapeNode] = []  // 添加墙壁数组
    
    override func didMove(to view: SKView) {
        // 等待下一帧再设置游戏，确保 safeArea 已经正确计算
        DispatchQueue.main.async {
            self.backgroundColor = .white  // 改成白色背景
            self.setupGame()
            self.setupWalls()  // 添加设置墙壁的方法
            self.setupControls()
            self.startGame()
        }
    }
    
    private func setupGame() {
        // 获取安全区域
        let safeArea = view?.safeAreaInsets ?? UIEdgeInsets.zero
        
        // 计算可用游戏区域
        let playableWidth = frame.width - (safeArea.left + safeArea.right)
        let playableHeight = frame.height - (safeArea.top + safeArea.bottom)
        let playableRect = CGRect(x: frame.minX + safeArea.left,
                                y: frame.minY + safeArea.bottom,
                                width: playableWidth,
                                height: playableHeight)
        
        // 创建蛇，确保蛇的初始位置在安全区域内
        snake = Snake(at: CGPoint(x: playableRect.midX, y: playableRect.midY))
        snake?.body.forEach { segment in
            addChild(segment)
        }
        
        // 创建食物
        spawnFood()
        
        // 创建分数标签，确保在安全区域内
        scoreLabel = SKLabelNode(text: "分数: 0")
        scoreLabel?.position = CGPoint(x: playableRect.minX + 100,
                                     y: playableRect.maxY - 50 - safeArea.top) // 确保不与红墙重叠
        scoreLabel?.fontColor = UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0) // 天蓝色
        scoreLabel?.fontName = "Helvetica-Bold"  // 设置为加粗字体
        addChild(scoreLabel!)
    }
    
    private func setupWalls() {
        let safeArea = view?.safeAreaInsets ?? UIEdgeInsets.zero
        
        // 计算可用游戏区域，左右墙面完全贴合屏幕边缘
        let margin: CGFloat = 10  // 只用于上下墙面
        let wallThickness: CGFloat = 4
        
        // 左右墙面完全贴合屏幕边缘
        let left = frame.minX + safeArea.left
        let right = frame.maxX - safeArea.right
        // 上下墙面保持一定间距
        let top = frame.maxY - safeArea.top - margin
        let bottom = frame.minY + safeArea.bottom + margin
        
        // 创建四面墙的矩形
        let wallRects = [
            // 上墙
            CGRect(x: left, y: top - wallThickness, 
                  width: right - left, height: wallThickness),
            // 下墙
            CGRect(x: left, y: bottom, 
                  width: right - left, height: wallThickness),
            // 左墙 - 完全贴合左边缘
            CGRect(x: left, y: bottom, 
                  width: wallThickness, height: top - bottom),
            // 右墙 - 完全贴合右边缘
            CGRect(x: right - wallThickness, y: bottom, 
                  width: wallThickness, height: top - bottom)
        ]
        
        // 红砖色
        let brickColor = UIColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 1.0)
        
        // 创建并添加墙壁
        for wallRect in wallRects {
            let wall = SKShapeNode(rect: wallRect, cornerRadius: 0)
            wall.fillColor = brickColor
            wall.strokeColor = brickColor
            wall.name = "wall"
            addChild(wall)
            self.walls.append(wall)
        }
    }
    
    private func setupControls() {
        // 添加手势识别器
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRight.direction = .right
        view?.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeLeft.direction = .left
        view?.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUp.direction = .up
        view?.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeDown.direction = .down
        view?.addGestureRecognizer(swipeDown)
    }
    
    private func startGame() {
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(gameLoop), userInfo: nil, repeats: true)
    }
    
    @objc private func gameLoop() {
        snake?.move()
        checkCollision()
    }
    
    private func checkCollision() {
        guard let snake = snake, let food = food else { return }
        
        // 检查是否吃到食物
        if food.checkCollision(with: snake.head.position) {
            let newSegment = snake.grow()
            addChild(newSegment)
            food.node.removeFromParent()
            spawnFood()
            score += 10
            scoreLabel?.text = "分数: \(score)"
        }
        
        // 检查是否撞到自己的身体
        for i in 1..<snake.body.count {
            if snake.head.position == snake.body[i].position {
                gameOver()
                return
            }
        }
        
        // 改进墙壁碰撞检测
        let snakeHeadFrame = CGRect(
            x: snake.head.position.x - 10,
            y: snake.head.position.y - 10,
            width: 20,
            height: 20
        )
        
        for wall in walls {
            if wall.frame.intersects(snakeHeadFrame) {
                gameOver()
                return
            }
        }
    }
    
    private func spawnFood() {
        var randomX: CGFloat
        var randomY: CGFloat
        var isValidPosition = false
        
        let safeArea = view?.safeAreaInsets ?? UIEdgeInsets.zero
        let margin: CGFloat = 10  // 与墙壁保持一致的间距
        let padding: CGFloat = 15 // 与墙的额外安全距离
        
        // 计算可用游戏区域
        let playableMinX = frame.minX + safeArea.left + margin + padding
        let playableMaxX = frame.maxX - safeArea.right - margin - padding
        let playableMinY = frame.minY + safeArea.bottom + margin + padding
        let playableMaxY = frame.maxY - safeArea.top - margin - padding
        
        let gridSize: CGFloat = 20
        
        repeat {
            let columnsCount = Int((playableMaxX - playableMinX) / gridSize)
            let rowsCount = Int((playableMaxY - playableMinY) / gridSize)
            
            let randomColumn = Int.random(in: 0..<columnsCount)
            let randomRow = Int.random(in: 0..<rowsCount)
            
            randomX = playableMinX + CGFloat(randomColumn) * gridSize
            randomY = playableMinY + CGFloat(randomRow) * gridSize
            
            isValidPosition = true
            
            // 检查是否与蛇身体重叠
            for segment in snake!.body {
                let distance = hypot(segment.position.x - randomX, segment.position.y - randomY)
                if distance < gridSize {
                    isValidPosition = false
                    break
                }
            }
        } while !isValidPosition
        
        food = Food(at: CGPoint(x: randomX, y: randomY))
        addChild(food!.node)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .right:
            snake?.changeDirection(.right)
        case .left:
            snake?.changeDirection(.left)
        case .up:
            snake?.changeDirection(.up)
        case .down:
            snake?.changeDirection(.down)
        default:
            break
        }
    }
    
    private func gameOver() {
        gameTimer?.invalidate()
        gameTimer = nil
        
        // 直接使用 view?.safeAreaInsets
        let skyBlue = UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0)
        
        // 创建游戏结束标签
        let gameOverLabel = SKLabelNode(text: "游戏结束! 得分: \(score)")
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverLabel.fontColor = skyBlue
        gameOverLabel.fontName = "Helvetica-Bold"  // 设置为加粗字体
        addChild(gameOverLabel)
        
        // 创建重新开始按钮
        let restartButton = SKLabelNode(text: "重新开始")
        restartButton.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        restartButton.fontColor = skyBlue
        restartButton.fontName = "Helvetica-Bold"  // 设置为加粗字体
        restartButton.name = "restartButton"
        addChild(restartButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        for node in nodes {
            if node.name == "restartButton" {
                // 创建新场景时，确保传递正确的尺寸
                let newScene = GameScene(size: size)
                newScene.scaleMode = scaleMode
                scene?.view?.presentScene(newScene)
                return
            }
        }
    }
} 