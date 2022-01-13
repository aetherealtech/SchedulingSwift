//
//  Created by Daniel Coleman on 1/8/22.
//

import Foundation

public class Timer {

    public static func scheduleWithValues<Value, Values: Sequence>(
        values: Values,
        getFireTime: @escaping (Value) -> Date,
        scheduler: Scheduler,
        _ work: @escaping (Value) -> Void
    ) -> Timer where Values.Element == Value {

        Timer(
            values: values,
            getFireTime: getFireTime,
            scheduler: scheduler,
            work: work
        )
    }

    private init<Value, Values: Sequence>(
        values: Values,
        getFireTime: @escaping (Value) -> Date,
        scheduler: Scheduler,
        work: @escaping (Value) -> Void
    ) where Values.Element == Value {

        self.imp = TimerWithValue(
            values: values,
            getFireTime: getFireTime,
            scheduler: scheduler,
            work: work
        )
    }
    
    private let imp: TimerImp
}

extension Scheduler {

    public func runTimer<FireTimes: Sequence>(
        at fireTimes: FireTimes,
        _ work: @escaping () -> Void
    ) -> Timer where FireTimes.Element == Date {

        runTimer(
            values: fireTimes,
            getFireTime: { fireTime in fireTime }
        ) { _ in

            work()
        }
    }

    public func runTimer<Value, Values: Sequence>(
        values: Values,
        _ work: @escaping (Value) -> Void
    ) -> Timer where Values.Element == (Value, Date) {

        runTimer(
            values: values,
            getFireTime: { (value, time) in time }
        ) { (value, _) in

            work(value)
        }
    }

    public func runTimer<Value, Values: Sequence>(
        values: Values,
        getFireTime: @escaping (Value) -> Date,
        work: @escaping (Value) -> Void
    ) -> Timer where Values.Element == Value {

        Timer.scheduleWithValues(
            values: values,
            getFireTime: getFireTime,
            scheduler: self,
            work
        )
    }
}

private protocol TimerImp {

}

private class TimerWithValue<Value> : TimerImp {

    init<Values: Sequence>(
        values: Values,
        getFireTime: @escaping (Value) -> Date,
        scheduler: Scheduler,
        work: @escaping (Value) -> Void
    ) where Values.Element == Value {

        self.valueIterator = AnyIterator(values.makeIterator())
        self.getFireTime = getFireTime

        self.work = work
        self.scheduler = scheduler

        scheduleNext()
    }

    private let valueIterator: AnyIterator<Value>
    private let getFireTime: (Value) -> Date

    private let work: (Value) -> Void
    private let scheduler: Scheduler

    private func scheduleNext() {

        guard let nextValue = valueIterator.next() else {
            return
        }

        scheduler.runAt(time: getFireTime(nextValue), { [weak self] in

            guard let strongSelf = self else { return }

            strongSelf.work(nextValue)
            strongSelf.scheduleNext()
        })
    }
}