import SwiftUI
import SwiftData

struct AddObjectiveView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(OKRStore.self) private var store
    @Query(sort: \FamilyMember.name) private var members: [FamilyMember]

    @State private var title = ""
    @State private var description = ""
    @State private var priority: Priority = .medium
    @State private var selectedMember: FamilyMember?
    @State private var period: OKRPeriod = .currentQuarter()

    var body: some View {
        NavigationStack {
            Form {
                Section("Objective") {
                    TextField("Title", text: $title)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Details") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { p in
                            Label(p.rawValue, systemImage: p.icon).tag(p)
                        }
                    }

                    Picker("Period", selection: $period) {
                        ForEach(OKRPeriod.availablePeriods(), id: \.self) { p in
                            Text(p.label).tag(p)
                        }
                    }
                }

                Section("Assign To") {
                    if members.isEmpty {
                        Text("No family members yet. Add members first.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Family Member", selection: $selectedMember) {
                            Text("Unassigned").tag(nil as FamilyMember?)
                            ForEach(members) { member in
                                HStack {
                                    Text(member.avatarEmoji)
                                    Text(member.name)
                                }
                                .tag(member as FamilyMember?)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Objective")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addObjective()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear {
            period = store.selectedPeriod
        }
    }

    private func addObjective() {
        let objective = Objective(
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            priority: priority,
            period: period
        )
        objective.owner = selectedMember
        modelContext.insert(objective)
        dismiss()
    }
}
