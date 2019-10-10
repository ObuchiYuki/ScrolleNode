//
//  GKTextNode.swift
//  ScrolleNodeSample
//
//  Created by yuki on 2019/10/10.
//  Copyright © 2019 yuki. All rights reserved.
//

import SpriteKit


public class GKTextNode: SKSpriteNode {
    // ============================================================ //
    // MARK: - Properties -
    
     
    // MARK: - Nodes -

    /// The text of this textNode.
    public var text: String? = "" {
        didSet { _updateText() }
    }
    
    /// The size of this node.
    public override var size: CGSize {
        get { return super.size }
        set {
            super.size = newValue
            _updateSize(to: newValue)
            _updateText()
        }
    }
    
    public var fontName: String? {
        set {
            _label.fontName = newValue
            _updateText()
        }
        get { _label.fontName }
    }
    
    public var fontSize: CGFloat {
        set {
            _label.fontSize = newValue
            _updateText()
        }
        get { _label.fontSize }
    }
    
    public var fontColor: SKColor? {
        get { _label.fontColor }
        set { _label.fontColor = newValue }
    }
    
    // =============================== //
    // MARK: - Privates -
    
    /// The scroll node of this node.
    private let _scrolleNode = GKScrollNode()
    
    /// The label node of this node.
    private let _label = SKLabelNode()
    
    // ============================================================ //
    // MARK: - Methods -
    
    /// This methods update text. with scroll size.
    private func _updateText() {
        let text = self.text
        
        self._label.text = text
        
        let contentHeight = _label.frame.height
        
        self._scrolleNode.contentSize.height = contentHeight
        self._label.position.y = -contentHeight + self.size.height / 2
        
    }
    
    /// This methods update size of this node.
    private func _updateSize(to size: CGSize) {
        self._label.preferredMaxLayoutWidth = size.width
        self._scrolleNode.size = size
    }
    
    private func _calcContentHeight(for string:String, fontSize: CGFloat, fontNamed fontName:String, width: CGFloat) -> CGFloat {
        let maxSize = CGSize(width: width, height: 10000)
        let font = UIFont(name: fontName, size: fontSize)
        let size = (string as NSString).boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font as Any], context: nil).size
        
        return size.height
    }
    
    // ============================================================ //
    // MARK: - Constructor -
    
    /// This methods set up node.
    private func _setup() {
        // = for debug =
        _scrolleNode.color = .green
        
        // label
        _label.numberOfLines = -1
        _label.lineBreakMode = .byTruncatingTail
        _label.fontColor = .black
        _scrolleNode.addChild(_label)
        // scroll node
        self.addChild(_scrolleNode)
        
        // initirize
        self._updateSize(to: self.size)
    }
    
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self._setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._setup()
    }
}
