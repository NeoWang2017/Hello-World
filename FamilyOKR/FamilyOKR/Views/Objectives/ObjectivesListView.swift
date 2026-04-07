import SwiftUI
import SwiftData

struct ObjectivesListView: View {
    @Environment(OKRStore.self) private var store
    @Environment(\.modelContext) private var modelContext
    @Query private var objectives: [Objective]
    @Query(sort: \FamilyMember.name) private var members: [FamilyMember]
    @State private var showingAddSheet = false

    var body: some View {
        @Bindable var store = store
        let filtered = store.filteredObjectives(from: objectives)

        List {
            Section {
                MemberFilterChips(members: members)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            if filtered.isEmpty {
                ContentUnavailableView(
                    "No Objectives",
                    systemImage: "target",
                    description: Text("Tap + to create your first objective for \(store.selectedPeriod.label)")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(filtered) { objective in
                    NavigationLink(value: objective.id) {
                        ObjectiveRow(objective: objective)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(filtered[index])
                    }
                }
            }
        }
        .navigationTitle("Objectives")
        .navigationDestination(for: UUID.self) { objectiveId in
            if let objective = objectives.first(where: { $0.id == objectiveId }) {
                ObjectiveDetailView(objective: objective)
            }
        }
        .searchable(text: Bindable(store).searchText, prompt: "Search objectives")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                PeriodPicker()
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddObjectiveView()
        }
    }
}

struct ObjectiveRow: View {
    let objective: Objective

    var body: some View {
        HStack(spacing: 12) {
            ProgressRing(
                progress: objective.progress,
                lineWidth: 4,
                size: 44,
                showLabel: true
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(objective.title)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    Spacer()
                    PriorityBadge(priority: objective.priority)
                }

                HStack(spacing: 8) {
                    if let owner = objective.owner {
                        HStack(spacing: 2) {
                            Text(owner.avatarEmoji)
                                .font(.caption2)
                            Text(owner.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text("\(objective.keyResults.count) key result\(objective.keyResults.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                StatusBadge(status: objective.status)
            }
        }
        .padding(.vertical, 4)
    }
}
