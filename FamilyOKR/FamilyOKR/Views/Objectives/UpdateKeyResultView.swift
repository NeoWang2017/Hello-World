import SwiftUI

struct UpdateKeyResultView: View {
    @Bindable var keyResult: KeyResult
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var newValue: Double = 0
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(keyResult.title)
                            .font(.headline)

                        ProgressView(value: keyResult.progress)
                            .tint(.blue)

                        Text("Current: \(formatted(keyResult.currentValue)) / \(formatted(keyResult.targetValue)) \(keyResult.unit)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Update Progress") {
                    HStack {
                        Text("New Value")
                        Spacer()
                        TextField("Value", value: $newValue, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }

                    Slider(
                        value: $newValue,
                        in: 0...keyResult.targetValue,
                        step: keyResult.targetValue > 100 ? 1 : 0.5
                    )

                    TextField("Note (optional)", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                }

                if !keyResult.entries.isEmpty {
                    Section("History") {
                        ForEach(keyResult.entries.sorted(by: { $0.date > $1.date }).prefix(5)) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(formatted(entry.value) + " \(keyResult.unit)")
                                        .fontWeight(.medium)
                                    if !entry.note.isEmpty {
                                        Text(entry.note)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Text(entry.date, style: .date)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Update Progress")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateProgress()
                    }
                }
            }
            .onAppear {
                newValue = keyResult.currentValue
            }
        }
    }

    private func updateProgress() {
        let entry = ProgressEntry(value: newValue, note: note)
        entry.keyResult = keyResult
        modelContext.insert(entry)
        keyResult.currentValue = newValue
        keyResult.updatedAt = Date()
        if let objective = keyResult.objective {
            objective.updatedAt = Date()
        }
        dismiss()
    }

    private func formatted(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }
}
