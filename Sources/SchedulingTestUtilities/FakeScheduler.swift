//
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation
import Scheduling
import Synchronization

public final class FakeScheduler : Scheduler {
    public init() {
        
    }
    
    public func run(_ task: @escaping () -> Void) {
        task()
    }
    
    public func run(
        at time: Instant,
        _ task: @escaping () -> Void
    ) {
        _pendingTasks.write { pendingTasks in
            pendingTasks.append((time: time, task))
            pendingTasks.sort { lhs, rhs in lhs.time < rhs.time }
        }
    }
    
    public var now: Instant {
        get { _now.wrappedValue }
        set {
            while let nextTask = _pendingTasks.write({ pendingTasks -> PendingTask? in
                if let next = pendingTasks.first, next.time <= newValue {
                    return next
                } else {
                    return nil
                }
            }) {
                // Set shared clock's current time to task's time
                nextTask.1()
            }
            
            _now.wrappedValue = newValue
        }
    }
    
    public func reset() {
        _pendingTasks.wrappedValue.removeAll()
    }
    
    private typealias PendingTask = (time: Instant, () -> Void)
    private let _now = Synchronized(wrappedValue: Instant.now)
    private let _pendingTasks = Synchronized<[PendingTask]>(wrappedValue: [])
}
