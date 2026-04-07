import SwiftUI

struct PeriodPicker: View {
    @Environment(OKRStore.self) private var store

    var body: some View {
        @Bindable var store = store
        Menu {
            ForEach(OKRPeriod.availablePeriods(), id: \.self) { period in
                Button {
                    store.selectedPeriod = period
                } label: {
                    HStack {
                        Text(period.label)
                        if period == store.selectedPeriod {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                Text(store.selectedPeriod.label)
                    .fontWeight(.semibold)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
        }
    }
}

struct MemberFilterChips: View {
    @Environment(OKRStore.self) private var store
    let members: [FamilyMember]

    var body: some View {
        @Bindable var store = store
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    emoji: "👨‍👩‍👧‍👦",
                    isSelected: store.selectedMember == nil
                ) {
                    store.selectedMember = nil
                }

                ForEach(members) { member in
                    FilterChip(
                        title: member.name,
                        emoji: member.avatarEmoji,
                        isSelected: store.selectedMember?.id == member.id
                    ) {
                        store.selectedMember = member
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FilterChip: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
