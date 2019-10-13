//
//  ViewController.swift
//  ScrolleNodeSample
//
//  Created by yuki on 2019/10/07.
//  Copyright © 2019 yuki. All rights reserved.
//

import SpriteKit
import UIKit

class ViewController: UIViewController {

    var skView: SKView { return self.view as! SKView }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = SampleScene()
        scene.scaleMode = .aspectFit
        skView.presentScene(scene)
        
    }
}


// ======================================================================== //
// MARK: - RMKit exp

class SampleScene: SKScene {
    let label = SKLabelNode()
    let tableNode = GKTableNode(color: .clear, size: [200, 400])
    
    override func sceneDidLoad() {
        self.size = [300, 700]
        
        label.position = [150, 100]
        
        tableNode.register(Cell.self, for: "cell")
        tableNode.datasource = self
        tableNode.delegate = self
        tableNode.position = [150, 350]
        
        self.addChild(label)
        self.addChild(tableNode)
    }
}

class Cell: GKTableNodeCell {
    let label = SKLabelNode()
    
    init() {
        super.init(texture: nil, color: .red, size: .zero)
        
        self.addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
extension SampleScene: GKTableNodeDelegate {
    func tableNode(_ tableNode: GKTableNode, cellDidSelectedAt index: Int) {
        label.text = "Cell selected at \(index)"
    }
}
extension SampleScene: GKTableNodeDataSource {
    func numberOfRows(_ tableNode: GKTableNode) -> Int {
        50
    }
    
    func tableNode(_ tableNode: GKTableNode, cellForRowAt index: Int) -> GKTableNodeCell {
        guard let cell = tableNode.dequeueReusableCell(for: "cell", at: index) as? Cell else { fatalError() }
        cell.label.text = "\(index)"
        cell.label.fontColor = .black
        if index % 2 == 0 {
            cell.color = .red
        } else {
            cell.color = .green
        }
        return cell
    }
    
    func cellHeight(_ tableNode: GKTableNode) -> CGFloat {
        100
    }
    
}
