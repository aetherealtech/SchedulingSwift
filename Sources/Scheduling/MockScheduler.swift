 //
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation

class MockScheduler : Scheduler {

    func run(_ task: @escaping () -> Void) {
        
    }
    
    var runAtInvocations: [(time: Date, () -> Void)] = []
    func run(at time: Date, _ task: @escaping () -> Void) {
        
        runAtInvocations.append((time: time, task))
        
        pendingTasks.insert(task, at: 0)
    }
    
    func process() {
        
        while let task = pendingTasks.popLast() {
            
            task()
        }
    }
    
    private var pendingTasks: [() -> Void] = []
}
