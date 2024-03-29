import Foundation

public struct Instant: Sendable, Hashable, Comparable {
    public static var now: Self { .init(unixTimestamp: Date().timeIntervalSince1970) }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.unixTimestamp < rhs.unixTimestamp
    }
    
    public static func + (lhs: Self, rhs: Duration) -> Self {
        .init(unixTimestamp: lhs.unixTimestamp + rhs.seconds)
    }
    
    public static func += (lhs: inout Self, rhs: Duration) {
        lhs.unixTimestamp += rhs.seconds
    }
    
    public static func - (lhs: Self, rhs: Duration) -> Self {
        .init(unixTimestamp: lhs.unixTimestamp - rhs.seconds)
    }
    
    public static func -= (lhs: inout Self, rhs: Duration) {
        lhs.unixTimestamp -= rhs.seconds
    }
    
    public static func - (lhs: Self, rhs: Self) -> Duration {
        .init(seconds: lhs.unixTimestamp - rhs.unixTimestamp)
    }
    
    fileprivate var unixTimestamp: Double
}
