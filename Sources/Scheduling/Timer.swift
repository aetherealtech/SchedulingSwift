//
//  Created by Daniel Coleman on 1/8/22.
//

import Foundation

public class Timer {

    public typealias FireSequence = (Date?) -> Date?
    
    public init(
        fireTimes: @escaping FireSequence,
        work: @escaping () -> Void
    ) {
        
        self.fireTimes = fireTimes
        self.work = work
    }
    
    public func scheduleOn(_ scheduler: Scheduler) {
                
        guard let initialFireTime = fireTimes(nil) else { return }
        
        scheduleNext(scheduler: scheduler, fireTime: initialFireTime)
    }
    
    private let fireTimes: (Date?) -> Date?
    private let work: () -> Void
    
    private func scheduleNext(scheduler: Scheduler, fireTime: Date) {
        
        scheduler.runAt(time: fireTime, { [weak self] in
            
            guard let strongSelf = self else { return }
            
            strongSelf.work()
            
            if let nextFireTime = strongSelf.fireTimes(fireTime) {
                
                strongSelf.scheduleNext(scheduler: scheduler, fireTime: nextFireTime)
            }
        })
    }
}

public struct FireSequences {
    
    @available(*, unavailable) private init() {}
}

extension FireSequences {
    
    public static func regularIntervals(
        initialFireTime: Date,
        interval: TimeInterval,
        latestFireTime: Date = Date.distantFuture
    ) -> Timer.FireSequence {
        
        { lastFireTime in
            
            guard let lastTime = lastFireTime else { return initialFireTime }
            
            let nextFireTime = lastTime + interval
            guard nextFireTime <= latestFireTime else { return nil }
            
            return nextFireTime
        }
    }
    
    public static func regularIntervals(
        initialFireTime: Date,
        interval: TimeInterval,
        count: Int
    ) -> Timer.FireSequence {
        
        regularIntervals(
            initialFireTime: initialFireTime,
            interval: interval,
            latestFireTime: initialFireTime + interval * Double(fireCount)
        )
    }
    
    public static func fireDates<SequenceType: Sequence>(
        _ fireDates: SequenceType
    ) -> Timer.FireSequence where SequenceType.Element == Date {
        
        var iterator = fireDates.makeIterator()
        
        return { _ in iterator.next() }
    }
}
