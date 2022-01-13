//
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation

private class WorkItem {

    init(work: @escaping () -> Void) {

        self.work = work
    }

    let work: () -> Void
}

extension CFRunLoop : Scheduler {

    public func run(_ task: @escaping () -> Void) {
        
        let workItemPtr = UnsafeMutablePointer<WorkItem>.allocate(capacity: 1)
        workItemPtr.initialize(to: WorkItem(work: task))

        var context = CFRunLoopSourceContext()
        context.info = UnsafeMutableRawPointer(workItemPtr)
        context.perform = { info in

            let workItemPtr = info!.assumingMemoryBound(to: WorkItem.self)
            let workItem = workItemPtr.pointee
            workItem.work()
            workItemPtr.deallocate()
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
    
    public func run(at time: Date, _ task: @escaping () -> Void) {
        
        let workItemPtr = UnsafeMutablePointer<WorkItem>.allocate(capacity: 1)
        workItemPtr.initialize(to: WorkItem(work: task))

        var context = CFRunLoopTimerContext()
        context.info = UnsafeMutableRawPointer(workItemPtr)

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
                    
                    let workItemPtr = info!.assumingMemoryBound(to: WorkItem.self)
                    let workItem = workItemPtr.pointee
                    workItem.work()
                    workItemPtr.deallocate()
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

extension RunLoop : Scheduler {
    
    class Work
    {
        init(_ task: @escaping () -> Void) {
            
            self.task = task
        }
        
        @objc func run() {
            
            task()
        }
        
        let task: () -> Void
    }
    
    public func run(_ task: @escaping () -> Void) {
        
        let work = Work(task)

        self.perform(
            #selector(Work.run),
            target: work,
            argument: nil,
            order: 0,
            modes: [.default]
        )
    }
    
    public func run(at time: Date, _ task: @escaping () -> Void) {
        
        let work = Work(task)

        let timer = Foundation.Timer(
            fireAt: time,
            interval: .infinity,
            target: work,
            selector: #selector(Work.run),
            userInfo: nil,
            repeats: false
        )
        
        self.add(timer, forMode: .default)
    }
}
