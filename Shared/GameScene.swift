
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
    var selectedNodeRotation: CGFloat = 0.0
    var selectedNodePosition = CGPoint.zero

    enum PanMoveType {
        case Sprite
        case Camera
    }
    var selectedPanType = PanMoveType.Camera

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

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        self.view?.addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        pinchGesture.delegate = self
        self.view?.addGestureRecognizer(pinchGesture)

        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate))
        rotateGesture.delegate = self
        self.view?.addGestureRecognizer(rotateGesture)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

#if os(iOS)
// Gesture event handling
extension GameScene {

    func handlePan(gesture:UIPanGestureRecognizer) {
        let numberOfTouches = gesture.numberOfTouches
        // if touches > 1, pan the camera

        switch gesture.state {
        case .began:
            let translation = gesture.translation(in: self.view!)
            if numberOfTouches == 1 {
                self.selectedPanType = .Sprite

                let location = gesture.location(in: gesture.view)
                let nodeLocation = self.convertPoint(fromView: location)
                let node = self.atPoint(nodeLocation)
                self.selectedNode = node

                if let node = self.selectedNode {
                    self.selectedNodePosition = node.position
                    // must invert y
                    node.position = CGPoint(x: selectedNodePosition.x + translation.x, y:selectedNodePosition.y - translation.y)
                }
            } else {
                self.selectedPanType = .Camera

                if let camera = self.camera {
                    self.selectedNodePosition = camera.position
                    // must invert x
                    camera.position = CGPoint(x:selectedNodePosition.x - translation.x, y: selectedNodePosition.y + translation.y)
                }
            }
        case .changed:
            var translation = gesture.translation(in: self.view!)
            if let camera = self.camera {
                translation = translation.applying(CGAffineTransform.init(scaleX: camera.xScale, y: camera.yScale))
            }

            if self.selectedPanType == .Sprite {
                if let node = self.selectedNode {
                    // must invert y
                    node.position = CGPoint(x: selectedNodePosition.x + translation.x, y:selectedNodePosition.y - translation.y)
                }
            } else {
                if let camera = self.camera {
                    // must invert x
                    camera.position = CGPoint(x:selectedNodePosition.x - translation.x, y: selectedNodePosition.y + translation.y)
                }
            }
        case .ended:
            break
        default:
            break
        }
    }
    func handlePinch(gesture:UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            if let camera = self.camera {
                self.selectedNodeScale = camera.xScale
            }

        case .changed:
            if let camera = self.camera {
                camera.setScale(selectedNodeScale / gesture.scale)
            }
        case .ended:
            break
        default:
            break
        }
    }

    func handleRotate(gesture:UIRotationGestureRecognizer) {
        switch gesture.state {
        case .began:
            let location = gesture.location(in: gesture.view)
            let nodeLocation = self.convertPoint(fromView: location)
            let node = self.atPoint(nodeLocation)
            self.selectedNode = node
            self.selectedNodeRotation = node.zRotation
            break
        case .changed:
            if let node = self.selectedNode {
                node.zRotation = selectedNodeRotation - gesture.rotation
            }
            break
        case .ended:
            break
        default:
            break
        }
    }
}

// MARK: UIGestureRecognizerDelegate
extension GameScene: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIRotationGestureRecognizer.self) ||
            gestureRecognizer.isKind(of: UIRotationGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPinchGestureRecognizer.self)
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

