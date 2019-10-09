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
        skView.presentScene(scene)
        
        print("Hello")
    }
}

extension Comparable {
    func into(_ range: ClosedRange<Self>) -> Self {
        return max(range.lowerBound, min(self, range.upperBound))
    }
}

extension CGPoint {
    func into(_ min: CGPoint,_ max:CGPoint) -> CGPoint {
        return CGPoint(x: self.x.into(min.x...max.x), y: self.y.into(min.y...max.y))
    }
}

extension CGSize: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: CGFloat...) {
        self.init(width: elements[0], height: elements[1])
    }
    public static func + (right: CGSize, left: CGSize) -> CGSize {
        return CGSize(width: right.width + left.width, height: right.height + left.height)
    }
    
    public static func - (right: CGSize, left: CGSize) -> CGSize {
        return CGSize(width: right.width - left.width, height: right.height - left.height)
    }
    
    var point:CGPoint {
        return CGPoint(x: self.width, y: self.height)
    }
}

extension CGPoint: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: CGFloat...) {
        self.init(x: elements[0], y: elements[1])
    }
    public static func + (right: CGPoint, left: CGPoint) -> CGPoint {
        return CGPoint(x: right.x + left.x, y: right.y + left.y)
    }
    public static func - (right: CGPoint, left: CGPoint) -> CGPoint {
        return CGPoint(x: right.x - left.x, y: right.y - left.y)
    }
    public static func * <T: BinaryInteger>(right: CGPoint, left:T) -> CGPoint {
        return CGPoint(x: right.x * CGFloat(left), y: right.y * CGFloat(left))
    }
    public static prefix func - (right: CGPoint) -> CGPoint {
        return CGPoint(x: -right.x, y: -right.y)
    }
    
    var size: CGSize {
        return CGSize(width: self.x, height: self.y)
    }
}

// ======================================================================== //
// MARK: - RMKit exp

class SampleScene: SKScene {
    let node1 = SKSpriteNode(color: .red, size: [10, 10])
    let node2 = SKSpriteNode(color: .blue, size: [10, 10])
    
    let scroleNode = GKScrollNode(color: .green, size: [200, 400])
    
    override func sceneDidLoad() {
        self.size = [300, 700]
        
        node1.position = [20, 40]
        scroleNode.addChild(node1)
        node2.position = [40, 70]
        scroleNode.position = [150, 350]
        scroleNode.addChild(node2)
        scroleNode.contentSize = [200, 700]
        
        self.addChild(scroleNode)
    }
}

public class GKScrollNode: SKSpriteNode {
    // ======================================================== //
    // MARK: - Properties -
    
    // MARK: - Variables -
    
    public override var size: CGSize {
        get { return super.size }
        set {
            super.size = newValue
            _maskNode.size = newValue
            _scrollNode.size = newValue
        }
    }
    
    
    public var contentSize:CGSize {
        set { _scrollNode.contentSize = newValue }
        get { return _scrollNode.contentSize }
    }
    
    
    private let _maskNode = SKSpriteNode()
    private let _scrollNode = _GKScrollNode()
    private let _cropNode = SKCropNode()
    
    private func _setup() {
        
        self.isUserInteractionEnabled = true
        self._cropNode.isUserInteractionEnabled = false
        self._maskNode.isUserInteractionEnabled = false
        
        super.size = size
        _maskNode.size = size
        _scrollNode.size = size
        
        _cropNode.maskNode = _maskNode
        _cropNode.addChild(_scrollNode)
        
        self.addChild(_cropNode)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _scrollNode.touchesBegan(touches, with: event)
    }
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        _scrollNode.touchesMoved(touches, with: event)
    }
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        _scrollNode.touchesEnded(touches, with: event)
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
// MARK: - _GKScrollNode - 
/// This node is enable you to make scrolling content in SpriteKit.
private class _GKScrollNode: SKSpriteNode {
    
    // ======================================================== //
    // MARK: - Properties -
    
    // MARK: - Variables -
    
    public override var size: CGSize {
        get { return super.size }
        set {
            super.size = newValue
            self._checkOffset()
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
    private let _verticalIndicator = _GKScrollNodeScrolleIndicator()

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
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isScrollEnabled else { return }
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        _dragDidStart(from: location)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isScrollEnabled else { return }
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        _dragDidMove(to: location)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    
    // ======================================================== //
    // MARK: - Constructor -
    private func _setup() {
        self.isUserInteractionEnabled = true
        super.addChild(_contentNode)
        super.addChild(_verticalIndicator)
        
        _verticalIndicator.setDelegate(self)
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
extension _GKScrollNode: _GKScrollNodeScrolleIndicatorDataSource {
}
 
private protocol _GKScrollNodeScrolleIndicatorDataSource: class {
    var size: CGSize { get }
    var contentSize: CGSize { get }
    var contentOffset: CGPoint { get }
}

private class _GKScrollNodeScrolleIndicator: SKSpriteNode {
    private let _indicatorNode = SKSpriteNode(color: .brown, size: .zero)
    
    private weak var delegate: _GKScrollNodeScrolleIndicatorDataSource!
    
    func setDelegate(_ _delegate: _GKScrollNodeScrolleIndicatorDataSource) {
        self.delegate = _delegate
        self._setup()
    }
    
    func update() {
        guard let delegate = self.delegate else { return }
        
        let _hrate = delegate.size.height / delegate.contentSize.height
        let indicatorH = delegate.size.height * _hrate
        let indicatorF = delegate.size.height * ( self.delegate.contentOffset.y / delegate.contentSize.height )
        
        _indicatorNode.size = [5, indicatorH]
        _indicatorNode.position = [0, (self.size.height / 2) - indicatorF]
    }
    
    private func _setup() {
        self.size =     [5, delegate.size.height]
        self.position = [delegate.size.width / 2, 0]
    }
    
    init() {
        super.init(texture: nil, color: .yellow, size: .zero)
        
        self._indicatorNode.anchorPoint = [0.5, 1]
        self.addChild(_indicatorNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
