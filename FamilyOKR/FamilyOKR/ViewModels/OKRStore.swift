import Foundation
import SwiftUI
import SwiftData

@Observable
final class OKRStore {
    var selectedPeriod: OKRPeriod = .currentQuarter()
    var selectedMember: FamilyMember?
    var searchText: String = ""

    func filteredObjectives(from objectives: [Objective]) -> [Objective] {
        var result = objectives.filter { $0.period == selectedPeriod }

        if let member = selectedMember {
            result = result.filter { $0.owner?.id == member.id }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.objectiveDescription.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result.sorted { $0.priority.sortOrder < $1.priority.sortOrder }
    }

    func overallProgress(from objectives: [Objective]) -> Double {
        let filtered = filteredObjectives(from: objectives)
        guard !filtered.isEmpty else { return 0 }
        let total = filtered.reduce(0.0) { $0 + $1.progress }
        return total / Double(filtered.count)
    }

    func statusCounts(from objectives: [Objective]) -> [OKRStatus: Int] {
        let filtered = filteredObjectives(from: objectives)
        var counts: [OKRStatus: Int] = [:]
        for status in OKRStatus.allCases {
            counts[status] = filtered.filter { $0.status == status }.count
        }
        return counts
    }

    func objectivesForMember(_ member: FamilyMember, from objectives: [Objective]) -> [Objective] {
        objectives.filter { $0.owner?.id == member.id && $0.period == selectedPeriod }
    }

    func memberProgress(_ member: FamilyMember, from objectives: [Objective]) -> Double {
        let memberObjectives = objectivesForMember(member, from: objectives)
        guard !memberObjectives.isEmpty else { return 0 }
        let total = memberObjectives.reduce(0.0) { $0 + $1.progress }
        return total / Double(memberObjectives.count)
    }
}
