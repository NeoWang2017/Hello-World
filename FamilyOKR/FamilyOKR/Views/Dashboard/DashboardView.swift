import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(OKRStore.self) private var store
    @Environment(\.modelContext) private var modelContext
    @Query private var objectives: [Objective]
    @Query(sort: \FamilyMember.name) private var members: [FamilyMember]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                periodInfoCard
                MemberFilterChips(members: members)
                overviewCards
                memberProgressSection
                recentObjectivesSection
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                PeriodPicker()
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Family OKR Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Track your family's goals together")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var periodInfoCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(store.selectedPeriod.label)
                    .font(.title2)
                    .fontWeight(.bold)
                Text("\(store.selectedPeriod.daysRemaining) days remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            ProgressRing(
                progress: store.selectedPeriod.timeProgress,
                lineWidth: 6,
                size: 54,
                showLabel: true
            )
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var overviewCards: some View {
        let filtered = store.filteredObjectives(from: objectives)
        let progress = store.overallProgress(from: objectives)
        let counts = store.statusCounts(from: objectives)

        return LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(
                title: "Overall Progress",
                value: "\(Int(progress * 100))%",
                icon: "chart.line.uptrend.xyaxis",
                color: .blue
            )
            StatCard(
                title: "Objectives",
                value: "\(filtered.count)",
                icon: "target",
                color: .purple
            )
            StatCard(
                title: "Completed",
                value: "\(counts[.completed, default: 0])",
                icon: "checkmark.circle.fill",
                color: .green
            )
        }
    }

    private var memberProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Member Progress")
                .font(.headline)

            if members.isEmpty {
                ContentUnavailableView(
                    "No Family Members",
                    systemImage: "person.3",
                    description: Text("Add family members to start tracking OKRs")
                )
            } else {
                ForEach(members) { member in
                    MemberProgressRow(
                        member: member,
                        progress: store.memberProgress(member, from: objectives),
                        objectiveCount: store.objectivesForMember(member, from: objectives).count
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var recentObjectivesSection: some View {
        let filtered = store.filteredObjectives(from: objectives)
        return VStack(alignment: .leading, spacing: 12) {
            Text("Objectives")
                .font(.headline)

            if filtered.isEmpty {
                ContentUnavailableView(
                    "No Objectives",
                    systemImage: "target",
                    description: Text("Create objectives to start tracking progress")
                )
            } else {
                ForEach(filtered.prefix(5)) { objective in
                    ObjectiveRow(objective: objective)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .fontDesign(.rounded)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct MemberProgressRow: View {
    let member: FamilyMember
    let progress: Double
    let objectiveCount: Int

    var body: some View {
        HStack(spacing: 12) {
            Text(member.avatarEmoji)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color(hex: member.colorHex).opacity(0.15), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .fontWeight(.medium)
                Text("\(objectiveCount) objective\(objectiveCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            ProgressRing(progress: progress, lineWidth: 4, size: 40, showLabel: true)
        }
        .padding(.vertical, 4)
    }
}
