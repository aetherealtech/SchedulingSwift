//
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation
import Synchronization

public final class LoopingThread: Thread, Scheduler, @unchecked Sendable {
    public override init() {
        super.init()
        start()
    }
    
    public var runLoop: CFRunLoop {
        runLoopReady.wait()
        return runLoopValue
    }

    public func run(
        _ task: @escaping @Sendable () -> Void
    ) {
        runLoop.run(task)
    }
    
    public func run(
        at time: Date,
        _ task: @escaping @Sendable () -> Void
    ) {
        runLoop.run(
            at: time,
            task
        )
    }
    
    override public func main() {
        runLoopValue = CFRunLoopGetCurrent()
        runLoopReady.signal(reset: false)

        let keepAliveSource = CFRunLoopTimerCreateWithHandler(
            CFAllocatorGetDefault().takeUnretainedValue(),
            CFAbsoluteTime.infinity,
            0.0,
            0,
            0
        ) { _ in }

        CFRunLoopAddTimer(runLoopValue, keepAliveSource, .defaultMode)
        CFRunLoopRun()
    }

    private var runLoopValue: CFRunLoop!
    private let runLoopReady = Event()
}
