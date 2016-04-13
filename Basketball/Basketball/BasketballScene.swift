//
//  GameScene.swift
//  Basketball
//
//  Created by LoRoy on 4/13/16.
//  Copyright (c) 2016 LoRoy. All rights reserved.
//

import SpriteKit

class BasketBallScene: SKScene, SKPhysicsContactDelegate {
    var contentCreated:Bool = false
    var ball:BasketBallNode?
    var basket:Basket?
    var scoreText:SKLabelNode?
    var score:Int = 0 {
        didSet {
            scoreText?.text = "Score: \(score)"
        }
    }
    override func didMoveToView(view: SKView) {
        guard !contentCreated else { return }
        createContent()
        contentCreated = true
    }
    
    func createContent(){
        backgroundColor = SKColor.whiteColor()
        self.scaleMode = .AspectFit
        addChild(newBallNode())
        addChild(newBasketNode())
        addChild(newScoreText())
        physicsWorld.contactDelegate = self
    }
    
    func ballPosition() -> CGPoint {
        return CGPointMake(CGRectGetMidX(frame), 50)
    }
    
    func newScoreText() -> SKLabelNode {
        let n = SKLabelNode()
        scoreText = n
        n.fontSize = 70
        n.fontName = "helvetica"
        n.fontColor = UIColor.blackColor()
        n.text = "Score: 0"
        n.zPosition = -2
        n.position = CGPointMake(CGRectGetMidX(frame), 500)
        return n
    }
    
    func newBasketNode() -> Basket {
        let basket = Basket()
        self.basket = basket
        basket.position = CGPointMake(CGRectGetMidX(frame) - basket.rad/2, 700)
        return basket
    }
    
    func newBallNode() -> SKLabelNode {
        let node = BasketBallNode()
        ball = node
        node.position = ballPosition()
        node.userInteractionEnabled = true
        return node
    }
    
    func resetBall() {
        ball?.reset(ballPosition())
        basket?.ringEnabled = false
    }
    
    func ballAboveRing()->Bool {
        return basket?.position.y < ball?.position.y
    }
    
    override func update(currentTime: NSTimeInterval) {
        if ballAboveRing() {
            basket?.ringEnabled = true
            ball?.appearBeforeRing = false
        }
        if ball?.position.y < -300 {
            resetBall()
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        guard basket!.ringEnabled else { return }
        score += 1
    }
}

class Basket:SKNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    let rad:CGFloat = 200
    let h:CGFloat = 10
    var ring:SKShapeNode?
    override init() {
        super.init()
        initRing()
        initScoreSensor()
    }
    
    var sensor:SKNode?
    func initScoreSensor() {
        sensor = SKNode()
        let phy = SKPhysicsBody(circleOfRadius: 3*h, center: CGPointMake(rad/2, -rad/2))
        phy.affectedByGravity = false
        phy.dynamic = false
        phy.collisionBitMask = CollisionMask.None
        phy.contactTestBitMask = CollisionMask.Ball
        phy.categoryBitMask = CollisionMask.Sensor
        sensor!.physicsBody = phy
        addChild(sensor!)
    }
    
    func initRing() {
        ring = SKShapeNode(rect: CGRectMake(0, 0, rad, 2*h))
        ring!.fillColor = UIColor.redColor()
        let l = SKPhysicsBody(edgeFromPoint: CGPointMake(0, 2*h), toPoint: CGPointMake(3*h, 2*h))
        let r = SKPhysicsBody(edgeFromPoint: CGPointMake(rad-3*h, 2*h), toPoint: CGPointMake(rad, 2*h))
        ring!.physicsBody = SKPhysicsBody(bodies: [l,r])
        ring!.physicsBody?.affectedByGravity = false
        ring!.physicsBody?.dynamic = false
        ringEnabled = false
        addChild(ring!)
    }
    var ringEnabled:Bool {
        set {
            ring?.physicsBody?.collisionBitMask = newValue ? CollisionMask.Ball : CollisionMask.None
            ring?.physicsBody?.categoryBitMask = newValue ? CollisionMask.Basket : CollisionMask.None
        }
        get {
            return ring?.physicsBody?.collisionBitMask == CollisionMask.Ball
        }
    }
}

struct CollisionMask {
    static let None : UInt32 = 0
    static let Ball : UInt32 = 0b1
    static let Basket : UInt32 = 0b10
    static let Sensor : UInt32 = 0b100
}

class BasketBallNode : SKLabelNode {
    var dragStart:CGPoint?
    
    override init() {
        super.init()
        text = "🏀"
        fontColor = UIColor.blackColor()
        fontSize = 200
        physicsBody = SKPhysicsBody(circleOfRadius: 95, center: CGPointMake(0, 75))
        physicsBody?.affectedByGravity = false
        physicsBody?.restitution = 0.8
        physicsBody?.categoryBitMask =  CollisionMask.Ball
        physicsBody?.collisionBitMask = CollisionMask.Basket
        appearBeforeRing = true
    }
    
    var appearBeforeRing:Bool {
        set { zPosition = newValue ? 1 : -1 }
        get { return zPosition == 1 }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touches
        guard dragStart == nil else { return }
        dragStart = touches.first?.locationInNode(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let start = dragStart else { return }
        let end = touches.first!.locationInNode(self)
        shoot(start, to: end)
        dragStart = nil
    }
    
    func shoot(from:CGPoint, to:CGPoint){
        let dx = (to.x-from.x)/2.5
        let dy = to.y-from.y
        let norm = sqrt(pow(dx, 2) + pow(dy, 2))
        let base:CGFloat = 2000
        physicsBody?.affectedByGravity = true
        let impulse = CGVectorMake(base * (dx/norm), base * (dy/norm))
        physicsBody?.applyImpulse(impulse)
        let scale:CGFloat = 0.5
        let scaleDuration:NSTimeInterval = 1.1
        runAction(SKAction.scaleBy(scale, duration: scaleDuration))
        to.x - from.x > 0 ? runAction(SKAction.rotateByAngle(-1, duration: scaleDuration)) : runAction(SKAction.rotateByAngle(1, duration: scaleDuration))
    }
    func reset(pos:CGPoint){
        physicsBody?.affectedByGravity = false
        physicsBody?.velocity = CGVectorMake(0, 0)
        physicsBody?.angularVelocity = 0
        zPosition = 1
        zRotation = 0
        position = pos
        xScale = 1
        yScale = 1
        appearBeforeRing = true
    }
}

class BasketBallController: UIViewController {
}