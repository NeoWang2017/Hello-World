import Foundation
import SwiftData

@Model
final class KeyResult {
    var id: UUID
    var title: String
    var targetValue: Double
    var currentValue: Double
    var unit: String
    var createdAt: Date
    var updatedAt: Date

    var objective: Objective?

    @Relationship(deleteRule: .cascade, inverse: \ProgressEntry.keyResult)
    var entries: [ProgressEntry]

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }

    var progressPercentage: Int {
        Int(progress * 100)
    }

    init(
        title: String,
        targetValue: Double = 100,
        currentValue: Double = 0,
        unit: String = "%"
    ) {
        self.id = UUID()
        self.title = title
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.unit = unit
        self.createdAt = Date()
        self.updatedAt = Date()
        self.entries = []
    }
}

@Model
final class ProgressEntry {
    var id: UUID
    var value: Double
    var note: String
    var date: Date

    var keyResult: KeyResult?

    init(value: Double, note: String = "") {
        self.id = UUID()
        self.value = value
        self.note = note
        self.date = Date()
    }
}
