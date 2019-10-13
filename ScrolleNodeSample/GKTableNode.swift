//
//  GKTableNode.swift
//  ScrolleNodeSample
//
//  Created by yuki on 2019/10/11.
//  Copyright © 2019 yuki. All rights reserved.
//

import SpriteKit

// ============================================================ //
// MARK: - GKTableNodeDelegate -

public protocol GKTableNodeDelegate: class {
    func tableNode(_ tableNode: GKTableNode, highlightCell cell: GKTableNodeCell)
    func tableNode(_ tableNode: GKTableNode, unhighlightCell cell: GKTableNodeCell)
    func tableNode(_ tableNode: GKTableNode, cellDidSelectedAt index: Int)
}

extension GKTableNodeDelegate {
    func tableNode(_ tableNode: GKTableNode, highlightCell cell: GKTableNodeCell) {
        cell.alpha = 0.6
    }
    func tableNode(_ tableNode: GKTableNode, unhighlightCell cell: GKTableNodeCell) {
        cell.alpha = 1
    }
    
    func tableNode(_ tableNode: GKTableNode, cellDidSelectedAt index: Int) {  }
}

private class GKTableNodeDelegate_: GKTableNodeDelegate {
    static let `default` = GKTableNodeDelegate_()
}

// ============================================================ //
// MARK: - GKTableNodeDataSource -

public protocol GKTableNodeDataSource: class {
    func numberOfRows(_ tableNode: GKTableNode) -> Int
    func tableNode(_ tableNode: GKTableNode, cellForRowAt index: Int) -> GKTableNodeCell
    func cellHeight(_ tableNode: GKTableNode) -> CGFloat
}

// ============================================================ //
// MARK: - GKTableNode -
public class GKTableNode: SKSpriteNode {
    
    // ============================================================ //
    // MARK: - Properties -
    
    /// The delegate of GKTableNode.
    public weak var delegate: GKTableNodeDelegate! = GKTableNodeDelegate_.default
    
    /// The datasource of GKTableNode.
    public weak var datasource: GKTableNodeDataSource! = nil {
        didSet { reloadData() }
    }
    
    /// The size of node.
    public override var size: CGSize {
        get { super.size }
        set {
            super.size = newValue
            _updateSize()
        }
    }
    
    // MARK: - Privates -
    
    private let _touchInterval = 0.7
    private let _allowTouchMoving:CGFloat = 10 //px
    private var _touchStartTimeStamp:TimeInterval?
    private var _touchStartLocation:CGPoint?
    private var _touchingCellIndex:Int?
    
    // MARK: - Nodes -
    private var _cellClasses = [String: AnyClass]()
    private let _scrollNode = GKScrollNode()
    private var _renderingCellsQueue = [GKTableNodeCell]()
    private var _unrenderedCellsQueue = [GKTableNodeCell]()
    
    // ============================================================ //
    // MARK: - Methods -
    
    public func reloadData() {
        /// number 適応までの仮
        self._updateCells()
    }
    
    public func cell(at position: CGPoint) -> GKTableNodeCell? {
        guard let index = self._index(of: position) else { return nil }
        
        return cell(for: index)
    }
    
    public func cell(for index: Int) -> GKTableNodeCell? {
        return _renderingCellsQueue.first(where: { $0._index == index })
    }
    
    public func register(_ cellClass: AnyClass, for identifier: String) {
        _cellClasses[identifier] = cellClass
    }
    
    public func dequeueReusableCell(for iditifier: String, at index: Int) -> GKTableNodeCell? {
        
        // unrendered
        if let cell = _unrenderedCellsQueue.first(where: { $0._identifier == iditifier }) {
            _unrenderedCellsQueue.remove(of: cell)
            cell._index = index
            return cell
        }
        
        // create
        if let cell = _createNewCell(for: iditifier, at: index) {
            return cell
        }
        
        return nil
    }
    
    public override func touchBegan(from location: CGPoint) {
        _touchStartTimeStamp = Date().timeIntervalSince1970
        _touchStartLocation = location
        
        guard let cell = self.cell(at: location) else { return }
        
        _touchingCellIndex = cell._index
        
        cell.isSelected = true
        delegate.tableNode(self, highlightCell: cell)
    }
    
    public override func touchEnded(at location: CGPoint) {
        guard
            let touchStartLocation = _touchStartLocation,
            let touchingCellIndex = _touchingCellIndex
        else { return }
        
        guard let cell = cell(for: touchingCellIndex) else { return }
        
        _unselectCell(cell)
        
        // delta
        let delta = touchStartLocation - location
            
        if abs(delta.x) < _allowTouchMoving && abs(delta.y) < _allowTouchMoving {
            _touchCell(cell)
                
        }
    }
    
    // MARK: - Privates -
    private func _index(of location: CGPoint) -> Int? {
        guard let datasource = self.datasource else { return nil }
        
        let uh = (location.y - self.size.height / 2) - _scrollNode.contentOffset.y
        let _index = uh / datasource.cellHeight(self)
        
        let index = Int(-_index)
        
        return index
    }
    
    private func _unselectCell(_ cell: GKTableNodeCell) {
        if cell.isSelected {
            cell.isSelected = false
            delegate.tableNode(self, unhighlightCell: cell)
        }
    }
    private func _touchCell(_ cell: GKTableNodeCell) {
        delegate.tableNode(self, cellDidSelectedAt: cell._index)
    }
    
    private func _createNewCell(for identifier: String, at index: Int) -> GKTableNodeCell? {
        guard let aClass: AnyClass = _cellClasses[identifier] else { return nil }
        guard let cellClass = aClass as? NSObject.Type else { return nil }
        guard let cell = cellClass.init() as? GKTableNodeCell else { return nil }

        cell._index = index
        cell._identifier = identifier
        
        cell.size = CGSize(width: self.size.width, height: self.datasource?.cellHeight(self) ?? 0)
        
        self._scrollNode.addChild(cell)
        
        return cell
    }
    
    /// update to fit current size.
    private func _updateSize() {
        self._scrollNode.size = self.size
    }
    
    private func _updateCells() {
        guard let datasource = self.datasource else { return }
        
        let offset = self._scrollNode.contentOffset
        let renderIndexes = _calcRenderIndexes(from: offset)
        
        
        // unrender
        for _renderingCell in _renderingCellsQueue {
            if renderIndexes.allSatisfy({ $0 != _renderingCell._index }) {
                self._unrenderCell(_renderingCell)
            }
        }
        
        // render
        for renderIndex in renderIndexes {
            if _renderingCellsQueue.allSatisfy({ $0._index != renderIndex }) {
                let cell = datasource.tableNode(self, cellForRowAt: renderIndex)
                cell._index = renderIndex
                _renderingCellsQueue.append(cell)
                _updateCell(cell)
            }
        }
        
        self._scrollNode.contentSize.height = CGFloat(datasource.numberOfRows(self)) * datasource.cellHeight(self)
    }
    
    private func _updateCell(_ cell: GKTableNodeCell) {
        cell.position = _calcPositions(of: cell)
    }
    
    private func _unrenderCell(_ cell: GKTableNodeCell) {
        guard let _index = _renderingCellsQueue.firstIndex(of: cell) else { return }
        
        delegate.tableNode(self, unhighlightCell: cell)
        
        _renderingCellsQueue.remove(at: _index)
        _unrenderedCellsQueue.append(cell)
    }
    
    private func _calcPositions(of cell: GKTableNodeCell) -> CGPoint {
        let cellHeight = datasource!.cellHeight(self)
        
        let ut = (CGPoint(x: 0, y: CGFloat(cell._index) * cellHeight - (self.size.height / 2) + (cellHeight / 2)))
        return -ut
    }
    private func _calcRenderIndexes(from offset: CGPoint) -> [Int] {
        guard let datasource = self.datasource else { return [] }
        
        let cellHeight = datasource.cellHeight(self)
        let cellCount = datasource.numberOfRows(self)
        
        let topIndex = Int(offset.y / cellHeight)
        let endIndex = min(cellCount - 1, Int((offset.y + self.size.height) / cellHeight + 1))
        
        return (topIndex...endIndex).filter{ $0 <= endIndex }
    }
    // ============================================================ //
    // MARK: - Constructor -
    private func _setup() {
        self.addChild(_scrollNode)
        
        _scrollNode.delegate = self
        
        _updateSize()
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

extension GKTableNode: GKScrollNodeDelegate {
    public func scrollNode(scrollViewDidMoveTo offset: CGPoint) {
        _updateCells()
    }
}

// is anchor [0, 0]
open class GKTableNodeCell: SKSpriteNode {
    public var isSelected:Bool = false
    
    fileprivate var _index: Int!
    fileprivate var _identifier:String!
    
    open func setupCell() {}
    
    private func _setup() {
        self.isUserInteractionEnabled = false
        self.setupCell()
    }
    
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        _setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _setup()
    }
    
}
