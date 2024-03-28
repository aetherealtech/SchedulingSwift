import Assertions
import AsyncExtensions
import Synchronization
import XCTest

@testable import Scheduling

final class SchedulingTests: XCTestCase {
    func testSchedulerRun() async throws {
        try await tester.testSchedulers(testRun)
    }
    
    func testSchedulerRunAt() async throws {
        try await tester.testSchedulers(testRunAt)
    }
    
    func testSchedulerRunAfter() async throws {
        try await tester.testSchedulers(testRunAfter)
    }
    
    func testSchedulerRunAndWait() async throws {
        try await testSchedulersWaiting(testRunAndWait)
    }
    
    func testSchedulerRunAtAndWait() async throws {
        try await testSchedulersWaiting(testRunAtAndWait)
    }
    
    func testSchedulerRunAfterAndWait() async throws {
        try await testSchedulersWaiting(testRunAfterAndWait)
    }
    
    func testSchedulerRunAndWaitWithResult() async throws {
        try await testSchedulersWaiting(testRunAndWaitWithResult)
    }
    
    func testSchedulerRunAtAndWaitWithResult() async throws {
        try await testSchedulersWaiting(testRunAtAndWaitWithResult)
    }
    
    func testSchedulerRunAfterAndWaitWithResult() async throws {
        try await testSchedulersWaiting(testRunAfterAndWaitWithResult)
    }
    
    private final class Tester: Sendable {
        func testSchedulers(_ test: (Scheduler) async throws -> Void) async rethrows {
            for scheduler in schedulers {
                try await test(scheduler)
            }
        }
        
        let schedulers: [Scheduler] = [
            SynchronousScheduler(),
            NewThreadScheduler(),
            CFRunLoopGetMain(),
            RunLoop.main,
            LoopingThread(),
            DispatchQueue.global()
        ]
    }
    
    private func testSchedulersWaiting(_ test: @escaping @Sendable (Scheduler) throws -> Void) async throws {
        try await tester.testSchedulers { scheduler in
            try await withTimeout(timeInterval: 2.0) {
                try await withCheckedThrowingContinuation { continuation in
                    let thread = Thread {
                        do {
                            try test(scheduler)
                            continuation.resume()
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                    
                    thread.start()
                }
            }
        }
    }
    
    private func testRun(_ scheduler: Scheduler) async throws {
        try await withTimeout(timeInterval: 2.0) {
            await withCheckedContinuation { continuation in
                scheduler.run {
                    continuation.resume()
                }
            }
        }
    }
    
    private func testRunAt(_ scheduler: Scheduler) async throws {
        let expectedFireTime = Date() + 0.1
        
        try await withTimeout(timeInterval: 2.0) {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                scheduler.run(at: expectedFireTime) {
                    let actualFireTime = Date()
                    
                    do {
                        try assertTrue(abs(actualFireTime.timeIntervalSince(expectedFireTime)) < 0.025)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    
                    continuation.resume()
                }
            }
        }
    }
    
    private func testRunAfter(_ scheduler: Scheduler) async throws {
        let expectedFireTime = Date() + 0.1
        
        try await withTimeout(timeInterval: 2.0) {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                scheduler.run(after: 0.1) {
                    let actualFireTime = Date()
                    
                    do {
                        try assertTrue(abs(actualFireTime.timeIntervalSince(expectedFireTime)) < 0.025)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    
                    continuation.resume()
                }
            }
        }
    }
    
    private func testRunAndWait(_ scheduler: Scheduler) throws {
        @Synchronized
        var executed = false
        
        scheduler.runAndWait { [_executed] in
            _executed.wrappedValue = true
        }
        
        try assertTrue(executed)
    }
    
    private func testRunAtAndWait(_ scheduler: Scheduler) throws {
        @Synchronized
        var executed = false
        
        let expectedFireTime = Date() + 0.1
        
        try scheduler.runAndWait(at: expectedFireTime) { [_executed] in
            let actualFireTime = Date()
            try assertTrue(abs(actualFireTime.timeIntervalSince(expectedFireTime)) < 0.025)
            
            _executed.wrappedValue = true
        }
        
        try assertTrue(executed)
    }
    
    private func testRunAfterAndWait(_ scheduler: Scheduler) throws {
        @Synchronized
        var executed = false
        
        let expectedFireTime = Date() + 0.1
        
        try scheduler.runAndWait(after: 0.1) { [_executed] in
            let actualFireTime = Date()
            try assertTrue(abs(actualFireTime.timeIntervalSince(expectedFireTime)) < 0.025)
            
            _executed.wrappedValue = true
        }
        
        try assertTrue(executed)
    }
    
    private func testRunAndWaitWithResult(_ scheduler: Scheduler) throws {
        let expectedResult = Int.random(in: 0..<100)
        
        let actualResult = scheduler.runAndWait {
            expectedResult
        }
        
        try assertEqual(expectedResult, actualResult)
    }
    
    private func testRunAtAndWaitWithResult(_ scheduler: Scheduler) throws {
        let expectedResult = Int.random(in: 0..<100)
        
        let expectedFireTime = Date() + 0.1
        
        let actualResult = try scheduler.runAndWait(at: expectedFireTime) { () -> Int in
            let actualFireTime = Date()
            try assertTrue(abs(actualFireTime.timeIntervalSince(expectedFireTime)) < 0.025)
            
            return expectedResult
        }
        
        try assertEqual(expectedResult, actualResult)
    }
    
    private func testRunAfterAndWaitWithResult(_ scheduler: Scheduler) throws {
        let expectedResult = Int.random(in: 0..<100)
        
        let expectedFireTime = Date() + 0.1
        
        let actualResult = try scheduler.runAndWait(after: 0.1) { () -> Int in
            let actualFireTime = Date()
            try assertTrue(abs(actualFireTime.timeIntervalSince(expectedFireTime)) < 0.025)
            
            return expectedResult
        }
        
        try assertEqual(expectedResult, actualResult)
    }
    
    private let tester = Tester()
}
