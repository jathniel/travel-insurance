import SwiftUI

/// The governance trail: every control-plane checkpoint recorded during the Siri journey,
/// newest first. Mocked/local, purely for the demo narrative.
struct AuditLogView: View {
    @Environment(AuditLogStore.self) private var auditLog

    var body: some View {
        List {
            if auditLog.entries.isEmpty {
                ContentUnavailableView(
                    "No Audit Entries",
                    systemImage: "checkmark.shield",
                    description: Text("Entries appear here after a Siri journey runs.")
                )
            } else {
                ForEach(auditLog.entries) { entry in
                    AuditEntryRowView(entry: entry)
                }
            }
        }
        .navigationTitle("Audit Trail")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Clear", systemImage: "trash", role: .destructive) {
                    auditLog.removeAll()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AuditLogView()
            .environment(AuditLogStore.shared)
    }
}
