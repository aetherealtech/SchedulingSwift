 //
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation

extension DispatchQueue : Scheduler {
    public func run(
        _ task: @escaping @Sendable () -> Void
    ) {
        async(execute: task)
    }
    
    public func run(
        at time: Date,
        _ task: @escaping @Sendable () -> Void
    ) {
        let timeInterval = time.timeIntervalSinceNow
        let dispatchTime = DispatchTime.now() + timeInterval
        
        asyncAfter(
            deadline: dispatchTime,
            execute: task
        )
    }
}
