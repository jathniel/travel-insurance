import SwiftUI

/// Success card rendered in Siri at the end of the journey — the app never opens.
struct SuccessSnippetView: View {
    var policy: Policy

    private var theme: BrandTheme {
        BrandTheme.theme(for: Brand.current)
    }

    var body: some View {
        VStack {
            Image(systemName: "checkmark.seal.fill")
                .font(.largeTitle)
                .foregroundStyle(theme.accentColor)

            Text("You're Covered")
                .font(.title3)
                .bold()

            Text("\(policy.quote.tierName) travel insurance for your \(policy.flight.destinationDisplayName) trip")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Divider()

            HStack {
                VStack(alignment: .leading) {
                    Text("Policy")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(policy.policyNumber)
                        .font(.callout)
                        .bold()
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Premium")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(policy.quote.formattedPrice)
                        .font(.callout)
                        .bold()
                        .foregroundStyle(theme.accentColor)
                }
            }
        }
        .padding()
    }
}

#Preview {
    SuccessSnippetView(
        policy: .issued(
            for: MockSparkQuoteService.cannedQuotes[1],
            flight: .demo,
            paymentReference: "PAY-DEMO123"
        )
    )
}
