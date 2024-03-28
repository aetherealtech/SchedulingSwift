import Assertions
import Synchronization
import XCTest

@testable import Scheduling

final class TimerTests: XCTestCase {
    func testSchedule() throws {
        for _ in 0..<100 {
            let fireDates = (0..<10).map { index in
                Date() + 8.5 * Double(index)
            }
            
            @Synchronized
            var workInvocations = 0

            let scheduler = MockScheduler()

            @Synchronized
            var completedAfterInvocations: Int? = nil
            
            let onComplete = { @Sendable [_completedAfterInvocations, _workInvocations] in
                _completedAfterInvocations.wrappedValue = _workInvocations.wrappedValue
            }

            let timer = scheduler.runTimer(
                at: fireDates,
                onFire: { [_workInvocations] in
                    _workInvocations.wrappedValue += 1
                },
                onComplete: onComplete
            )
            
            scheduler.process()

            try assertTrue(scheduler.runAtInvocations.elementsEqual(fireDates, by: { invocation, expectedFireTime in
                invocation.time == expectedFireTime
            }))
            
            try assertEqual(workInvocations, fireDates.count)
            try assertEqual(completedAfterInvocations, workInvocations)
            
            withExtendedLifetime(timer) {}
        }
    }
    
    func testCancel() throws {
        for _ in 0..<100 {
            let fireDates = (0..<10).map { index in
                Date() + 8.5 * Double(index)
            }
            
            let invocationsCount = Int.random(in: fireDates.indices)
            
            @Synchronized
            var workInvocations = 0

            let scheduler = MockScheduler()

            @Synchronized
            var completedAfterInvocations: Int? = nil
            
            let onComplete = { @Sendable [_completedAfterInvocations, _workInvocations] in
                _completedAfterInvocations.wrappedValue = _workInvocations.wrappedValue
            }

            @Synchronized
            var timer: Scheduling.Timer! = nil

            timer = scheduler.runTimer(
                at: fireDates,
                onFire: { [_workInvocations, _timer] in
                    _workInvocations.write { workInvocations in
                        if workInvocations == invocationsCount {
                            _timer.wrappedValue = nil
                            return
                        }
                        
                        workInvocations += 1
                    }
                },
                onComplete: onComplete
            )
            
            scheduler.process()

            try assertEqual(workInvocations, invocationsCount)
            try assertEqual(completedAfterInvocations, workInvocations)
        }
    }

    struct TestTimerValue: Equatable {
        let data: String
        let fireTime: Date
    }

    func testWithValues() throws {
        for _ in 0..<100 {
            let values = (0..<10)
                .map { index in
                    TestTimerValue(
                        data: "Value #\(index)",
                        fireTime: Date() + 8.5 * Double(index)
                    )
                }

            let fireDates = values.map { value in value.fireTime }

            @Synchronized
            var receivedValues = [TestTimerValue]()

            let scheduler = MockScheduler()

            let timer = scheduler.runTimer(
                values: values,
                getFireTime: { value in value.fireTime }
            ) { [_receivedValues] value in
                _receivedValues.wrappedValue.append(value)
            }

            scheduler.process()

            try assertTrue(scheduler.runAtInvocations.elementsEqual(fireDates, by: { invocation, expectedFireTime in
                invocation.time == expectedFireTime
            }))

            try assertEqual(receivedValues, values)
            
            withExtendedLifetime(timer) {}
        }
    }
}
