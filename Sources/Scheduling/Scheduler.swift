 //
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation

public protocol Scheduler {

    func run(_ task: @escaping () -> Void)

    func run(at time: Date, _ task: @escaping () -> Void)
}

public struct TimedOutError : Error { }

extension Scheduler {

    public func run(after delay: TimeInterval, _ task: @escaping () -> Void) {

        run(at: Date().addingTimeInterval(delay), task)
    }
    
    public func runAndWait(timeout: TimeInterval = .infinity, _ task: @escaping () -> Void) throws {
        
        try performAndWait(task: task, timeout: timeout, perform: run)
    }
    
    public func runAndWait(at time: Date, timeout: TimeInterval = .infinity, _ task: @escaping () -> Void) throws {
        
        try performAndWait(task: task, timeout: timeout) { task in
            
            run(at: time, task)
        }
    }
    
    public func runAndWait(after delay: TimeInterval, timeout: TimeInterval = .infinity, _ task: @escaping () -> Void) throws {
        
        try performAndWait(task: task, timeout: timeout) { task in
            
            run(after: delay, task)
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
    
    public func runAndWait<Result>(at time: Date, timeout: TimeInterval = .infinity, _ task: @escaping () -> Result) throws -> Result {
        
        var result: Result!
        
        try runAndWait(at: time) {
            
            result = task()
        }
                
        return result
    }
    
    public func runAndWait<Result>(at time: Date, _ task: @escaping () -> Result) -> Result {
        
        try! runAndWait(at: time, timeout: .infinity, task)
    }
    
    public func runAndWait<Result>(after delay: TimeInterval, timeout: TimeInterval = .infinity, _ task: @escaping () -> Result) throws -> Result {
        
        var result: Result!
        
        try runAndWait(after: delay) {
            
            result = task()
        }
                
        return result
    }
    
    public func runAndWait<Result>(after delay: TimeInterval, _ task: @escaping () -> Result) -> Result {
        
        try! runAndWait(after: delay, timeout: .infinity, task)
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
