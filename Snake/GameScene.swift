import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var snake: Snake?
    private var food: Food?
    private var gameTimer: Timer?
    private var score: Int = 0
    private var scoreLabel: SKLabelNode?
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupGame()
        setupControls()
        startGame()
    }
    
    private func setupGame() {
        // 创建蛇
        snake = Snake(at: CGPoint(x: frame.midX, y: frame.midY))
        // 将蛇的所有身体段添加到场景中
        snake?.body.forEach { segment in
            addChild(segment)
        }
        
        // 创建食物
        spawnFood()
        
        // 创建分数标签
        scoreLabel = SKLabelNode(text: "分数: 0")
        scoreLabel?.position = CGPoint(x: frame.minX + 100, y: frame.maxY - 50)
        scoreLabel?.fontColor = .white
        addChild(scoreLabel!)
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
            // 在添加新段之前获取新段
            let newSegment = snake.grow()
            // 将新段添加到场景中
            addChild(newSegment)
            food.node.removeFromParent()
            spawnFood()
            score += 10
            scoreLabel?.text = "分数: \(score)"
        }
        
        // 检查是否撞到自己的身体
        // 跳过头部（索引0），从第1个身体段开始检查
        for i in 1..<snake.body.count {
            if snake.head.position == snake.body[i].position {
                gameOver()
                return
            }
        }
        
        // 检查是否撞墙
        if snake.head.position.x < frame.minX || snake.head.position.x > frame.maxX ||
           snake.head.position.y < frame.minY || snake.head.position.y > frame.maxY {
            gameOver()
        }
    }
    
    private func spawnFood() {
        var randomX: CGFloat
        var randomY: CGFloat
        var isValidPosition = false
        
        repeat {
            randomX = CGFloat.random(in: frame.minX...frame.maxX)
            randomY = CGFloat.random(in: frame.minY...frame.maxY)
            
            // 检查生成的位置是否与蛇的身体重叠
            isValidPosition = true
            for segment in snake!.body {
                if segment.position == CGPoint(x: randomX, y: randomY) {
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
        
        let gameOverLabel = SKLabelNode(text: "游戏结束! 得分: \(score)")
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverLabel.fontColor = .white
        addChild(gameOverLabel)
        
        let restartButton = SKLabelNode(text: "重新开始")
        restartButton.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        restartButton.fontColor = .white
        restartButton.name = "restartButton"
        addChild(restartButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        for node in nodes {
            if node.name == "restartButton" {
                scene?.view?.presentScene(GameScene(size: size))
                return
            }
        }
    }
} 