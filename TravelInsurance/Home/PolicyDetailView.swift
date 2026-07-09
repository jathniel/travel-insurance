import SwiftUI

/// Full detail for a purchased policy — the proof that the Siri journey "wrote" something.
struct PolicyDetailView: View {
    var policy: Policy
    var theme: BrandTheme

    var body: some View {
        List {
            Section("Policy") {
                LabeledContent("Policy Number", value: policy.policyNumber)
                LabeledContent("Plan", value: policy.quote.tierName)
                LabeledContent("Premium", value: policy.quote.formattedPrice)
                LabeledContent("Purchased", value: policy.purchaseDate.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("Payment Ref", value: policy.paymentReference)
            }

            Section("Trip") {
                LabeledContent("Flight", value: "\(policy.flight.airline) \(policy.flight.flightNumber)")
                LabeledContent("From", value: policy.flight.origin)
                LabeledContent("To", value: policy.flight.destination)
                LabeledContent("Departure", value: policy.flight.departureDate.formatted(date: .abbreviated, time: .omitted))
                LabeledContent("Return", value: policy.flight.returnDate.formatted(date: .abbreviated, time: .omitted))
            }

            Section("Benefits") {
                ForEach(policy.quote.benefits, id: \.self) { benefit in
                    Label(benefit, systemImage: "checkmark.circle")
                        .foregroundStyle(.primary)
                }
            }
        }
        .navigationTitle("\(policy.quote.tierName) Cover")
        .navigationBarTitleDisplayMode(.inline)
        .tint(theme.accentColor)
    }
}
