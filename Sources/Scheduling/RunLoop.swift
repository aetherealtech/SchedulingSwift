//
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation

private final class WorkItem {
    init(work: @escaping @Sendable () -> Void) {
        self.work = work
    }

    let work: @Sendable () -> Void
}

extension CFRunLoop: Scheduler, @unchecked Sendable {
    public func run(_ task: @escaping @Sendable () -> Void) {
        let workItem = UnsafeMutablePointer<@Sendable () -> Void>.allocate(capacity: 1)
        workItem.initialize(to: task)

        var context = CFRunLoopSourceContext()
        context.info = UnsafeMutableRawPointer(workItem)
        
        context.perform = { info in
            let workItem = info!.assumingMemoryBound(to: (@Sendable () -> Void).self)
            workItem.pointee()
            workItem.deallocate()
        }

        withUnsafeMutablePointer(to: &context) { contextPtr in
            let source = CFRunLoopSourceCreate(
                CFAllocatorGetDefault().takeUnretainedValue(),
                0,
                contextPtr
            )

            CFRunLoopAddSource(
                self,
                source,
                CFRunLoopMode.defaultMode
            )

            CFRunLoopSourceSignal(source)
            CFRunLoopWakeUp(self)
        }
    }
    
    public func run(
        at time: Date,
        _ task: @escaping @Sendable () -> Void
    ) {
        let workItem = UnsafeMutablePointer<@Sendable () -> Void>.allocate(capacity: 1)
        workItem.initialize(to: task)

        var context = CFRunLoopTimerContext()
        context.info = UnsafeMutableRawPointer(workItem)

        withUnsafeMutablePointer(to: &context) { contextPtr in
            let timeInterval = time.timeIntervalSinceNow
            let fireTime = CFAbsoluteTimeGetCurrent() + timeInterval

            let timer = CFRunLoopTimerCreate(
                CFAllocatorGetDefault().takeUnretainedValue(),
                fireTime,
                .infinity,
                0,
                0,
                { timer, info in
                    let workItem = info!.assumingMemoryBound(to: (@Sendable () -> Void).self)
                    workItem.pointee()
                    workItem.deallocate()
                },
                contextPtr
            )
            
            CFRunLoopAddTimer(
                self,
                timer,
                .defaultMode
            )

            CFRunLoopWakeUp(self)
        }
    }
}

extension RunLoop: Scheduler, @unchecked Sendable {
    private final class Work {
        init(_ task: @escaping @Sendable () -> Void) {
            self.task = task
        }
        
        @objc func run() {
            task()
        }
        
        let task: @Sendable () -> Void
    }
    
    public func run(_ task: @escaping @Sendable () -> Void) {
        let work = Work(task)

        self.perform(
            #selector(Work.run),
            target: work,
            argument: nil,
            order: 0,
            modes: [.default]
        )
    }
    
    public func run(
        at time: Date,
        _ task: @escaping @Sendable () -> Void
    ) {
        let work = Work(task)

        let timer = Foundation.Timer(
            fireAt: time,
            interval: .infinity,
            target: work,
            selector: #selector(Work.run),
            userInfo: nil,
            repeats: false
        )
        
        self.add(
            timer,
            forMode: .default
        )
    }
}
