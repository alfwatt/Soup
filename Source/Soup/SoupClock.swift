import Foundation

open class SoupClock: NSObject, SoupTime {
    public let earliest: Date
    public let latest: Date
    private let alwaysMatch: Bool

    public required init(earliest: Date, andLatest latest: Date) {
        self.earliest = earliest
        self.latest = latest
        self.alwaysMatch = false
        super.init()
    }

    private init(earliest: Date, latest: Date, alwaysMatch: Bool) {
        self.earliest = earliest
        self.latest = latest
        self.alwaysMatch = alwaysMatch
        super.init()
    }

    public static func earlier() -> SoupTime {
        earlierThan(Date())
    }

    public static func earlierThan(_ latest: Date) -> SoupTime {
        SoupClock(earliest: .distantPast, andLatest: latest)
    }

    public static func later() -> SoupTime {
        laterThan(Date())
    }

    public static func laterThan(_ earliest: Date) -> SoupTime {
        SoupClock(earliest: earliest, andLatest: .distantFuture)
    }

    public static func anytime() -> SoupTime {
        SoupClock(earliest: .distantPast, andLatest: .distantFuture)
    }

    public static func whenever() -> SoupTime {
        SoupClock(earliest: .distantPast, latest: .distantFuture, alwaysMatch: true)
    }

    public static func never() -> SoupTime {
        SoupClock(earliest: .distantFuture, andLatest: .distantPast)
    }

    public static func interval(_ seconds: TimeInterval, before latest: Date) -> SoupTime {
        SoupClock(earliest: latest.addingTimeInterval(-seconds), andLatest: latest)
    }

    public static func interval(_ seconds: TimeInterval, around center: Date) -> SoupTime {
        let half = seconds / 2
        return SoupClock(earliest: center.addingTimeInterval(-half), andLatest: center.addingTimeInterval(half))
    }

    public static func interval(_ seconds: TimeInterval, after earliest: Date) -> SoupTime {
        SoupClock(earliest: earliest, andLatest: earliest.addingTimeInterval(seconds))
    }

    public static func recently() -> SoupTime { interval(5 * 60, before: Date()) }
    public static func nowish() -> SoupTime { interval(2 * 60, around: Date()) }
    public static func soonish() -> SoupTime { interval(5 * 60, after: Date()) }

    public static func today() -> SoupTime {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start) ?? Date()
        return SoupClock(earliest: start, andLatest: end)
    }

    public static func thisMonth() -> SoupTime {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        let end = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: start) ?? now
        return SoupClock(earliest: start, andLatest: end)
    }

    public static func thisYear() -> SoupTime {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(from: calendar.dateComponents([.year], from: now)) ?? now
        let end = calendar.date(byAdding: DateComponents(year: 1, second: -1), to: start) ?? now
        return SoupClock(earliest: start, andLatest: end)
    }

    public static func lastYear() -> SoupTime {
        shiftYear(by: -1)
    }

    public static func lastDecade() -> SoupTime {
        shiftYears(startOffset: -10, length: 10)
    }

    public static func lastCentury() -> SoupTime {
        shiftYears(startOffset: -100, length: 100)
    }

    public static func lastMillennium() -> SoupTime {
        shiftYears(startOffset: -1000, length: 1000)
    }

    public static func nextYear() -> SoupTime {
        shiftYear(by: 1)
    }

    public static func nextDecade() -> SoupTime {
        shiftYears(startOffset: 0, length: 10)
    }

    public static func nextCentury() -> SoupTime {
        shiftYears(startOffset: 0, length: 100)
    }

    public static func nextMillennium() -> SoupTime {
        shiftYears(startOffset: 0, length: 1000)
    }

    private static func shiftYear(by offset: Int) -> SoupTime {
        let calendar = Calendar.current
        let now = Date()
        let thisStart = calendar.date(from: calendar.dateComponents([.year], from: now)) ?? now
        let start = calendar.date(byAdding: .year, value: offset, to: thisStart) ?? now
        let end = calendar.date(byAdding: DateComponents(year: 1, second: -1), to: start) ?? now
        return SoupClock(earliest: start, andLatest: end)
    }

    private static func shiftYears(startOffset: Int, length: Int) -> SoupTime {
        let calendar = Calendar.current
        let now = Date()
        let thisStart = calendar.date(from: calendar.dateComponents([.year], from: now)) ?? now
        let start = calendar.date(byAdding: .year, value: startOffset, to: thisStart) ?? now
        let end = calendar.date(byAdding: DateComponents(year: length, second: -1), to: start) ?? now
        return SoupClock(earliest: start, andLatest: end)
    }

    public func interval() -> TimeInterval {
        latest.timeIntervalSince(earliest)
    }

    public func compare(_ date: Date) -> ComparisonResult {
        if alwaysMatch { return .orderedSame }
        if earliest > latest { return .orderedAscending }
        if date < earliest { return .orderedAscending }
        if date > latest { return .orderedDescending }
        return .orderedSame
    }
}
