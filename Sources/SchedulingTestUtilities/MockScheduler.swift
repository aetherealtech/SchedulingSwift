//
//  Created by Daniel Coleman on 1/7/22.
//

import Foundation
import Scheduling
import Synchronization

public final class MockScheduler : Scheduler {
   public init() {

   }

   public var runInvocations: [() -> Void] { _runInvocations.wrappedValue }
   public func run(_ task: @escaping () -> Void) {
       _runInvocations.wrappedValue.append(task)
       _pendingTasks.wrappedValue.insert(task, at: 0)
   }

   public var runAtInvocations: [(time: Instant, () -> Void)] { _runAtInvocations.wrappedValue }
   public func run(at time: Instant, _ task: @escaping () -> Void) {
       _runAtInvocations.wrappedValue.append((time: time, task))
       _pendingTasks.wrappedValue.insert(task, at: 0)
   }

   public func reset() {
       _runInvocations.wrappedValue.removeAll()
       _runAtInvocations.wrappedValue.removeAll()
       _pendingTasks.wrappedValue.removeAll()
   }

   public func process() {
       while let task = _pendingTasks.wrappedValue.popLast() {
           task()
       }
   }
   
   private let _pendingTasks = Synchronized<[() -> Void]>(wrappedValue: [])
   private let _runInvocations = Synchronized<[() -> Void]>(wrappedValue: [])
   private let _runAtInvocations = Synchronized<[(time: Instant, () -> Void)]>(wrappedValue: [])
}
