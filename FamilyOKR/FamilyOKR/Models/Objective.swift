import Foundation
import SwiftData

@Model
final class Objective {
    var id: UUID
    var title: String
    var objectiveDescription: String
    var icon: String
    var priority: Priority
    var period: OKRPeriod
    var createdAt: Date
    var updatedAt: Date

    var owner: FamilyMember?

    @Relationship(deleteRule: .cascade, inverse: \KeyResult.objective)
    var keyResults: [KeyResult]

    var progress: Double {
        guard !keyResults.isEmpty else { return 0 }
        let total = keyResults.reduce(0.0) { $0 + $1.progress }
        return total / Double(keyResults.count)
    }

    var status: OKRStatus {
        let p = progress
        if p >= 1.0 { return .completed }
        if p >= 0.7 { return .onTrack }
        if p >= 0.3 { return .atRisk }
        if p > 0 { return .behind }
        return .notStarted
    }

    init(
        title: String,
        description: String = "",
        icon: String = "target",
        priority: Priority = .medium,
        period: OKRPeriod = .currentQuarter()
    ) {
        self.id = UUID()
        self.title = title
        self.objectiveDescription = description
        self.icon = icon
        self.priority = priority
        self.period = period
        self.createdAt = Date()
        self.updatedAt = Date()
        self.keyResults = []
    }
}

enum Priority: String, Codable, CaseIterable, Identifiable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .high: return "exclamationmark.3"
        case .medium: return "exclamationmark.2"
        case .low: return "exclamationmark"
        }
    }

    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

enum OKRStatus: String, CaseIterable, Identifiable {
    case notStarted = "Not Started"
    case behind = "Behind"
    case atRisk = "At Risk"
    case onTrack = "On Track"
    case completed = "Completed"

    var id: String { rawValue }

    var color: String {
        switch self {
        case .notStarted: return "gray"
        case .behind: return "red"
        case .atRisk: return "orange"
        case .onTrack: return "blue"
        case .completed: return "green"
        }
    }

    var icon: String {
        switch self {
        case .notStarted: return "circle.dashed"
        case .behind: return "exclamationmark.triangle.fill"
        case .atRisk: return "exclamationmark.circle.fill"
        case .onTrack: return "checkmark.circle"
        case .completed: return "checkmark.circle.fill"
        }
    }
}
