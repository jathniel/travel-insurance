import SwiftUI

/// The "Confirm with Face ID" state of the purchase verification page, shown
/// beneath the system Face ID sheet while authentication and payment run.
struct VerifyingContentView: View {
    var quote: InsuranceQuote
    var flight: FlightDetails

    private var theme: BrandTheme {
        BrandTheme.theme(for: Brand.current)
    }

    var body: some View {
        VStack {
            Spacer()

            Image(systemName: "faceid")
                .font(.largeTitle)
                .foregroundStyle(theme.accentColor)

            Text("Confirm with Face ID")
                .font(.title2)
                .bold()

            Text("Approve the prompt to complete your purchase.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            ProgressView()
                .padding()

            Spacer()

            PurchaseConfirmationSnippetView(quote: quote, flight: flight)
                .background(.background.secondary, in: .rect(cornerRadius: 16))
                .padding()
        }
    }
}

#Preview {
    VerifyingContentView(quote: QuoteTierCatalog.baseTiers[1], flight: .demo)
}
