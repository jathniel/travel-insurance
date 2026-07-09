import Foundation

/// The control-plane checkpoints from the story map, in journey order.
enum AuditStep: String, Codable, CaseIterable, Sendable {
    case invocation
    case sessionValidation
    case quoteReturned
    case guardrailCheck
    case consentCheck
    case tierSelected
    case biometricAuth
    case paymentProcessed
    case policyIssued
    case journeyComplete

    var displayName: String {
        switch self {
        case .invocation: "Siri Invocation"
        case .sessionValidation: "Session Validation"
        case .quoteReturned: "Quote Returned"
        case .guardrailCheck: "Guardrail Check"
        case .consentCheck: "Consent Check"
        case .tierSelected: "Tier Selected"
        case .biometricAuth: "Biometric Authentication"
        case .paymentProcessed: "Payment Processed"
        case .policyIssued: "Policy Issued"
        case .journeyComplete: "Journey Complete"
        }
    }

    var systemImage: String {
        switch self {
        case .invocation: "waveform"
        case .sessionValidation: "person.badge.shield.checkmark"
        case .quoteReturned: "doc.text.magnifyingglass"
        case .guardrailCheck: "checkmark.shield"
        case .consentCheck: "hand.raised"
        case .tierSelected: "checklist"
        case .biometricAuth: "faceid"
        case .paymentProcessed: "creditcard"
        case .policyIssued: "doc.badge.plus"
        case .journeyComplete: "checkmark.seal"
        }
    }
}
