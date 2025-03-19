//
//  GameViewController.swift
//  Snake
//
//  Created by Roy Xie on 2025/3/19.
//

import UIKit
import SpriteKit

// Our iOS specific view controller
class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // 创建游戏场景
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            
            // 设置视图
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            
            #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
            #endif
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
