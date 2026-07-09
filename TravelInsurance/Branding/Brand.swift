import Foundation

/// The two demo brand options: generic/neutral for the HK client demo,
/// HSBC-styled for the orals. Switchable at runtime from the home screen.
enum Brand: String, CaseIterable, Identifiable, Codable, Sendable {
    case generic
    case hsbc

    var id: String { rawValue }

    /// UserDefaults key shared by the app UI and the headless intent runs.
    static let storageKey = "selectedBrand"

    /// The brand currently selected, readable outside SwiftUI (e.g. in intent handlers).
    static var current: Brand {
        guard let rawValue = UserDefaults.standard.string(forKey: storageKey) else { return .generic }
        return Brand(rawValue: rawValue) ?? .generic
    }

    var displayName: String {
        switch self {
        case .generic: "Voyager"
        case .hsbc: "HSBC"
        }
    }
}
