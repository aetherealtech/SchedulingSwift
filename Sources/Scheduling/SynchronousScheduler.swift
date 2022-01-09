//
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation

public class SynchronousScheduler : Scheduler {

    public init() {
        
    }
    
    public func run(_ task: @escaping () -> Void) {

        task()
    }

    public func runAt(time: Date, _ task: @escaping () -> Void) {

        Thread.sleep(until: time)
        task()
    }
}
