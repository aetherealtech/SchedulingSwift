 //
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation

public protocol Scheduler {

    func run(_ task: @escaping () -> Void)

    func runAt(time: Date, _ task: @escaping () -> Void)
}

public struct TimedOutError : Error { }

extension Scheduler {

    public func runAfter(delay: TimeInterval, _ task: @escaping () -> Void) {

        runAt(time: Date().addingTimeInterval(delay), task)
    }
    
    public func runAndWait(timeout: TimeInterval = .infinity, _ task: @escaping () -> Void) throws {
        
        try performAndWait(task: task, timeout: timeout, perform: run)
    }
    
    public func runAtAndWait(timeout: TimeInterval = .infinity, time: Date, _ task: @escaping () -> Void) throws {
        
        try performAndWait(task: task, timeout: timeout) { task in
            
            runAt(time: time, task)
        }
    }
    
    public func runAfterAndWait(delay: TimeInterval, timeout: TimeInterval = .infinity, _ task: @escaping () -> Void) throws {
        
        try performAndWait(task: task, timeout: timeout) { task in
            
            runAfter(delay: delay, task)
        }
    }

    public func runAndWait<Result>(timeout: TimeInterval = .infinity, _ task: @escaping () -> Result) throws -> Result {
        
        var result: Result!
        
        try runAndWait {
            
            result = task()
        }
                
        return result
    }
    
    public func runAndWait<Result>(_ task: @escaping () -> Result) -> Result {
        
        try! runAndWait(timeout: .infinity, task)
    }
    
    public func runAtAndWait<Result>(time: Date, timeout: TimeInterval = .infinity, _ task: @escaping () -> Result) throws -> Result {
        
        var result: Result!
        
        try runAtAndWait(time: time) {
            
            result = task()
        }
                
        return result
    }
    
    public func runAtAndWait<Result>(time: Date, _ task: @escaping () -> Result) -> Result {
        
        try! runAtAndWait(time: time, timeout: .infinity, task)
    }
    
    public func runAfterAndWait<Result>(delay: TimeInterval, timeout: TimeInterval = .infinity, _ task: @escaping () -> Result) throws -> Result {
        
        var result: Result!
        
        try runAfterAndWait(delay: delay) {
            
            result = task()
        }
                
        return result
    }
    
    public func runAfterAndWait<Result>(delay: TimeInterval, _ task: @escaping () -> Result) -> Result {
        
        try! runAfterAndWait(delay: delay, timeout: .infinity, task)
    }
    
    private func performAndWait(task: @escaping () -> Void, timeout: TimeInterval, perform: (@escaping () -> Void) -> Void) throws {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        perform {
            
            task()
            semaphore.signal()
        }
        
        let dispatchTime: DispatchTime = timeout.isInfinite ? .distantFuture : .now() + timeout
        if case .timedOut = semaphore.wait(timeout: dispatchTime) {
            
            throw TimedOutError()
        }
    }
}
