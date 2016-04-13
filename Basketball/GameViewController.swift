//
//  GameViewController.swift
//  Baseball
//
//  Created by LoRoy on 4/13/16.
//  Copyright (c) 2016 LoRoy. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = BasketBallController()
        let view = SKView(frame: vc.view.frame)
        vc.view = view
        vc.view.backgroundColor = UIColor.whiteColor()
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsPhysics = true
        let size = CGSizeMake(768,1024)
        let scene = BasketBallScene(size: size)
        view.presentScene(scene)

//        let scene = BaseballScene(fileNamed:"BaeballScene") 
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        
        

    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
