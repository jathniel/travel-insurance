import Foundation
import Testing
@testable import TravelInsurance

struct AuditStepTests {
    @Test(arguments: AuditStep.allCases)
    func everyStepHasDisplayNameAndImage(step: AuditStep) {
        #expect(!step.displayName.isEmpty)
        #expect(!step.systemImage.isEmpty)
    }

    @Test func stepsFollowJourneyOrder() throws {
        let steps = AuditStep.allCases

        let invocation = try #require(steps.firstIndex(of: .invocation))
        let tierSelected = try #require(steps.firstIndex(of: .tierSelected))
        let consentCheck = try #require(steps.firstIndex(of: .consentCheck))
        let biometricAuth = try #require(steps.firstIndex(of: .biometricAuth))
        let journeyComplete = try #require(steps.firstIndex(of: .journeyComplete))

        #expect(invocation == steps.startIndex)
        #expect(tierSelected < consentCheck, "The user picks a tier before consenting to the purchase")
        #expect(consentCheck < biometricAuth)
        #expect(journeyComplete == steps.index(before: steps.endIndex))
    }

    @Test(arguments: AuditStep.allCases)
    func codableRoundTripPreservesStep(step: AuditStep) throws {
        let data = try JSONEncoder().encode(step)
        let decoded = try JSONDecoder().decode(AuditStep.self, from: data)

        #expect(decoded == step)
    }
}
