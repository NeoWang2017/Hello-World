import SwiftUI
import SwiftData

struct ObjectiveDetailView: View {
    @Bindable var objective: Objective
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddKeyResult = false
    @State private var showingEditObjective = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                objectiveHeader
                keyResultsSection
            }
            .padding()
        }
        .navigationTitle(objective.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showingEditObjective = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingAddKeyResult) {
            AddKeyResultView(objective: objective)
        }
        .sheet(isPresented: $showingEditObjective) {
            EditObjectiveView(objective: objective)
        }
    }

    private var objectiveHeader: some View {
        VStack(spacing: 16) {
            ProgressRing(progress: objective.progress, lineWidth: 10, size: 120)

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    StatusBadge(status: objective.status)
                    PriorityBadge(priority: objective.priority)
                }

                if let owner = objective.owner {
                    HStack(spacing: 4) {
                        Text(owner.avatarEmoji)
                        Text(owner.name)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }

                if !objective.objectiveDescription.isEmpty {
                    Text(objective.objectiveDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Text(objective.period.label)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var keyResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Key Results")
                    .font(.headline)
                Spacer()
                Button {
                    showingAddKeyResult = true
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                }
            }

            if objective.keyResults.isEmpty {
                ContentUnavailableView(
                    "No Key Results",
                    systemImage: "list.bullet",
                    description: Text("Add key results to track progress toward this objective")
                )
            } else {
                ForEach(objective.keyResults) { keyResult in
                    KeyResultCard(keyResult: keyResult)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct KeyResultCard: View {
    @Bindable var keyResult: KeyResult
    @Environment(\.modelContext) private var modelContext
    @State private var showingUpdateSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(keyResult.title)
                    .fontWeight(.medium)
                Spacer()
                Text("\(keyResult.progressPercentage)%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(progressColor)
            }

            ProgressView(value: keyResult.progress)
                .tint(progressColor)

            HStack {
                Text("\(formatted(keyResult.currentValue)) / \(formatted(keyResult.targetValue)) \(keyResult.unit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Update") {
                    showingUpdateSheet = true
                }
                .font(.caption)
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        .sheet(isPresented: $showingUpdateSheet) {
            UpdateKeyResultView(keyResult: keyResult)
        }
    }

    private var progressColor: Color {
        if keyResult.progress >= 1.0 { return .green }
        if keyResult.progress >= 0.7 { return .blue }
        if keyResult.progress >= 0.3 { return .orange }
        return .red
    }

    private func formatted(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }
}
