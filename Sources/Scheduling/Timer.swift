//
//  Created by Daniel Coleman on 1/8/22.
//

import Foundation
import Synchronization

public struct Timer: Sendable {
    public static func scheduleWithValues<Value: Sendable>(
        values: some Sequence<Value>,
        getFireTime: @escaping @Sendable (Value) -> Date,
        scheduler: Scheduler,
        onFire: @escaping @Sendable (Value) -> Void,
        onComplete: @escaping @Sendable () -> Void
    ) -> Timer {
        .init(
            values: values,
            getFireTime: getFireTime,
            scheduler: scheduler,
            onFire: onFire,
            onComplete: onComplete
        )
    }

    private init<Value: Sendable>(
        values: some Sequence<Value>,
        getFireTime: @escaping @Sendable (Value) -> Date,
        scheduler: Scheduler,
        onFire: @escaping @Sendable (Value) -> Void,
        onComplete: @escaping @Sendable () -> Void
    ) {
        imp = TimerWithValue(
            values: values,
            getFireTime: getFireTime,
            scheduler: scheduler,
            onFire: onFire,
            onComplete: onComplete
        )

        imp.scheduleNext()
    }
    
    private let imp: TimerImp
}

extension Scheduler {
    public func runTimer<FireTimes: Sequence>(
        at fireTimes: FireTimes,
        _ work: @escaping @Sendable () -> Void
    ) -> Timer where FireTimes.Element == Date {
        runTimer(
            values: fireTimes,
            getFireTime: { fireTime in fireTime }
        ) { _ in
            work()
        }
    }

    public func runTimer(
        at fireTimes: some Sequence<Date>,
        onFire: @escaping @Sendable () -> Void,
        onComplete: @escaping @Sendable () -> Void
    ) -> Timer {
        runTimer(
            values: fireTimes,
            getFireTime: { fireTime in fireTime },
            onFire: { _ in onFire() },
            onComplete: onComplete
        )
    }

    public func runTimer<Value: Sendable>(
        values: some Sequence<(Value, Date)>,
        _ work: @escaping @Sendable (Value) -> Void
    ) -> Timer {
        runTimer(
            values: values,
            getFireTime: { (value, time) in time }
        ) { (value, _) in
            work(value)
        }
    }

    public func runTimer<Value: Sendable>(
        values: some Sequence<(Value, Date)>,
        onFire: @escaping @Sendable (Value) -> Void,
        onComplete: @escaping @Sendable () -> Void
    ) -> Timer {
        runTimer(
            values: values,
            getFireTime: { (value, time) in time },
            onFire: { (value, _) in onFire(value) },
            onComplete: onComplete
        )
    }

    public func runTimer<Value: Sendable>(
        values: some Sequence<Value>,
        getFireTime: @escaping @Sendable (Value) -> Date,
        work: @escaping @Sendable (Value) -> Void
    ) -> Timer {
        .scheduleWithValues(
            values: values,
            getFireTime: getFireTime,
            scheduler: self,
            onFire: work,
            onComplete: { }
        )
    }

    public func runTimer<Value: Sendable>(
        values: some Sequence<Value>,
        getFireTime: @escaping @Sendable (Value) -> Date,
        onFire: @escaping @Sendable (Value) -> Void,
        onComplete: @escaping @Sendable () -> Void
    ) -> Timer {
        .scheduleWithValues(
            values: values,
            getFireTime: getFireTime,
            scheduler: self,
            onFire: onFire,
            onComplete: onComplete
        )
    }
}

private protocol TimerImp: Sendable {
    func scheduleNext()
}

private final class TimerWithValue<Value: Sendable>: TimerImp {
    init<Values: Sequence>(
        values: Values,
        getFireTime: @escaping @Sendable (Value) -> Date,
        scheduler: Scheduler,
        onFire: @escaping @Sendable (Value) -> Void,
        onComplete: @escaping @Sendable () -> Void
    ) where Values.Element == Value {
        @Synchronized
        var iterator = values.makeIterator()
        
        self.next = { [_iterator] in _iterator.wrappedValue.next() }
        self.getFireTime = getFireTime

        self.onFire = onFire
        self.onComplete = onComplete

        self.scheduler = scheduler
    }

    deinit {
        onComplete()
    }

    func scheduleNext() {
        guard let nextValue = next() else {
            onComplete()
            return
        }

        scheduler.run(at: getFireTime(nextValue), { [weak self] in
            guard let self else { return }

            self.onFire(nextValue)
            self.scheduleNext()
        })
    }

    private let next: @Sendable () -> Value?
    private let getFireTime: @Sendable (Value) -> Date

    private let onFire: @Sendable (Value) -> Void
    private let onComplete: @Sendable () -> Void

    private let scheduler: Scheduler
}

