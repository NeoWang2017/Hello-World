import SwiftUI

struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var size: CGFloat = 80
    var showLabel: Bool = true

    private var statusColor: Color {
        if progress >= 1.0 { return .green }
        if progress >= 0.7 { return .blue }
        if progress >= 0.3 { return .orange }
        if progress > 0 { return .red }
        return .gray
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(statusColor.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(statusColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            if showLabel {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                    .foregroundStyle(statusColor)
            }
        }
        .frame(width: size, height: size)
    }
}

struct StatusBadge: View {
    let status: OKRStatus

    var color: Color {
        switch status {
        case .notStarted: return .gray
        case .behind: return .red
        case .atRisk: return .orange
        case .onTrack: return .blue
        case .completed: return .green
        }
    }

    var body: some View {
        Label(status.rawValue, systemImage: status.icon)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12), in: Capsule())
    }
}

struct PriorityBadge: View {
    let priority: Priority

    var color: Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }

    var body: some View {
        Label(priority.rawValue, systemImage: priority.icon)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12), in: Capsule())
    }
}
