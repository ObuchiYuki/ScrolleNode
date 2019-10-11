//
//  GKScrollNode.swift
//  ScrolleNodeSample
//
//  Created by yuki on 2019/10/09.
//  Copyright © 2019 yuki. All rights reserved.
//

import SpriteKit

// ======================================================== //
// MARK: - GKScrollNodeDataSource -

public protocol GKScrollNodeDataSource: class {
    /// You can impl to return the node scroll indicator.
    func scrollIndicator() -> SKSpriteNode
    
    /// You can impl to resize node.
    func resizeScrollIndicator(from node: SKSpriteNode, to size: CGSize)
    /// You can impl to return the node scroll indicator's backgroud color.
    func scrollIndicatorBackgroundColor() -> SKColor
    
}

/// The default instance class of GKScrollNodeDataSource.
private class GKScrollNodeDataSourceDefault: GKScrollNodeDataSource {}
/// The default instance.
private let GKScrollNodeDataSource_default = GKScrollNodeDataSourceDefault()

// MARK: - Make Optional -
public extension GKScrollNodeDataSource {
    func scrollIndicator() ->SKSpriteNode { SKSpriteNode(texture: nil, color: UIColor(white: 1, alpha: 1).withAlphaComponent(0.4), size: .zero) }
    func resizeScrollIndicator(from node: SKSpriteNode, to size: CGSize) { node.size = size }
    func scrollIndicatorBackgroundColor() -> SKColor { .orange }
}

// ======================================================== //
// MARK: - GKScrollNodeDelegate -

public protocol GKScrollNodeDelegate: class {
    // all optional
    func scrollNode(_ scrollNode: GKScrollNode, scrollViewDidMoveTo offset: CGPoint)
    func scrollNode(_ scrollNode: GKScrollNode, scrollViewWillMoveTo offset: CGPoint)
    
    func scrollNode(_ scrollNode: GKScrollNode, shouldShowScrollIndicatorAt offset: CGPoint) -> Bool
}

public extension GKScrollNodeDelegate {
    func scrollNode(_ scrollNode: GKScrollNode, scrollViewDidMoveTo offset: CGPoint) {}
    func scrollNode(_ scrollNode: GKScrollNode, scrollViewWillMoveTo offset: CGPoint) {}
    
    func scrollNode(_ scrollNode: GKScrollNode, shouldShowScrollIndicatorAt offset: CGPoint) -> Bool { return true }
}

/// The default instance class of GKScrollNodeDelegate.
private class GKScrollNodeDelegateDefault: GKScrollNodeDelegate {}
/// The default instance.
private let GKScrollNodeDelegate_default = GKScrollNodeDelegateDefault()


public class GKScrollNode: SKSpriteNode {
    
    // ================================================= //
    // MARK: - Properties -
    
    
    /// The delegate of GKScrollNode.
    public var delegate: GKScrollNodeDelegate {
        set { _scrollNode.delegate = newValue }
        get { _scrollNode.delegate }
    }
    
    /// The size of node.
    public override var size: CGSize {
        get { return super.size }
        set {
            super.size = newValue
            self._updateSize(to: newValue)
        }
    }
    
    
    /// The size of content.
    /// If this property smaller than node size the node automatically stop scrolling.
    /// Default is zero
    public var contentSize:CGSize {
        get { return _scrollNode.contentSize }
        set { _scrollNode.contentSize = newValue }
    }
    
    /// The current scroll offset. Default is .zero
    public var contentOffset: CGPoint {
        set { _scrollNode.contentOffset = newValue }
        get { _scrollNode.contentOffset }
    }
    
    
    // MARK: - Privates -
    
    // MARK: - Nodes -
    private let _scrollNode = _GKScrollNode()
    private let _cropNode = SKCropNode()
    private let _maskNode = SKSpriteNode(color: .black, size: .zero)
    
    // ================================================= //
    // MARK: - Methods -
    private func _updateSize(to size: CGSize) {
        self._scrollNode.size = size
        self._maskNode.size = size
        
        
        print(_maskNode.size)
    }
    
    public override func addChild(_ node: SKNode) {
        _scrollNode.addChild(node)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        self._scrollNode.touchesBegan(from: location)
    }
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        self._scrollNode.touchesMoved(to: location)
    }
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        self._scrollNode.touchesEnded(at: location)
    }
    
    // ================================================= //
    // MARK: - Constrctor -
    private func _setup() {
        self.isUserInteractionEnabled = true
        
        _cropNode.addChild(_scrollNode)
        _cropNode.maskNode = _maskNode
        
        super.addChild(_cropNode)
        
        _updateSize(to: self.size)
    }
    
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        _setup()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _setup()
    }
    
}
// ================================================= //
// MARK: - GKScrollNode -

/// The real scrolling class.
private class _GKScrollNode: SKSpriteNode {
    
    // ======================================================== //
    // MARK: - Properties -
    
    // MARK: - Delegates -
    
    /// The delegate of GKScrollNode.
    public weak var delegate: GKScrollNodeDelegate! = GKScrollNodeDelegate_default
    
    /// The datasource of GKScrollNode.
    public weak var datasouce: GKScrollNodeDataSource! = GKScrollNodeDataSource_default
    
    // MARK: - Variables -
    
    /// The size of Scroll Node.
    public override var size: CGSize {
        get { return super.size }
        set {
            super.size = newValue
            self._checkOffset()
            self._updateIndicatorRect()
        }
    }
    
    /// The current scroll offset. Default is .zero
    public var contentOffset: CGPoint = .zero {
        didSet{
            self._checkOffset()
        }
    }
    
    /// The size of content.
    /// If this property smaller than node size the node automatically stop scrolling.
    /// Default is zero
    public var contentSize:CGSize = .zero {
        didSet { _checkOffset() }
    }
    
    // MARK: - Options -
    
    public var isScrollEnabled:Bool = true
    
    private(set) public var isDragging:Bool = false
    
    // ======================================================== //
    // MARK: - Privates -
    
    // MARK: - Nodes -
    private let _contentNode = SKNode()
    private let _verticalIndicator = GKScrollNodeScrolleIndicator()

    // MARK: - Variables -
    // contentOffset can only be (x: -, y: -)
    
    private var _startOffset = CGPoint.zero
    private var _startTouchLocation = CGPoint.zero
    
    // ======================================================== //
    // MARK: - Methods -
    public func setOffset(_ offset:CGPoint) {
        self.contentOffset = offset
        _checkOffset()
    }
    
    public override func addChild(_ node: SKNode) {
        self._contentNode.addChild(node)
    }
    
    public func touchesBegan(from location: CGPoint) {
        guard isScrollEnabled else { return }
        
        _dragDidStart(from: location)
    }
    
    public func touchesMoved(to location: CGPoint) {
        guard isScrollEnabled else { return }

        _dragDidMove(to: location)
    }
    
    public func touchesEnded(at location: CGPoint) {
        self.isDragging = false
    }
    
    // ======================================================== //
    // MARK: - Private -
    private func _checkOffset() {
        self._contentNode.position = _modifyOffset(contentOffset)
        
        _verticalIndicator.update()
    }
    
    private func _dragDidStart(from location: CGPoint) {
        self.isDragging = true
        
        self._startOffset = self.contentOffset
        self._startTouchLocation = location
    }
    
    private func _dragDidMove(to location: CGPoint) {
        guard let delta = _calcDelta(location) else { return }
        self.contentOffset = _modifyOffset(_startOffset + delta)
        
        _checkOffset()
    }
    
    private func _modifyOffset(_ offset: CGPoint) -> CGPoint {
        var _csize = contentSize - self.size
        if _csize.width < 0  { _csize.width  = 0 }
        if _csize.height < 0 { _csize.height = 0 }
        
        return offset.into(.zero, CGPoint(x: _csize.width, y: _csize.height))
    }
    
    private func _calcDelta(_ location: CGPoint) -> CGPoint? {
        return CGPoint(x: location.x - _startTouchLocation.x, y: location.y - _startTouchLocation.y)
    }
    private func _updateIndicatorRect() {
        _verticalIndicator.size =     [5, self.size.height]
        _verticalIndicator.position = [self.size.width / 2, 0]
    }
    
    // ======================================================== //
    // MARK: - Constructor -
    private func _setup() {
        
        super.addChild(_contentNode)
        super.addChild(_verticalIndicator)
        
        _verticalIndicator.setDelegate(self)
        
        self._checkOffset()
        self._updateIndicatorRect()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._setup()
    }
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self._setup()
    }
}

// ratificate
extension GKScrollNode: GKScrollNodeScrolleIndicatorDataSource {
    var indicatorBackgroundColor: SKColor { return datasouce.scrollIndicatorBackgroundColor() }

    var indicatorNode: SKSpriteNode { return datasouce.scrollIndicator() }
    
    func resizeIndicator(_ node: SKSpriteNode, to size: CGSize) { self.datasouce.resizeScrollIndicator(from: node, to: size) }
}
 
private protocol GKScrollNodeScrolleIndicatorDataSource: class {
    var indicatorNode:SKSpriteNode { get }
    var indicatorBackgroundColor: SKColor { get }
    
    func resizeIndicator(_ node: SKSpriteNode, to size: CGSize)
    
    var size: CGSize { get }
    var contentSize: CGSize { get }
    var contentOffset: CGPoint { get }
}

private class GKScrollNodeScrolleIndicator: SKSpriteNode {
    private var _indicatorNode:SKSpriteNode!
    
    private weak var delegate: GKScrollNodeScrolleIndicatorDataSource!
    
    func setDelegate(_ _delegate: GKScrollNodeScrolleIndicatorDataSource) {
        self.delegate = _delegate
        self._setup()
    }
    
    func update() {
        guard let delegate = self.delegate else { return }
        
        let _hrate = delegate.size.height / delegate.contentSize.height
        let indicatorH = delegate.size.height * _hrate
        let indicatorF = delegate.size.height * ( self.delegate.contentOffset.y / delegate.contentSize.height )
        
        if indicatorH > self.size.height { return }
        self.delegate.resizeIndicator(_indicatorNode, to: [5, indicatorH])
        _indicatorNode.position = [0, (self.size.height / 2) - indicatorF]
    }
    
    // called after delegate setted.
    private func _setup() {
        self._indicatorNode = delegate.indicatorNode
        
        self._indicatorNode.anchorPoint = [0.5, 1]
        self.addChild(_indicatorNode)
    }
}
