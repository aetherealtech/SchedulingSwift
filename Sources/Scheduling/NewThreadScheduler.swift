//
//  File.swift
//  
//
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation

public class NewThreadScheduler : Scheduler {

    class TaskThread : Thread {
        
        init(task: @escaping () -> Void) {
            
            self.task = task
        }
        
        override func main() {
            
            task()
        }
        
        private let task: () -> Void
    }
    
    public func run(_ task: @escaping () -> Void) {

        TaskThread(task: task).start()
    }

    public func runAt(time: Date, _ task: @escaping () -> Void) {

        TaskThread {
            
            Thread.sleep(until: time)
            task()
            
        }.start()
    }
}
