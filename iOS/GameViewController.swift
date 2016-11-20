//
//  GameViewController.swift
//  drag
//
//  Created by Robert Carlsen on 11/19/16.
//  Copyright © 2016 Robert Carlsen. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = self.view as! SKView
        createScene(inView: skView)

        let restartButton = UIButton(type: .system)
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        restartButton.setTitle("Restart", for: .normal)
        restartButton.addTarget(self, action: #selector(handleRestartTapped), for: .touchUpInside)
        self.view.addSubview(restartButton)
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[button]",
                                                          options: NSLayoutFormatOptions(rawValue: 0),
                                                          metrics: nil,
                                                          views: ["button":restartButton])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[button]-|",
                                                          options: NSLayoutFormatOptions(rawValue: 0),
                                                          metrics: nil,
                                                          views: ["button":restartButton])
        self.view.addConstraints(hConstraints)
        self.view.addConstraints(vConstraints)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .landscape
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func createScene(inView skView:SKView) {
        let scene = GameScene.newGameScene()

        // Present the scene
        skView.presentScene(scene)

        skView.ignoresSiblingOrder = true
//        skView.showsFPS = true
//        skView.showsNodeCount = true
    }

    func handleRestartTapped(sender:UIButton) {
        let skView = self.view as! SKView
        createScene(inView: skView)
    }
}
