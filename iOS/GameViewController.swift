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
        self.view.tintColor = UIColor.lightGray

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

        let submitButton = UIButton(type: .system)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Submit Match", for: .normal)
        submitButton.addTarget(self, action: #selector(handleSubmitTapped), for: .touchUpInside)
        self.view.addSubview(submitButton)
        let hSubmitConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[button]-|",
                                                                options: NSLayoutFormatOptions(rawValue: 0),
                                                                metrics: nil,
                                                                views: ["button":submitButton])
        let vSubmitConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[button]-|",
                                                                options: NSLayoutFormatOptions(rawValue: 0),
                                                                metrics: nil,
                                                                views: ["button":submitButton])
        self.view.addConstraints(hSubmitConstraints)
        self.view.addConstraints(vSubmitConstraints)

        let nextButton = UIButton(type: .system)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("None Match", for: .normal)
        nextButton.addTarget(self, action: #selector(handleNextTapped), for: .touchUpInside)
        self.view.addSubview(nextButton)
        let hNextConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[button]-40-[submit]",
                                                                options: NSLayoutFormatOptions(rawValue: 0),
                                                                metrics: nil,
                                                                views: ["button":nextButton, "submit":submitButton])
        let vNextConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[button]-|",
                                                                options: NSLayoutFormatOptions(rawValue: 0),
                                                                metrics: nil,
                                                                views: ["button":nextButton])
        self.view.addConstraints(hNextConstraints)
        self.view.addConstraints(vNextConstraints)
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

    func handleSubmitTapped(sender:UIButton) {
        let scene = (self.view as! SKView).scene as! GameScene
        if scene.submitMatch() {
            // alert good
            let alert = UIAlertController(title: "Submitted", message: "This match was submitted. Thank you!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Next match", style: .default, handler: { [weak scene] (action) in
                DispatchQueue.main.async {
                    if let weakScene = scene {
                        weakScene.showNextFragment()
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)

        } else  {
            // alert bad
            let alert = UIAlertController(title: "Submit", message: "Double-tap an image to select at least two fragments to match and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func handleNextTapped(sender:UIButton) {
        let scene = (self.view as! SKView).scene as! GameScene
        scene.showNextFragment()
    }
}
