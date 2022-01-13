//
//  Created by Daniel Coleman on 1/8/22.
//

import Foundation

public class Timer {
    
    public static func schedule<FireTimes: Sequence>(
        at fireTimes: FireTimes,
        on scheduler: Scheduler,
        _ work: @escaping () -> Void
    ) -> Timer where FireTimes.Element == Date {
        
        Timer(
            fireTimes: fireTimes,
            scheduler: scheduler,
            work: work
        )
    }
    
    private init<FireTimes: Sequence>(
        fireTimes: FireTimes,
        scheduler: Scheduler,
        work: @escaping () -> Void
    ) where FireTimes.Element == Date {
        
        self.nextFireTime = AnyIterator(fireTimes.makeIterator())
        self.work = work
        self.scheduler = scheduler
        
        scheduleNext()
    }
    
    private let nextFireTime: AnyIterator<Date>
    private let work: () -> Void
    private let scheduler: Scheduler
    
    private func scheduleNext() {
        
        guard let fireTime = nextFireTime.next() else {
            return
        }
        
        scheduler.runAt(time: fireTime, { [weak self] in
            
            guard let strongSelf = self else { return }
            
            strongSelf.work()
            strongSelf.scheduleNext()
        })
    }
}
