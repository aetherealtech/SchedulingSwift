public struct Duration: AdditiveArithmetic, Sendable, Hashable, Comparable {
    public static var zero: Self { .init(seconds: 0) }
    public static var eternity: Self { .init(seconds: .infinity) }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.seconds < rhs.seconds
    }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(seconds: lhs.seconds + rhs.seconds)
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.seconds += rhs.seconds
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        .init(seconds: lhs.seconds - rhs.seconds)
    }
    
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.seconds -= rhs.seconds
    }
    
    public static func * <T: BinaryInteger>(lhs: Self, rhs: T) -> Self {
        .init(seconds: lhs.seconds * .init(rhs))
    }
    
    public static func * (lhs: Self, rhs: Float) -> Self {
        .init(seconds: lhs.seconds * .init(rhs))
    }
    
    public static func * (lhs: Self, rhs: Double) -> Self {
        .init(seconds: lhs.seconds * rhs)
    }
    
    public static func * (lhs: Self, rhs: Float80) -> Self {
        .init(seconds: lhs.seconds * .init(rhs))
    }
    
    public static func * <T: BinaryInteger>(lhs: T, rhs: Self) -> Self {
        rhs * lhs
    }
    
    public static func * (lhs: Float, rhs: Self) -> Self {
        rhs * lhs
    }
    
    public static func * (lhs: Double, rhs: Self) -> Self {
        rhs * lhs
    }
    
    public static func * (lhs: Float80, rhs: Self) -> Self {
        rhs * lhs
    }
    
    public static func *= <T: BinaryInteger>(lhs: inout Self, rhs: T) {
        lhs.seconds *= .init(rhs)
    }
    
    public static func *= (lhs: inout Self, rhs: Float) {
        lhs.seconds *= .init(rhs)
    }
    
    public static func *= (lhs: inout Self, rhs: Double) {
        lhs.seconds *= rhs
    }
    
    public static func *= (lhs: inout Self, rhs: Float80) {
        lhs.seconds *= .init(rhs)
    }
    
    public static func / <T: BinaryInteger>(lhs: Self, rhs: T) -> Self {
        .init(seconds: lhs.seconds / .init(rhs))
    }
    
    public static func / (lhs: Self, rhs: Float) -> Self {
        .init(seconds: lhs.seconds / .init(rhs))
    }
    
    public static func / (lhs: Self, rhs: Double) -> Self {
        .init(seconds: lhs.seconds / rhs)
    }
    
    public static func / (lhs: Self, rhs: Float80) -> Self {
        .init(seconds: lhs.seconds / .init(rhs))
    }
    
    public static func / <T: BinaryInteger>(lhs: T, rhs: Self) -> Self {
        rhs / lhs
    }
    
    public static func / (lhs: Float, rhs: Self) -> Self {
        rhs / lhs
    }
    
    public static func / (lhs: Double, rhs: Self) -> Self {
        rhs / lhs
    }
    
    public static func / (lhs: Float80, rhs: Self) -> Self {
        rhs / lhs
    }
    
    public static func /= <T: BinaryInteger>(lhs: inout Self, rhs: T) {
        lhs.seconds /= .init(rhs)
    }
    
    public static func /= (lhs: inout Self, rhs: Float) {
        lhs.seconds /= .init(rhs)
    }
    
    public static func /= (lhs: inout Self, rhs: Double) {
        lhs.seconds /= rhs
    }
    
    public static func /= (lhs: inout Self, rhs: Float80) {
        lhs.seconds /= .init(rhs)
    }
    
    public static func / (lhs: Self, rhs: Self) -> Double {
        lhs.seconds / rhs.seconds
    }
    
    private(set) var seconds: Double
}

public extension BinaryInteger {
    var seconds: Duration {
        .init(seconds: .init(self))
    }
}

public extension Float {
    var seconds: Duration {
        .init(seconds: .init(self))
    }
}

public extension Double {
    var seconds: Duration {
        .init(seconds: .init(self))
    }
}

public extension Float80 {
    var seconds: Duration {
        .init(seconds: .init(self))
    }
}
