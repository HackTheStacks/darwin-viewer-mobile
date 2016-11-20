
//
//  GameScene.swift
//  drag
//
//  Created by Robert Carlsen on 11/19/16.
//  Copyright © 2016 Robert Carlsen. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    
    fileprivate var label : SKLabelNode?
    var selectedNode: SKNode? {
        didSet {
            oldValue?.zPosition = -1
            selectedNode?.zPosition = 1
        }
    }
    var selectedNodeScale: CGFloat = 1.0

    lazy var fragmentImages:[UIImage] = {
        return [#imageLiteral(resourceName: "MS-DAR-00002-000-197"), #imageLiteral(resourceName: "MS-DAR-00002-000-199"), #imageLiteral(resourceName: "MS-DAR-00002-000-205")]
    }()


    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill

        return scene
    }
    
    func setUpScene() {
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }

        for image in fragmentImages {
            let imageNode = SKSpriteNode(texture: SKTexture(image: image))
            imageNode.setScale(0.3)
            imageNode.blendMode = .screen
            imageNode.zPosition = -1

            if let bounds = self.view?.bounds {
                let windowMiddle = CGPoint(x:bounds.midX, y:bounds.midY)
                let randX = CGFloat(arc4random_uniform(UInt32(bounds.size.width/2.0))) - windowMiddle.x
                let randY = CGFloat(arc4random_uniform(UInt32(bounds.size.height/2.0))) - windowMiddle.y
                imageNode.position = CGPoint(x: randX + windowMiddle.x, y:randY + windowMiddle.y)
            }
            self.addChild(imageNode)
        }

    }

    override func didMove(to view: SKView) {
        self.setUpScene()

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        self.view?.addGestureRecognizer(pinchGesture)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

#if os(iOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches {
//            print("touch: \(t)")
//        }

        if let touch = touches.first {
            self.selectedNode = self.atPoint(touch.location(in: self))
            self.selectedNode?.removeAllActions()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches {
//            print("touch: \(t)")
//        }

        if let touch = touches.first {
            let touchLoc = touch.location(in:self)
            let prevTouchLoc = touch.previousLocation(in:self)

            if let node = self.selectedNode {
                let newYPos = node.position.y + (touchLoc.y - prevTouchLoc.y)
                let newXPos = node.position.x + (touchLoc.x - prevTouchLoc.x)

                node.position = CGPoint(x:newXPos, y:newYPos)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches {
//            print("touch: \(t)")
//        }
//        self.selectedNode = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches {
//            print("touch: \(t)")
//        }
//        self.selectedNode = nil
    }

    func handlePinch(gesture:UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            let location = gesture.location(in: gesture.view)
            let nodeLocation = self.convertPoint(fromView: location)
            let node = self.atPoint(nodeLocation)
            self.selectedNode = node
            self.selectedNodeScale = node.xScale

        case .changed:
            if let node = self.selectedNode {
                node.setScale(selectedNodeScale * gesture.scale) // not likely correct
            }
        case .ended:
            self.selectedNode = nil
        default:
            break
        }
    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        print("event: \(event)")
    }

    override func mouseDragged(with event: NSEvent) {
        print("event: \(event)")
    }
    
    override func mouseUp(with event: NSEvent) {
        print("event: \(event)")
    }

// none of these seem to be recognized
//
//    override func smartMagnify(with event: NSEvent) {
//        print("event: \(event)")
//    }
//    override func magnify(with event: NSEvent) {
//        print("magnify event: \(event)")
//    }
//    override func rotate(with event: NSEvent) {
//        print("rotate event: \(event)")
//    }
//    override func swipe(with event: NSEvent) {
//        print("event: \(event)")
//    }
//
//    override func beginGesture(with event: NSEvent) {
//        print("event: \(event)")
//    }
//    override func endGesture(with event: NSEvent) {
//        print("event: \(event)")
//    }
//    override func touchesMoved(with event: NSEvent) {
//        print("event: \(event)")
//    }
//    override func touchesBegan(with event: NSEvent) {
//        print("event: \(event)")
//    }
//    override func touchesEnded(with event: NSEvent) {
//        print("event: \(event)")
//    }
}
#endif

