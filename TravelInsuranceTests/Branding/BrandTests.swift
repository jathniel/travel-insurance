import Foundation
import Testing
@testable import TravelInsurance

/// Serialized because `Brand.current` reads shared `UserDefaults.standard` state.
@Suite(.serialized)
struct BrandTests {
    /// Runs `body` with the stored brand selection replaced, restoring the original afterwards.
    private func withStoredBrand(_ rawValue: String?, body: () -> Void) {
        let defaults = UserDefaults.standard
        let original = defaults.string(forKey: Brand.storageKey)
        defer {
            if let original {
                defaults.set(original, forKey: Brand.storageKey)
            } else {
                defaults.removeObject(forKey: Brand.storageKey)
            }
        }

        if let rawValue {
            defaults.set(rawValue, forKey: Brand.storageKey)
        } else {
            defaults.removeObject(forKey: Brand.storageKey)
        }
        body()
    }

    @Test func currentDefaultsToGenericWhenNothingStored() {
        withStoredBrand(nil) {
            #expect(Brand.current == .generic)
        }
    }

    @Test func currentReadsStoredSelection() {
        withStoredBrand("hsbc") {
            #expect(Brand.current == .hsbc)
        }
    }

    @Test func currentFallsBackToGenericForUnknownValue() {
        withStoredBrand("not-a-brand") {
            #expect(Brand.current == .generic)
        }
    }

    @Test(arguments: Brand.allCases)
    func everyBrandHasDisplayName(brand: Brand) {
        #expect(!brand.displayName.isEmpty)
    }

    @Test(arguments: Brand.allCases)
    func everyBrandHasCompleteTheme(brand: Brand) {
        let theme = BrandTheme.theme(for: brand)

        #expect(!theme.productName.isEmpty)
        #expect(!theme.tagline.isEmpty)
        #expect(!theme.logoSystemImage.isEmpty)
    }

    @Test func brandThemesAreDistinct() {
        let generic = BrandTheme.theme(for: .generic)
        let hsbc = BrandTheme.theme(for: .hsbc)

        #expect(generic.productName != hsbc.productName)
    }
}
