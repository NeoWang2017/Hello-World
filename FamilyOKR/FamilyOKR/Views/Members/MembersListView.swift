import SwiftUI
import SwiftData

struct MembersListView: View {
    @Environment(OKRStore.self) private var store
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FamilyMember.name) private var members: [FamilyMember]
    @Query private var objectives: [Objective]
    @State private var showingAddMember = false

    var body: some View {
        List {
            if members.isEmpty {
                ContentUnavailableView(
                    "No Family Members",
                    systemImage: "person.3",
                    description: Text("Add your family members to get started")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(members) { member in
                    NavigationLink(value: member.id) {
                        MemberRow(
                            member: member,
                            progress: store.memberProgress(member, from: objectives),
                            objectiveCount: store.objectivesForMember(member, from: objectives).count
                        )
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(members[index])
                    }
                }
            }
        }
        .navigationTitle("Family Members")
        .navigationDestination(for: UUID.self) { memberId in
            if let member = members.first(where: { $0.id == memberId }) {
                MemberDetailView(member: member)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showingAddMember = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddMember) {
            AddMemberView()
        }
    }
}

struct MemberRow: View {
    let member: FamilyMember
    let progress: Double
    let objectiveCount: Int

    var body: some View {
        HStack(spacing: 12) {
            Text(member.avatarEmoji)
                .font(.largeTitle)
                .frame(width: 50, height: 50)
                .background(Color(hex: member.colorHex).opacity(0.15), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.headline)
                HStack(spacing: 8) {
                    Label(member.role.rawValue, systemImage: member.role.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(objectiveCount) objective\(objectiveCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            ProgressRing(progress: progress, lineWidth: 4, size: 40, showLabel: true)
        }
        .padding(.vertical, 4)
    }
}

struct MemberDetailView: View {
    let member: FamilyMember
    @Environment(OKRStore.self) private var store
    @Query private var objectives: [Objective]

    var memberObjectives: [Objective] {
        store.objectivesForMember(member, from: objectives)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 12) {
                    Text(member.avatarEmoji)
                        .font(.system(size: 60))
                        .frame(width: 100, height: 100)
                        .background(Color(hex: member.colorHex).opacity(0.15), in: Circle())

                    Text(member.name)
                        .font(.title)
                        .fontWeight(.bold)

                    Label(member.role.rawValue, systemImage: member.role.icon)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ProgressRing(
                        progress: store.memberProgress(member, from: objectives),
                        lineWidth: 8,
                        size: 80
                    )
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

                // Objectives
                VStack(alignment: .leading, spacing: 12) {
                    Text("Objectives (\(memberObjectives.count))")
                        .font(.headline)

                    if memberObjectives.isEmpty {
                        ContentUnavailableView(
                            "No Objectives",
                            systemImage: "target",
                            description: Text("No objectives assigned for \(store.selectedPeriod.label)")
                        )
                    } else {
                        ForEach(memberObjectives) { objective in
                            ObjectiveRow(objective: objective)
                                .padding()
                                .background(Color.secondary.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .navigationTitle(member.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                PeriodPicker()
            }
        }
    }
}
