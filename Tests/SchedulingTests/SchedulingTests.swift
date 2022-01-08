import XCTest
@testable import Scheduling

final class SchedulingTests: XCTestCase {
    
    func testSchedulers(_ test: (Scheduler) -> Void) {
        
        schedulers.forEach(test)
    }
    
    func testSchedulersWaiting(_ test: @escaping (Scheduler) -> Void) {
        
        let expectation = self.expectation(description: "Scheduled work was executed")

        let thread = Thread {
            
            self.testSchedulers(test)
            expectation.fulfill()
        }
        
        thread.start()
        
        waitForExpectations(timeout: 10.0, handler: { error in

        })
    }
    
    func testRun(_ scheduler: Scheduler) {
            
        let expectation = self.expectation(description: "Scheduled work was executed")

        scheduler.run {
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0, handler: { error in

            print("")
        })
    }
    
    func testRunAt(_ scheduler: Scheduler) {
    
        let expectedFireTime = Date() + 1.0
        
        let expectation = self.expectation(description: "Scheduled work was executed")

        scheduler.runAt(time: expectedFireTime) {
            
            let actualFireTime = Date()
            XCTAssertTrue(abs(actualFireTime.timeIntervalSince(expectedFireTime)) < 0.25)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0, handler: { error in

        })
    }
    
    func testRunAfter(_ scheduler: Scheduler) {
        
        let expectation = self.expectation(description: "Scheduled work was executed")

        let expectedFireTime = Date() + 1.0

        scheduler.runAfter(delay: 1.0) {
            
            let actualFireTime = Date()
            XCTAssertTrue(abs(actualFireTime.timeIntervalSince(expectedFireTime)) < 0.25)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0, handler: { error in

        })
    }
    
    func testRunAndWait(_ scheduler: Scheduler) {

        var executed = false
        
        try! scheduler.runAndWait {
            
            executed = true
        }
        
        XCTAssertTrue(executed)
    }
    
    func testRunAtAndWait(_ scheduler: Scheduler) {

        var executed = false
        
        let expectedFireTime = Date() + 1.0

        try! scheduler.runAtAndWait(time: expectedFireTime) {
            
            let actualFireTime = Date()
            XCTAssertTrue(abs(actualFireTime.timeIntervalSince(expectedFireTime)) < 0.25)
            
            executed = true
        }
        
        XCTAssertTrue(executed)
    }
    
    func testRunAfterAndWait(_ scheduler: Scheduler) {

        var executed = false
        
        let expectedFireTime = Date() + 1.0

        try! scheduler.runAfterAndWait(delay: 1.0) {
            
            let actualFireTime = Date()
            XCTAssertTrue(abs(actualFireTime.timeIntervalSince(expectedFireTime)) < 0.25)
            
            executed = true
        }
        
        XCTAssertTrue(executed)
    }
    
    func testRunAndWaitWithResult(_ scheduler: Scheduler) {

        let expectedResult = Int.random(in: 0..<100)
        
        let actualResult = scheduler.runAndWait {
            
            return expectedResult
        }
        
        XCTAssertEqual(expectedResult, actualResult)
    }
    
    func testRunAtAndWaitWithResult(_ scheduler: Scheduler) {

        let expectedResult = Int.random(in: 0..<100)

        let expectedFireTime = Date() + 1.0

        let actualResult = scheduler.runAtAndWait(time: expectedFireTime) { () -> Int in
            
            let actualFireTime = Date()
            XCTAssertTrue(abs(actualFireTime.timeIntervalSince(expectedFireTime)) < 0.25)
            
            return expectedResult
        }
        
        XCTAssertEqual(expectedResult, actualResult)
    }
    
    func testRunAfterAndWaitWithResult(_ scheduler: Scheduler) {

        let expectedResult = Int.random(in: 0..<100)

        let expectedFireTime = Date() + 1.0

        let actualResult = scheduler.runAfterAndWait(delay: 1.0) { () -> Int in
            
            let actualFireTime = Date()
            XCTAssertTrue(abs(actualFireTime.timeIntervalSince(expectedFireTime)) < 0.25)
            
            return expectedResult
        }
        
        XCTAssertEqual(expectedResult, actualResult)
    }
    
    let schedulers: [Scheduler] = [
        SynchronousScheduler(),
        NewThreadScheduler(),
        CFRunLoopGetMain(),
        RunLoop.main,
        LoopingThread(),
        DispatchQueue.global()
    ]
    
    func testSchedulerRun() throws {

        testSchedulers(testRun)
    }
    
    func testSchedulerRunAt() throws {
        
        testSchedulers(testRunAt)
    }
    
    func testSchedulerRunAfter() throws {
        
        testSchedulers(testRunAfter)
    }
    
    func testSchedulerRunAndWait() throws {
        
        self.testSchedulersWaiting(self.testRunAndWait)
    }
    
    func testSchedulerRunAtAndWait() throws {
        
        self.testSchedulersWaiting(self.testRunAtAndWait)
    }
    
    func testSchedulerRunAfterAndWait() throws {
        
        self.testSchedulersWaiting(self.testRunAfterAndWait)
    }
    
    func testSchedulerRunAndWaitWithResult() throws {
        
        self.testSchedulersWaiting(self.testRunAndWaitWithResult)
    }
    
    func testSchedulerRunAtAndWaitWithResult() throws {
        
        self.testSchedulersWaiting(self.testRunAtAndWaitWithResult)
    }
    
    func testSchedulerRunAfterAndWaitWithResult() throws {
        
        self.testSchedulersWaiting(self.testRunAfterAndWaitWithResult)
    }
}
