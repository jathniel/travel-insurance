import SwiftUI

/// Branded hero card at the top of the home screen.
struct BrandHeaderView: View {
    var theme: BrandTheme

    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: theme.logoSystemImage)
                .font(.largeTitle)
                .foregroundStyle(.white)

            Text(theme.productName)
                .font(.title2)
                .bold()
                .foregroundStyle(.white)

            Text(theme.tagline)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [theme.accentColor, theme.secondaryColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

#Preview {
    BrandHeaderView(theme: .theme(for: .generic))
    BrandHeaderView(theme: .theme(for: .hsbc))
}
