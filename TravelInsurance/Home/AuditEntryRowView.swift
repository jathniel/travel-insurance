import SwiftUI

/// One checkpoint in the audit trail list.
struct AuditEntryRowView: View {
    var entry: AuditEntry

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: entry.step.systemImage)
                .foregroundStyle(.tint)
                .frame(minWidth: 28)

            VStack(alignment: .leading) {
                Text(entry.step.displayName)
                    .font(.headline)

                Text(entry.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(entry.timestamp.formatted(date: .omitted, time: .standard))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
