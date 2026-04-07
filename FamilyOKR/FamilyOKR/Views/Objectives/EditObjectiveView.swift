import SwiftUI
import SwiftData

struct EditObjectiveView: View {
    @Bindable var objective: Objective
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FamilyMember.name) private var members: [FamilyMember]

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var priority: Priority = .medium
    @State private var selectedMember: FamilyMember?
    @State private var period: OKRPeriod = .currentQuarter()

    var body: some View {
        NavigationStack {
            Form {
                Section("Objective") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
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

                Section {
                    Button("Delete Objective", role: .destructive) {
                        objective.owner?.objectives.removeAll { $0.id == objective.id }
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Objective")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                title = objective.title
                description = objective.objectiveDescription
                priority = objective.priority
                selectedMember = objective.owner
                period = objective.period
            }
        }
    }

    private func saveChanges() {
        objective.title = title.trimmingCharacters(in: .whitespaces)
        objective.objectiveDescription = description.trimmingCharacters(in: .whitespaces)
        objective.priority = priority
        objective.owner = selectedMember
        objective.period = period
        objective.updatedAt = Date()
        dismiss()
    }
}
