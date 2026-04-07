import SwiftUI

struct AddMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var role: FamilyRole = .member
    @State private var selectedEmoji = "👤"
    @State private var selectedColor = "#4A90D9"

    private let avatarEmojis = [
        "👤", "👨", "👩", "👦", "👧", "👶",
        "🧑", "👴", "👵", "🧔", "👱", "🧑‍🦰",
        "🦸", "🧑‍💻", "🧑‍🎓", "🧑‍🏫", "🧑‍🍳", "🧑‍🎨",
        "🐶", "🐱", "🐰", "🦊", "🐻", "🐼"
    ]

    private let colorOptions = [
        "#4A90D9", "#E74C3C", "#2ECC71", "#F39C12",
        "#9B59B6", "#1ABC9C", "#E67E22", "#3498DB",
        "#E91E63", "#00BCD4", "#8BC34A", "#FF9800"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Family member name", text: $name)
                }

                Section("Role") {
                    Picker("Role", selection: $role) {
                        ForEach(FamilyRole.allCases) { r in
                            Label(r.rawValue, systemImage: r.icon).tag(r)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Avatar") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(avatarEmojis, id: \.self) { emoji in
                            Text(emoji)
                                .font(.title)
                                .frame(width: 44, height: 44)
                                .background(
                                    selectedEmoji == emoji
                                        ? Color.accentColor.opacity(0.2)
                                        : Color.secondary.opacity(0.08),
                                    in: RoundedRectangle(cornerRadius: 10)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedEmoji == emoji ? Color.accentColor : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedEmoji = emoji
                                }
                        }
                    }
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == hex ? 3 : 0)
                                        .padding(2)
                                )
                                .onTapGesture {
                                    selectedColor = hex
                                }
                        }
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        Text(selectedEmoji)
                            .font(.system(size: 40))
                            .frame(width: 70, height: 70)
                            .background(Color(hex: selectedColor).opacity(0.2), in: Circle())
                        VStack(alignment: .leading) {
                            Text(name.isEmpty ? "Name" : name)
                                .font(.headline)
                                .foregroundStyle(name.isEmpty ? .secondary : .primary)
                            Text(role.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("Add Member")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addMember()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func addMember() {
        let member = FamilyMember(
            name: name.trimmingCharacters(in: .whitespaces),
            role: role,
            avatarEmoji: selectedEmoji,
            colorHex: selectedColor
        )
        modelContext.insert(member)
        dismiss()
    }
}
