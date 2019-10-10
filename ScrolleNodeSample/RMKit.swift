//
//  RMKit.swift
//  ScrolleNodeSample
//
//  Created by yuki on 2019/10/09.
//  Copyright © 2019 yuki. All rights reserved.
//

import CoreGraphics


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
