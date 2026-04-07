import Foundation

struct OKRPeriod: Codable, Hashable {
    var year: Int
    var quarter: Int

    var label: String {
        "Q\(quarter) \(year)"
    }

    var startDate: Date {
        let month = (quarter - 1) * 3 + 1
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }

    var endDate: Date {
        let month = quarter * 3
        var components = DateComponents()
        components.year = year
        components.month = month + 1
        components.day = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    var daysRemaining: Int {
        let now = Date()
        guard now < endDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: now, to: endDate).day ?? 0
    }

    var totalDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 90
    }

    var timeProgress: Double {
        let now = Date()
        guard now >= startDate else { return 0 }
        guard now <= endDate else { return 1 }
        let elapsed = now.timeIntervalSince(startDate)
        let total = endDate.timeIntervalSince(startDate)
        return elapsed / total
    }

    static func currentQuarter() -> OKRPeriod {
        let now = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)
        let quarter = ((month - 1) / 3) + 1
        return OKRPeriod(year: year, quarter: quarter)
    }

    static func availablePeriods() -> [OKRPeriod] {
        let current = currentQuarter()
        var periods: [OKRPeriod] = []

        // Previous 2 quarters + current + next 2 quarters
        for offset in -2...2 {
            var q = current.quarter + offset
            var y = current.year
            while q < 1 { q += 4; y -= 1 }
            while q > 4 { q -= 4; y += 1 }
            periods.append(OKRPeriod(year: y, quarter: q))
        }

        return periods
    }
}
