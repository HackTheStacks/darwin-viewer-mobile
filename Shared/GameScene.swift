
//
//  GameScene.swift
//  drag
//
//  Created by Robert Carlsen on 11/19/16.
//  Copyright © 2016 Robert Carlsen. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    // MARK: configure to use bundled test images or those provided by the API
    let UseLocalImages: Bool = true

    fileprivate var imageNodes: SKNode?
    fileprivate var startButton: SKLabelNode?
    fileprivate var instructionsNode: SKNode?
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


    lazy var demoFragmentModels:[FragmentModel] = {
        let matchNames = ["MS-DAR-00002-000-197", "MS-DAR-00002-000-205"]
        let fragmentModel = FragmentModel(id: "MS-DAR-00002-000-199", url: "")
        fragmentModel.matches = matchNames.map { name -> MatchModel in
            return MatchModel(id: name, edge: "")
        }
        let matchNames1 = ["MS-DAR-00070-000-352", "MS-DAR-00070-000-355"]
        let fragmentModel1 = FragmentModel(id: "MS-DAR-00070-000-366", url: "")
        fragmentModel1.matches = matchNames1.map { name -> MatchModel in
            return MatchModel(id: name, edge: "")
        }
        return [fragmentModel, fragmentModel1]
    }()

    var fragmentIndex = 0
    var fragments: [FragmentModel]?
    var currentFragment: FragmentModel?
    var matchesSet = Set<MatchModel>()

    
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
        self.imageNodes = SKNode()
        self.addChild(imageNodes!)

        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        self.instructionsNode = self.childNode(withName: "//instructionsNode")
        if let instructions = self.instructionsNode {
            instructions.alpha = 0.0
            let delay = SKAction.wait(forDuration: 1.0)
            instructions.run(SKAction.sequence([delay,
                                             SKAction.fadeIn(withDuration: 1.0)]))
        }
        self.startButton = self.childNode(withName: "//startButton") as? SKLabelNode
        if let startButton = self.startButton {
            startButton.alpha = 0.0
            let delay = SKAction.wait(forDuration: 2.0)
            let fadeIn = SKAction.fadeIn(withDuration: 1.0)
            let dim = SKAction.fadeAlpha(to: 0.5, duration: 1.0)
            let pulseAction = SKAction.sequence([fadeIn, dim])
            startButton.run(SKAction.sequence([
                delay,
                pulseAction,
                SKAction.repeatForever(pulseAction),
                ]))
        }
    }

    override func didMove(to view: SKView) {
        self.setUpScene()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view?.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        self.view?.addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        pinchGesture.delegate = self
        self.view?.addGestureRecognizer(pinchGesture)

        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate))
        rotateGesture.delegate = self
        self.view?.addGestureRecognizer(rotateGesture)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view?.addGestureRecognizer(doubleTapGesture)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

// MARK: Data loading
extension GameScene {

    func submitMatch() -> Bool {
        guard let _ = self.currentFragment, self.matchesSet.count > 0 else {
            return false
        }
        // submit fragment / match id upvote
        return true
    }

    func showNextFragment() {
        guard let fragments = self.fragments, fragments.count > 0 else {
            print("no fragments to show")
            return
        }

        if (self.currentFragment != nil) {
            fragmentIndex += 1
            if fragmentIndex >= fragments.count {
                fragmentIndex = 0
            }
            
            // hide current fragments
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let loadNext = SKAction.run { [weak self] in
                if let weakself = self {
                    weakself.imageNodes?.removeAllChildren()
                    let nextFragment = fragments[weakself.fragmentIndex]
                    weakself.currentFragment = nextFragment
                    weakself.loadFragment(fragment: nextFragment)
                }
            }
            self.imageNodes?.run(SKAction.sequence([fadeOut, loadNext, fadeIn]))
            if let camera = self.camera {
                let move = SKAction.move(to: CGPoint.zero, duration: 0.5)
                let scale = SKAction.scale(to: 1.0, duration: 0.5)
                camera.run(SKAction.group([move, scale]))
            }
        } else {
            let nextFragment = fragments[self.fragmentIndex]
            self.currentFragment = nextFragment
            self.loadFragment(fragment: nextFragment)
        }

    }

    func loadFragment(fragment:FragmentModel) {
        // get the fragment image, display it
        // get the match images, display them
        if UseLocalImages {
            var lastPosition = CGPoint.zero

            if let fragmentImage = UIImage(named: fragment.identifier) {
                let imageNode = SKSpriteNode(texture: SKTexture(image: fragmentImage))
                imageNode.name = String(fragment.hashValue)
                imageNode.setScale(0.3)
                imageNode.blendMode = .screen
                imageNode.zPosition = -1
                imageNode.position = imageNode.position.applying(CGAffineTransform.init(translationX: 0, y: 100))
                lastPosition = CGPoint(x: lastPosition.x, y: lastPosition.y - imageNode.size.height/2.0)

                self.imageNodes?.addChild(imageNode)
            }

            if let matches = fragment.matches {
                for matchModel in matches {
                    if let matchImage = UIImage(named: matchModel.identifier) {
                        let imageNode = SKSpriteNode(texture: SKTexture(image: matchImage))
                        imageNode.name = String(matchModel.hashValue)
                        imageNode.setScale(0.3)
                        imageNode.alpha = 0.5
                        imageNode.blendMode = .screen
                        imageNode.zPosition = -1
                        imageNode.position = lastPosition
                        lastPosition = CGPoint(x: lastPosition.x, y: lastPosition.y - imageNode.size.height/2.0)

                        self.imageNodes?.addChild(imageNode)
                    }
                }
            }
        } else {
            // load from API
        }

    }

    func loadImages() {
        if UseLocalImages {
            self.fragments = demoFragmentModels
            showNextFragment()
        } else {
            DarwinApiManager.fragments { [weak self] (fragments, success) in
                guard success else {
                    print("uh oh, fragments failed")
                    return
                }
                print("fragments: \(fragments)")

                let fragmentsWithMatches = fragments?.filter( { fragment -> Bool in
                    guard let matches = fragment.matches else { return false }
                    return matches.count > 0
                })

                if let weakSelf = self {
                    weakSelf.fragments = fragmentsWithMatches
                }

                if let firstFragment = fragmentsWithMatches?.first {
                    if let weakSelf = self {
                        weakSelf.currentFragment = firstFragment
                    }

                    var lastPosition = CGPoint.zero
                    var lastSize = CGSize.zero

                    DarwinApiManager.fragmentImage(identifier: firstFragment.identifier, callback: { (fragmentImage, success) in
                        guard success, let image = fragmentImage else { return }

                        if let weakSelf = self {
                            let imageNode = SKSpriteNode(texture: SKTexture(image: image))
                            imageNode.name = firstFragment.identifier
                            imageNode.setScale(0.3)
                            imageNode.blendMode = .screen
                            imageNode.zPosition = -1
                            weakSelf.imageNodes?.addChild(imageNode)

                            lastPosition = imageNode.position
                            lastSize = imageNode.size
                        }

                        if let matches = firstFragment.matches {
                            for match in matches {
                                DarwinApiManager.fragmentImage(identifier: match.targetId!, callback: { (matchImage, success) in
                                    guard success, let image = matchImage else { return }

                                    if let weakSelf = self {
                                        let imageNode = SKSpriteNode(texture: SKTexture(image: image))
                                        imageNode.name = String(match.hashValue)
                                        imageNode.setScale(0.3)
                                        imageNode.blendMode = .screen
                                        imageNode.alpha = 0.5
                                        imageNode.zPosition = -1

                                        imageNode.position = CGPoint(x: lastPosition.x, y: lastPosition.y - lastSize.height)
                                        lastPosition = imageNode.position
                                        lastSize = imageNode.size

                                        weakSelf.imageNodes?.addChild(imageNode)
                                    }
                                })
                            }
                        }
                    })

                }
            }
        }
    }
}

#if os(iOS)
// Gesture event handling
extension GameScene {

    func handleTap(gesture:UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        let nodeLocation = self.convertPoint(fromView: location)
        let node = self.atPoint(nodeLocation)

        if let button = self.startButton, button == node {
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            self.instructionsNode?.run(fadeOut)
            self.startButton?.removeAllActions()
            self.startButton?.run(fadeOut)
            self.loadImages()
        }
    }

    func handleDoubleTap(gesture:UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        let nodeLocation = self.convertPoint(fromView: location)
        let node = self.atPoint(nodeLocation)

        if let sprite = node as? SKSpriteNode, let parent = node.parent, parent == self.imageNodes {
            if let matchHash = sprite.name, let match = currentFragment?.matchWithHashValue(hashString: matchHash) {
                if self.matchesSet.contains(match) {
                    // deactivate node
                    sprite.run(SKAction.fadeAlpha(to: 0.5, duration: 0.3))
                    self.matchesSet.remove(match)
                } else {
                    // activate node
                    sprite.run(SKAction.fadeIn(withDuration: 0.3))
                    self.matchesSet.insert(match)
                }
            }
        }
    }

    func handlePan(gesture:UIPanGestureRecognizer) {
        let numberOfTouches = gesture.numberOfTouches

        switch gesture.state {
        case .began:
            let translation = gesture.translation(in: self.view)
            if numberOfTouches == 1 {
                self.selectedPanType = .Sprite

                let location = gesture.location(in: gesture.view)
                let nodeLocation = self.convertPoint(fromView: location)
                let node = self.atPoint(nodeLocation)
                if node == self.imageNodes { self.selectedNode = nil; return }

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
            if node == self.imageNodes { self.selectedNode = nil; return }

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

