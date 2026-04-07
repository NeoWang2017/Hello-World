import Foundation
import SwiftData

@Model
final class FamilyMember {
    var id: UUID
    var name: String
    var role: FamilyRole
    var avatarEmoji: String
    var colorHex: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Objective.owner)
    var objectives: [Objective]

    init(
        name: String,
        role: FamilyRole = .member,
        avatarEmoji: String = "👤",
        colorHex: String = "#4A90D9"
    ) {
        self.id = UUID()
        self.name = name
        self.role = role
        self.avatarEmoji = avatarEmoji
        self.colorHex = colorHex
        self.createdAt = Date()
        self.objectives = []
    }
}

enum FamilyRole: String, Codable, CaseIterable, Identifiable {
    case parent = "Parent"
    case child = "Child"
    case member = "Member"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .parent: return "person.fill"
        case .child: return "face.smiling"
        case .member: return "person"
        }
    }
}
