import SwiftUI

struct AddKeyResultView: View {
    let objective: Objective
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var targetValue: Double = 100
    @State private var unit = "%"

    private let commonUnits = ["%", "hours", "times", "pages", "miles", "kg", "items", "days", "sessions"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Key Result") {
                    TextField("What will you measure?", text: $title)
                }

                Section("Target") {
                    HStack {
                        Text("Target Value")
                        Spacer()
                        TextField("Value", value: $targetValue, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }

                    Picker("Unit", selection: $unit) {
                        ForEach(commonUnits, id: \.self) { u in
                            Text(u).tag(u)
                        }
                    }
                }

                Section {
                    Text("Example: \"Read 12 books\" → Target: 12, Unit: items")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Key Result")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addKeyResult()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || targetValue <= 0)
                }
            }
        }
    }

    private func addKeyResult() {
        let kr = KeyResult(
            title: title.trimmingCharacters(in: .whitespaces),
            targetValue: targetValue,
            unit: unit
        )
        kr.objective = objective
        modelContext.insert(kr)
        dismiss()
    }
}
