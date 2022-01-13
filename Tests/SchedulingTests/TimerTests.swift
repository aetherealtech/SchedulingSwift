import XCTest
@testable import Scheduling

class MockScheduler : Scheduler {

    func run(_ task: @escaping () -> Void) {
        
    }
    
    var runAtInvocations: [(time: Date, () -> Void)] = []
    func runAt(time: Date, _ task: @escaping () -> Void) {
        
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

final class TimerTests: XCTestCase {
    
    func testSchedule() {
     
        for _ in 0..<100 {
            
            let fireDates = (0..<10).map { index in
                
                Date() + 8.5 * Double(index)
            }
            
            var workInvocations = 0

            let scheduler = MockScheduler()

            let timer = Timer.schedule(
                at: fireDates,
                on: scheduler
            ) {

                workInvocations += 1
            }
            
            scheduler.process()

            XCTAssertTrue(scheduler.runAtInvocations.elementsEqual(fireDates, by: { invocation, expectedFireTime in
                
                invocation.time == expectedFireTime
            }))
            
            XCTAssertEqual(workInvocations, fireDates.count)
        }
    }
    
    func testCancel() {
     
        for _ in 0..<100 {
            
            let fireDates = (0..<10).map { index in
                
                Date() + 8.5 * Double(index)
            }
            
            let invocationsCount = Int.random(in: fireDates.indices)
            
            var workInvocations = 0

            let scheduler = MockScheduler()

            var timer: Scheduling.Timer! = nil

            timer = Timer.schedule(
                at: fireDates,
                on: scheduler
            ) {
                
                if workInvocations == invocationsCount {
                    timer = nil
                    return
                }
                
                workInvocations += 1
            }
            
            scheduler.process()

            XCTAssertEqual(workInvocations, invocationsCount)
        }
    }
}
