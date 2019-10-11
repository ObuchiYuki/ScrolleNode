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
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        
    }
}


// ======================================================================== //
// MARK: - RMKit exp

class SampleScene: SKScene {
    let textNode = GKTextNode(color: .green, size: [200, 400])
    
    override func sceneDidLoad() {
        self.size = [300, 700]
        
        textNode.fontSize = 15
        textNode.fontColor = .red
        textNode.text = "電子たばこの登場以来、若年喫煙者数の増加はうなぎ登り。一方で、重篤な健康被害の報告もあり、アメリカではサンフランシスコ市が電子たばこの販売・流通を禁止するなど規制が強化され、小売業者による取り扱いの停止も始まっています。そんな中でさらに追い打ちをかけるように、中国最大規模の通販サイト・アリババが、電子たばこ関連部品のアメリカ向け販売を中止したことが明らかになりました。電子たばこの登場以来、若年喫煙者数の増加はうなぎ登り。一方で、重篤な健康被害の報告もあり、アメリカではサンフランシスコ市が電子たばこの販売・流通を禁止するなど規制が強化され、小売業者による取り扱いの停止も始まっています。そんな中でさらに追い打ちをかけるように、中国最大規模の通販サイト・アリババが、電子たばこ関連部品のアメリカ向け販売を中止したことが明らかになりました。電子たばこの登場以来、若年喫煙者数の増加はうなぎ登り。一方で、重篤な健康被害の報告もあり、アメリカではサンフランシスコ市が電子たばこの販売・流通を禁止するなど規制が強化され、小売業者による取り扱いの停止も始まっています。そんな中でさらに追い打ちをかけるように、中国最大規模の通販サイト・アリババが、電子たばこ関連部品のアメリカ向け販売を中止したことが明らかになりました。"
        
        textNode.position = [150, 350]
        
        self.addChild(textNode)
    }
}
