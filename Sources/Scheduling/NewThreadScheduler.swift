//
//  File.swift
//  
//
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation

public final class NewThreadScheduler: Scheduler {
    public init() {}
    
    public func run(
        _ task: @escaping @Sendable () -> Void
    ) {
        TaskThread(task: task).start()
    }

    public func run(
        at time: Date,
        _ task: @escaping @Sendable () -> Void
    ) {
        TaskThread {
            Thread.sleep(until: time)
            task()
        }.start()
    }    
    
    private final class TaskThread : Thread {
        init(task: @escaping @Sendable () -> Void) {
            self.task = task
        }
        
        override func main() {
            task()
        }
        
        private let task: @Sendable () -> Void
    }
}
