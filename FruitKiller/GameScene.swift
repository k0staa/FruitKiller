//
//  GameScene.swift
//  FruitKiller
//
//  Created by Michal Kostewicz on 24/12/16.
//  Copyright (c) 2016 Michal Kostewicz. All rights reserved.
//

import SpriteKit

var knife = SKSpriteNode()
var fruitArray = [SKSpriteNode]()
var resetButtonSprite = SKSpriteNode(imageNamed: "button_restart")
var gameEndsLabel = SKLabelNode(fontNamed:"Chalkduster")
var gameRunning = true
var points = 0
var pointsGained = SKLabelNode(fontNamed:"Chalkduster")
var fruitOccuranceLastTimer = NSTimer()
var knifeMovementTimer = NSTimer()
var lastFruitLocation = CGPoint()
var touchLocation = CGPoint()
var screenTouched:Bool = false
var currentTouchedFruit:SKSpriteNode?
var knifeSprite = SKSpriteNode(imageNamed: "myKnife2")
var knifeOnUpperEnd = false
var currentKnifeSpeed:CGFloat = 120.0;

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let pointsLabel = SKLabelNode(fontNamed:"Chalkduster")
        pointsLabel.text = "POINTS: ";
        pointsLabel.fontSize = 25;
        pointsLabel.color = .redColor()
        pointsLabel.position = CGPoint(x:100, y:600);
        pointsLabel.zPosition = 1
        
        pointsGained.text = String(points);
        pointsGained.fontSize = 25;
        pointsGained.position = CGPoint(x:200, y:600);
        pointsGained.zPosition = 1
        
        let bgTableImage = SKSpriteNode(imageNamed: "qubodup-light_wood")
        bgTableImage.xScale = 1
        bgTableImage.yScale = 0.7
        bgTableImage.position = CGPointMake(self.size.width/2, self.size.height/2 )
        bgTableImage.zPosition = -1
        
        knifeSprite.xScale = 0.4
        knifeSprite.yScale = 0.4
        knifeSprite.position = CGPointMake(self.size.width/2, 120 )
        knifeSprite.zPosition = 2
        
        self.addChild(knifeSprite)
        self.addChild(bgTableImage)
        self.addChild(pointsLabel)
        self.addChild(pointsGained)
        
        sheduledFruitCreating()

    }
    
    func sheduledKnifeMove(){
        if !knifeOnUpperEnd{
            let knifeDestinationPointUp = CGPointMake(self.size.width/2, self.size.height)
            let moveUp = SKAction.moveTo(knifeDestinationPointUp, duration: moveKnife(knifeSprite.position,pointB: knifeDestinationPointUp,speed: currentKnifeSpeed))
            knifeSprite.runAction(moveUp, completion: {
                knifeOnUpperEnd = true
            })
        }else{
            let knifeDestinationPointDown = CGPointMake(self.size.width/2, 120)
            let moveDown = SKAction.moveTo(knifeDestinationPointDown, duration: moveKnife(knifeSprite.position,pointB: knifeDestinationPointDown,speed: currentKnifeSpeed))
            knifeSprite.runAction(moveDown, completion: {
                knifeOnUpperEnd = false
            })
        }
    }
    
    func moveKnife(pointA:CGPoint,pointB:CGPoint,speed:CGFloat)->NSTimeInterval{
        let xDist = (pointB.x - pointA.x)
        let yDist = (pointB.y - pointA.y)
        let distance = sqrt((xDist * xDist) + (yDist * yDist));
        let duration : NSTimeInterval = NSTimeInterval(distance/speed)
        return duration
    
    }
    
    func sheduledFruitCreating(){
        fruitOccuranceLastTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("createFruit"), userInfo: nil, repeats: true)
    }
    
    func createFruit(){
        if lastFruitLocation.y == 0 {
            lastFruitLocation = CGPoint(x:10 , y: 120)
        }else if lastFruitLocation.y > 600 {
            lastFruitLocation.y = 120
        }else {
            lastFruitLocation.y += 50
        }
        let sprite = getRandomFruit()
        
        sprite.position = lastFruitLocation
        fruitArray.append(sprite)
        self.addChild(sprite)
    
    }
    
    func getRandomFruit() -> SKSpriteNode {
        let random = Int(arc4random_uniform(3))
        var Fruit = SKSpriteNode()
        switch random {
        case 0 : Fruit = SKSpriteNode(imageNamed: "apple")
        case 1 : Fruit = SKSpriteNode(imageNamed: "cherry")
        case 2 : Fruit = SKSpriteNode(imageNamed: "plum")
        default : Fruit = SKSpriteNode(imageNamed: "apple")
        }
        Fruit.size = CGSize(width: 80, height: 80)
        Fruit.zPosition = 0
        return Fruit
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Start moving node to touch location */
        screenTouched = true
        for touch in touches {
            touchLocation = touch.locationInNode(self)
        }
        currentTouchedFruit = getCurrentlyTouchedFruit()
        if(resetButtonSprite.containsPoint(touchLocation)){
            gameRestart()
        }
    }
    
    func gameRestart(){
        sheduledFruitCreating()
        gameRunning = true
        points = 0
        currentKnifeSpeed = 120.0
        resetButtonSprite.removeFromParent()
        gameEndsLabel.removeFromParent()
        clearFruitArray()
    }
    
    func clearFruitArray(){
        for fruit in fruitArray {
           fruit.removeFromParent()
        }
    }
    
    func getCurrentlyTouchedFruit() -> SKSpriteNode?{
        for fruit in fruitArray {
            if(fruit .containsPoint(touchLocation)){
                return fruit
            }
        }
        return nil;
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Update to new touch location */
        for touch in touches {
            touchLocation = touch.locationInNode(self)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Stop node from moving to touch
        if currentTouchedFruit != nil && currentTouchedFruit!.position.x > self.size.width/2 + 10 {
            points += 10
            currentKnifeSpeed += 10
            addFruitExplosion(currentTouchedFruit)
            currentTouchedFruit?.removeFromParent()
        }
        screenTouched = false
        currentTouchedFruit = nil
    }
    
    func addFruitExplosion(fruit: SKSpriteNode?){
        let fruitExplodeEmiter = SKEmitterNode(fileNamed: "FruitExplode")
        fruitExplodeEmiter?.setScale(0.2)
        fruitExplodeEmiter?.position = fruit!.position
        fruitExplodeEmiter?.particleColor = UIColor.redColor()
        fruitExplodeEmiter?.particleBirthRate = 30
        let addEmitterAction = SKAction.runBlock({self.addChild(fruitExplodeEmiter!)})
        
        let emitterDuration = 5.0
        
        let wait = SKAction.waitForDuration(NSTimeInterval(emitterDuration))
        
        let remove = SKAction.runBlock({fruitExplodeEmiter!.removeFromParent(); })
        
        let sequence = SKAction.sequence([addEmitterAction, wait, remove])
        
        self.runAction(sequence)
    
    }
    
    func removeFruitExplodeEmiter (target: SKEmitterNode){
            target.removeFromParent()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if(gameRunning){
            var knifeTouched = false
            if (screenTouched) {
                knifeTouched = moveFruitSpriteNodeToLocation()
            }
            pointsGained.text = String(points);
            checkIfGameEnds(knifeTouched)
            sheduledKnifeMove()
        }
    }
    
    func checkIfGameEnds(isKnifeTouched: Bool){
        if(isKnifeTouched){
            addGameEndLabel()
            addResetButtonSprite()
            fruitOccuranceLastTimer.invalidate()
            gameRunning = false
        }
    }
    
    func addResetButtonSprite(){
        resetButtonSprite.xScale = 0.6
        resetButtonSprite.yScale = 0.6
        resetButtonSprite.position = CGPointMake(self.size.width/2, self.size.height/2 - 100 )
        resetButtonSprite.zPosition = 2
        self.addChild(resetButtonSprite)
    }
    
    func addGameEndLabel(){
        gameEndsLabel.text = "GAME OVER";
        gameEndsLabel.fontSize = 60;
        gameEndsLabel.color = .redColor()
        gameEndsLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2);
        gameEndsLabel.zPosition = 2
        self.addChild(gameEndsLabel)
    }
    
    // Move the node to the location of the touch
    func moveFruitSpriteNodeToLocation() -> Bool{
        // Node speed
        let speed:CGFloat = 0.25
        // Compute vector components in direction of the touch
        if(currentTouchedFruit != nil){
            let currentFruit = currentTouchedFruit!
            var dx = touchLocation.x - currentFruit.position.x
            var dy = touchLocation.y - currentFruit.position.y
        // Scale vector
            dx = dx * speed
            dy = dy * speed
            currentFruit.position = CGPointMake(currentFruit.position.x+dx, currentFruit.position.y+dy)
            if(knifeSprite.containsPoint(currentTouchedFruit!.position)){
                    return true
            }
        }
        return false
    }

}
