//
//  GKTextNode.swift
//  ScrolleNodeSample
//
//  Created by yuki on 2019/10/10.
//  Copyright © 2019 yuki. All rights reserved.
//

import SpriteKit

/// This node can display multi-line text.
/// If the content overs node size. Node automatically enable scrolling.
public class GKTextNode: GKScrollNode {
    // ============================================================ //
    // MARK: - Properties -
    
     
    /// The insets of scroll node.
    /// default is (10, 10, 10, 10).
    public var contentInsets: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) {
        didSet {
            _updateSize()
            _updateText()
        }
    }

    /// The text of this textNode.
    public var text: String? = "" {
        didSet { _updateText() }
    }
    
    /// The size of this node.
    public override var size: CGSize {
        get { return super.size }
        set {
            super.size = newValue
            _updateSize()
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
        
    /// The label node of this node.
    private let _label = SKLabelNode()
    
    // ============================================================ //
    // MARK: - Methods -
    
    /// This methods update text. with scroll size.
    private func _updateText() {
        let text = self.text
        
        self._label.text = text
        
        let contentHeight = _label.frame.height
                
        self.contentSize.height = contentHeight + contentInsets.top + contentInsets.bottom
        self._label.position.y = -contentHeight + self.size.height / 2 - contentInsets.top
    }
    
    /// This methods update size of this node.
    private func _updateSize() {
        let width = size.width - contentInsets.left - contentInsets.right
        self._label.preferredMaxLayoutWidth = width
    }
    
    // ============================================================ //
    // MARK: - Constructor -
    
    /// This methods set up node.
    private func _setup() {
        
        // label
        _label.isUserInteractionEnabled = false
        _label.numberOfLines = -1
        _label.lineBreakMode = .byTruncatingTail
        _label.fontColor = .black
        
        self.addChild(_label)
        
        // initirize
        self._updateSize()
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
