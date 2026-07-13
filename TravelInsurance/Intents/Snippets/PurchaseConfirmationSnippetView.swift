import SwiftUI

/// Compact purchase summary shown in the Siri confirmation prompt,
/// just before the mocked payment — the "consent" beat of the journey.
struct PurchaseConfirmationSnippetView: View {
    var quote: InsuranceQuote
    var flight: FlightDetails

    private var theme: BrandTheme {
        BrandTheme.theme(for: Brand.current)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: theme.logoSystemImage)
                    .foregroundStyle(theme.accentColor)

                Text(theme.productName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if quote.isRecommended {
                    Text("Recommended")
                        .font(.caption2)
                        .bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(theme.accentColor.opacity(0.15), in: .capsule)
                        .foregroundStyle(theme.accentColor)
                }
            }

            HStack(alignment: .firstTextBaseline) {
                Text("\(quote.tierName) Cover")
                    .font(.title3)
                    .bold()

                Spacer()

                Text(quote.formattedPrice)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(theme.accentColor)
            }

            Label("\(flight.destinationDisplayName) · \(flight.airline) \(flight.flightNumber)", systemImage: "airplane")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label(
                "\(flight.departureDate.formatted(date: .abbreviated, time: .omitted)) – \(flight.returnDate.formatted(date: .abbreviated, time: .omitted))",
                systemImage: "calendar"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Divider()

            ForEach(quote.benefits.prefix(3), id: \.self) { benefit in
                Label(benefit, systemImage: "checkmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.primary)
            }
        }
        .padding()
    }
}

#Preview {
    PurchaseConfirmationSnippetView(
        quote: QuoteTierCatalog.baseTiers[1],
        flight: .demo
    )
}
