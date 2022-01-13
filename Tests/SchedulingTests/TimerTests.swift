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

            let timer = scheduler.runTimer(
                at: fireDates
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

            timer = scheduler.runTimer(
                at: fireDates
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

    struct TestTimerValue : Equatable {

        let data: String
        let fireTime: Date
    }

    func testWithValues() {

        for _ in 0..<100 {

            let values = (0..<10).map { index in

                TestTimerValue(
                    data: "Value #\(index)",
                    fireTime: Date() + 8.5 * Double(index)
                )
            }

            let fireDates = values.map { value in value.fireTime }

            var receivedValues = [TestTimerValue]()

            let scheduler = MockScheduler()

            let timer = scheduler.runTimer(
                values: values,
                getFireTime: { value in value.fireTime }
            ) { value in

                receivedValues.append(value)
            }

            scheduler.process()

            XCTAssertTrue(scheduler.runAtInvocations.elementsEqual(fireDates, by: { invocation, expectedFireTime in

                invocation.time == expectedFireTime
            }))

            XCTAssertEqual(receivedValues, values)
        }
    }
}
