 //
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation

public class MockScheduler : Scheduler {

    public init() {

    }

    public var runInvocations: [() -> Void] { _runInvocations }
    public func run(_ task: @escaping () -> Void) {

        _runInvocations.append(task)
        pendingTasks.insert(task, at: 0)
    }

    public var runAtInvocations: [(time: Date, () -> Void)] { _runAtInvocations }
    public func run(at time: Date, _ task: @escaping () -> Void) {
        
        _runAtInvocations.append((time: time, task))
        pendingTasks.insert(task, at: 0)
    }

    public func reset() {

        _runInvocations.removeAll()
        _runAtInvocations.removeAll()
        
        pendingTasks.removeAll()
    }

    public func process() {
        
        while let task = pendingTasks.popLast() {
            
            task()
        }
    }
    
    private var pendingTasks: [() -> Void] = []

    public var _runInvocations: [() -> Void] = []
    public var _runAtInvocations: [(time: Date, () -> Void)] = []
}