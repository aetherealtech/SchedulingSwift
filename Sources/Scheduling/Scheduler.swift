 //
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation

public protocol Scheduler: Sendable {
    func run(
        _ task: @escaping @Sendable () -> Void
    )

    func run(
        at time: Instant,
        _ task: @escaping @Sendable () -> Void
    )
}

public struct TimedOut: Error {}

extension Scheduler {
    public func run(
        after delay: Duration,
        _ task: @escaping @Sendable () -> Void
    ) {
        run(
            at: Instant.now + delay,
            task
        )
    }
    
    public func runAndWait<R>(
        _ task: @escaping @Sendable () -> R
    ) -> R {
        performAndWait(
            task: task,
            perform: run
        )
    }
    
    public func runAndWait<R>(
        timeout: Duration = .eternity,
        _ task: @escaping @Sendable () throws -> R
    ) throws -> R {
        try performAndWait(
            task: task,
            timeout: timeout,
            perform: run
        )
    }
    
    public func runAndWait<R>(
        at time: Instant,
        _ task: @escaping @Sendable () -> R
    ) -> R {
        performAndWait(
            task: task
        ) { task in
            run(at: time, task)
        }
    }
    
    public func runAndWait<R>(
        at time: Instant,
        timeout: Duration = .eternity,
        _ task: @escaping @Sendable () throws -> R
    ) throws -> R {
        try performAndWait(
            task: task,
            timeout: timeout
        ) { task in
            run(at: time, task)
        }
    }
    
    public func runAndWait<R>(
        after delay: Duration,
        _ task: @escaping @Sendable () -> R
    ) -> R {
        performAndWait(
            task: task
        ) { task in
            run(after: delay, task)
        }
    }
    
    public func runAndWait<R>(
        after delay: Duration,
        timeout: Duration = .eternity,
        _ task: @escaping @Sendable () throws -> R
    ) throws -> R {
        try performAndWait(
            task: task,
            timeout: timeout
        ) { task in
            run(after: delay, task)
        }
    }

    private func performAndWait<R>(
        task: @escaping @Sendable () -> R,
        perform: (@escaping @Sendable () -> Void) -> Void
    ) -> R {
        withUnsafeTemporaryAllocation(of: R.self, capacity: 1) { result in
            nonisolated(unsafe) let result = result.baseAddress!
            
            let semaphore = DispatchSemaphore(value: 0)
                        
            perform {
                result.initialize(to: task())
                semaphore.signal()
            }
            
            semaphore.wait()
            
            return result.pointee
        }
    }
    
    private func performAndWait<R>(
        task: @escaping @Sendable () throws -> R,
        timeout: Duration,
        perform: (@escaping @Sendable () -> Void) -> Void
    ) throws -> R {
        try withUnsafeTemporaryAllocation(of: Result<R, any Error>.self, capacity: 1) { result in
            nonisolated(unsafe) let result = result.baseAddress!

            let semaphore = DispatchSemaphore(value: 0)
            
            perform {
                do {
                    result.initialize(to: .success(try task()))
                } catch {
                    result.initialize(to: .failure(error))
                }
                
                semaphore.signal()
            }
            
            let timeoutSeconds = timeout / 1.seconds
            let dispatchTime: DispatchTime = timeoutSeconds.isInfinite ? .distantFuture : .now() + timeoutSeconds
            
            if case .timedOut = semaphore.wait(timeout: dispatchTime) {
                throw TimedOut()
            }
            
            return try result.pointee.get()
        }
    }
}
