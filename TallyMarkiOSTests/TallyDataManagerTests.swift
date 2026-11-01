//
//  TallyDataManagerTests.swift
//  TallyMarkiOSTests
//

import Foundation
import SwiftData
import Testing
@testable import TallyMarkiOS

/// A controllable clock so tests can cross midnight.
final class TestClock {
    var now: Date
    init(_ now: Date) { self.now = now }
}

extension Calendar {
    /// Gregorian in UTC so day boundaries don't depend on the machine running the tests.
    static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar
    }()
}

func utcDate(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    Calendar.utc.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) ?? .distantPast
}

struct TallyDataManagerTests {
    let container: ModelContainer
    let clock: TestClock
    let manager: TallyDataManager

    init() throws {
        container = try TallyStore.makeContainer(inMemory: true)
        clock = TestClock(utcDate(2026, 11, 1, 9))
        let clock = clock
        manager = TallyDataManager(container: container, calendar: .utc, now: { clock.now })
    }

    @Test func startsEmpty() {
        #expect(manager.today == DayCounts())
        #expect(!manager.canUndo)
    }

    @Test func loggingIncrementsTheMatchingCount() {
        manager.log(.distracted)
        manager.log(.distracted)
        manager.log(.resisted)

        #expect(manager.today == DayCounts(distracted: 2, resisted: 1))
        #expect(manager.canUndo)
    }

    @Test func undoRemovesTheMostRecentEvent() {
        manager.log(.distracted)
        clock.now += 60
        manager.log(.resisted)

        manager.undoLast()

        #expect(manager.today == DayCounts(distracted: 1, resisted: 0))
    }

    @Test func countsResetAtMidnight() {
        manager.log(.distracted)
        clock.now = utcDate(2026, 11, 2, 0, 1)

        manager.refresh()

        #expect(manager.today == DayCounts())
        #expect(manager.day == utcDate(2026, 11, 2, 0))
    }

    @Test func undoNeverTouchesEarlierDays() throws {
        manager.log(.distracted)
        clock.now = utcDate(2026, 11, 2, 8)
        manager.refresh()

        manager.undoLast()

        // Yesterday's event survives.
        let remaining = try container.mainContext.fetchCount(FetchDescriptor<DistractionEvent>())
        #expect(remaining == 1)
        #expect(!manager.canUndo)
    }

    @Test func eventsLoggedElsewhereAppearAfterRefresh() throws {
        // Simulates LogEventIntent or the widget writing through another context.
        let otherContext = ModelContext(container)
        otherContext.insert(DistractionEvent(type: .resisted, timestamp: clock.now))
        try otherContext.save()

        manager.refresh()

        #expect(manager.today.resisted == 1)
    }
}

struct DaySummaryTests {
    @Test func groupsEventsByDayNewestFirst() {
        let events = [
            DistractionEvent(type: .distracted, timestamp: utcDate(2026, 10, 30, 9)),
            DistractionEvent(type: .resisted, timestamp: utcDate(2026, 10, 30, 23, 59)),
            DistractionEvent(type: .distracted, timestamp: utcDate(2026, 11, 1, 0, 0))
        ]

        let summaries = DaySummary.summaries(for: events, calendar: .utc)

        #expect(summaries.map(\.date) == [utcDate(2026, 11, 1, 0), utcDate(2026, 10, 30, 0)])
        #expect(summaries.map(\.counts) == [DayCounts(distracted: 1), DayCounts(distracted: 1, resisted: 1)])
    }

    @Test func recentDaysEndsTodayAndFillsGaps() {
        let summaries = [
            DaySummary(date: utcDate(2026, 11, 1, 0), counts: DayCounts(distracted: 3)),
            DaySummary(date: utcDate(2026, 10, 1, 0), counts: DayCounts(resisted: 9)) // Outside the window.
        ]

        let recent = DaySummary.recentDays(14, endingOn: utcDate(2026, 11, 1, 18), from: summaries, calendar: .utc)

        #expect(recent.count == 14)
        #expect(recent.first?.date == utcDate(2026, 10, 19, 0))
        #expect(recent.last?.date == utcDate(2026, 11, 1, 0))
        #expect(recent.last?.counts == DayCounts(distracted: 3))
        #expect(recent.dropLast().allSatisfy { $0.counts == DayCounts() })
    }
}
