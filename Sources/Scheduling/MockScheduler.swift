 //
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation

public class MockScheduler : Scheduler {

    public init() {

    }

    public var runInvocations: [() -> Void] = []
    public func run(_ task: @escaping () -> Void) {

        runInvocations.append(task)
        pendingTasks.insert(task, at: 0)
    }

    public var runAtInvocations: [(time: Date, () -> Void)] = []
    public func run(at time: Date, _ task: @escaping () -> Void) {
        
        runAtInvocations.append((time: time, task))
        pendingTasks.insert(task, at: 0)
    }

    public func process() {
        
        while let task = pendingTasks.popLast() {
            
            task()
        }
    }
    
    private var pendingTasks: [() -> Void] = []
}