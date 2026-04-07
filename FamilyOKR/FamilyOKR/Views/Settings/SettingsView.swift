import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var members: [FamilyMember]
    @Query private var objectives: [Objective]
    @State private var showingResetAlert = false
    @State private var showingSampleDataAlert = false

    var body: some View {
        Form {
            Section("About") {
                HStack {
                    Text("App")
                    Spacer()
                    Text("Family OKR Tracker")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Statistics") {
                HStack {
                    Label("Family Members", systemImage: "person.3")
                    Spacer()
                    Text("\(members.count)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Label("Total Objectives", systemImage: "target")
                    Spacer()
                    Text("\(objectives.count)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Label("Total Key Results", systemImage: "list.bullet")
                    Spacer()
                    Text("\(objectives.flatMap(\.keyResults).count)")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Data") {
                Button("Load Sample Data") {
                    showingSampleDataAlert = true
                }
                .alert("Load Sample Data?", isPresented: $showingSampleDataAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Load") { loadSampleData() }
                } message: {
                    Text("This will add sample family members and objectives to help you get started.")
                }

                Button("Reset All Data", role: .destructive) {
                    showingResetAlert = true
                }
                .alert("Reset All Data?", isPresented: $showingResetAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Reset", role: .destructive) { resetData() }
                } message: {
                    Text("This will permanently delete all family members, objectives, and key results. This action cannot be undone.")
                }
            }

            Section("How OKRs Work") {
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(
                        icon: "target",
                        title: "Objectives",
                        detail: "Qualitative goals that describe what you want to achieve. Keep them ambitious and inspiring."
                    )
                    InfoRow(
                        icon: "list.bullet",
                        title: "Key Results",
                        detail: "Measurable outcomes that indicate whether you're meeting your objective. Aim for 2-5 per objective."
                    )
                    InfoRow(
                        icon: "calendar",
                        title: "Quarterly Cycles",
                        detail: "Set OKRs each quarter. Review progress weekly and adjust as needed."
                    )
                    InfoRow(
                        icon: "person.3",
                        title: "Family Alignment",
                        detail: "Share objectives across the family to stay aligned and support each other's goals."
                    )
                }
            }
        }
        .navigationTitle("Settings")
    }

    private func loadSampleData() {
        let period = OKRPeriod.currentQuarter()

        // Create family members
        let parent1 = FamilyMember(name: "Mom", role: .parent, avatarEmoji: "👩", colorHex: "#E91E63")
        let parent2 = FamilyMember(name: "Dad", role: .parent, avatarEmoji: "👨", colorHex: "#3498DB")
        let child1 = FamilyMember(name: "Emma", role: .child, avatarEmoji: "👧", colorHex: "#9B59B6")
        let child2 = FamilyMember(name: "Jack", role: .child, avatarEmoji: "👦", colorHex: "#2ECC71")

        modelContext.insert(parent1)
        modelContext.insert(parent2)
        modelContext.insert(child1)
        modelContext.insert(child2)

        // Mom's objectives
        let obj1 = Objective(title: "Improve family health habits", description: "Build sustainable healthy routines for the whole family", priority: .high, period: period)
        obj1.owner = parent1
        modelContext.insert(obj1)

        let kr1 = KeyResult(title: "Cook healthy dinners per week", targetValue: 5, currentValue: 3, unit: "times")
        kr1.objective = obj1
        modelContext.insert(kr1)

        let kr2 = KeyResult(title: "Family walks per week", targetValue: 4, currentValue: 2, unit: "times")
        kr2.objective = obj1
        modelContext.insert(kr2)

        // Dad's objectives
        let obj2 = Objective(title: "Strengthen family finances", description: "Build better saving and budgeting habits", priority: .high, period: period)
        obj2.owner = parent2
        modelContext.insert(obj2)

        let kr3 = KeyResult(title: "Monthly savings target", targetValue: 1000, currentValue: 650, unit: "items")
        kr3.objective = obj2
        modelContext.insert(kr3)

        // Emma's objectives
        let obj3 = Objective(title: "Excel in school", description: "Maintain high grades and develop study habits", priority: .medium, period: period)
        obj3.owner = child1
        modelContext.insert(obj3)

        let kr4 = KeyResult(title: "Homework completion rate", targetValue: 100, currentValue: 85, unit: "%")
        kr4.objective = obj3
        modelContext.insert(kr4)

        let kr5 = KeyResult(title: "Books read this quarter", targetValue: 6, currentValue: 4, unit: "items")
        kr5.objective = obj3
        modelContext.insert(kr5)

        // Jack's objectives
        let obj4 = Objective(title: "Learn to play guitar", description: "Practice consistently and learn new songs", priority: .medium, period: period)
        obj4.owner = child2
        modelContext.insert(obj4)

        let kr6 = KeyResult(title: "Practice sessions per week", targetValue: 5, currentValue: 3, unit: "sessions")
        kr6.objective = obj4
        modelContext.insert(kr6)

        let kr7 = KeyResult(title: "Songs learned", targetValue: 4, currentValue: 1, unit: "items")
        kr7.objective = obj4
        modelContext.insert(kr7)
    }

    private func resetData() {
        do {
            try modelContext.delete(model: ProgressEntry.self)
            try modelContext.delete(model: KeyResult.self)
            try modelContext.delete(model: Objective.self)
            try modelContext.delete(model: FamilyMember.self)
        } catch {
            print("Failed to reset data: \(error)")
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.accentColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.semibold)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
