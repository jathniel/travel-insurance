import SwiftUI

/// One purchased policy in the home screen list.
struct PolicyRowView: View {
    var policy: Policy
    var theme: BrandTheme

    var body: some View {
        HStack {
            Image(systemName: "shield.checkered")
                .font(.title2)
                .foregroundStyle(theme.accentColor)

            VStack(alignment: .leading) {
                Text("\(policy.quote.tierName) — \(policy.flight.destinationDisplayName)")
                    .font(.headline)

                Text(policy.policyNumber)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(policy.quote.formattedPrice)
                .font(.subheadline)
                .bold()
        }
    }
}
