import XCTest
@testable import Scheduling

class MockScheduler : Scheduler {
    
    func run(_ task: @escaping () -> Void) {
        
    }
    
    var runAtInvocations: [(time: Date, () -> Void)] = []
    func runAt(time: Date, _ task: @escaping () -> Void) {
        
        runAtInvocations.append((time: time, task))
        task()
    }
}

final class TimerTests: XCTestCase {
    
    func testSchedule() {
     
        for _ in 0..<100 {
            
            let fireDates = (0..<10).map { index in
                
                Date() + 8.5 * Double(index)
            }
            
            var workInvocations = 0
            
            let work: () -> Void = {
                
                workInvocations += 1
            }

            let timer = Timer(
                fireTimes: FireSequences.fireDates(fireDates),
                work: work
            )
            
            let scheduler = MockScheduler()
            
            timer.scheduleOn(scheduler)
            
            XCTAssertTrue(scheduler.runAtInvocations.elementsEqual(fireDates, by: { invocation, expectedFireTime in
                
                invocation.time == expectedFireTime
            }))
            
            XCTAssertEqual(workInvocations, fireDates.count)
        }
    }
    
    func collectFireTimes(_ fireTimes: (Date?) -> Date?) -> [Date] {
    
        var nextFireTime = fireTimes(nil)
        
        var result = [Date]()

        while let fireTime = nextFireTime {
            result.append(fireTime)
            nextFireTime = fireTimes(fireTime)
        }
        
        return result
    }
    
    func testRegularIntervalsWithLatestFireTime() {
     
        for _ in 0..<100 {
            
            let initialFireTime = Date()
            let latestFireTime = initialFireTime + 1000.0
            
            let interval = TimeInterval.random(in: 0..<10.0)
            
            let fireTimes = collectFireTimes(FireSequences.regularIntervals(
                initialFireTime: initialFireTime,
                interval: interval,
                latestFireTime: latestFireTime
            ))
            
            XCTAssertEqual(fireTimes[0], initialFireTime)
            
            for fireTime in fireTimes {
                XCTAssertTrue(fireTime <= latestFireTime)
            }
            
            for index in 0..<(fireTimes.count - 1) {
                
                let fireTime = fireTimes[index]
                let nextFireTime = fireTimes[index + 1]
                
                XCTAssertEqual(nextFireTime.timeIntervalSince(fireTime), interval, accuracy: 0.001)
            }
            
            XCTAssertTrue(latestFireTime.timeIntervalSince(fireTimes.last!) < interval)
        }
    }
    
    func testRegularIntervalsWithCount() {
     
        for _ in 0..<100 {
            
            let initialFireTime = Date()
            
            let interval = TimeInterval.random(in: 0..<10.0)
            let fireCount = Int.random(in: 15..<25)
            
            let fireTimes = collectFireTimes(FireSequences.regularIntervals(
                initialFireTime: initialFireTime,
                interval: interval,
                count: fireCount
            ))
            
            XCTAssertEqual(fireTimes[0], initialFireTime)
            
            if(fireTimes.count != fireCount) {
                print("TEST")
            }
                
            XCTAssertEqual(fireTimes.count, fireCount)

            for index in 0..<(fireTimes.count - 1) {
                
                let fireTime = fireTimes[index]
                let nextFireTime = fireTimes[index + 1]
                
                XCTAssertEqual(nextFireTime.timeIntervalSince(fireTime), interval, accuracy: 0.001)
            }
        }
    }
}
