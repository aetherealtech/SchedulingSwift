//
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation

public struct SynchronousScheduler: Scheduler {
    public init() {}
    
    public func run(_ task: @escaping @Sendable () -> Void) {
        task()
    }

    public func run(
        at time: Date,
        _ task: @escaping @Sendable () -> Void
    ) {
        Thread.sleep(until: time)
        task()
    }
}
