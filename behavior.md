# Behavior — Travel Insurance Siri Demo

**Last updated:** 14 July 2026
**Companion to:** `context.md` (the original build brief). This file records how the app *actually behaves* today, including where it deviates from the brief.

---

## The journey as it runs today

Say **"Hey Siri, I want to buy travel insurance"** (or "Buy travel insurance"). The whole flow is one App Intent — `BuyTravelInsuranceIntent`:

| # | Beat | Where it happens | Status |
|---|------|------------------|--------|
| 1 | Phrase routes to the Travel Insurance Intent | Siri | ✅ Working |
| 2 | Quote fetch — **real Coherent SPARK call** (SIT `traveltest` service) returns live tier prices, which vary with the trip dates (e.g. Standard HKD 350 / **Elite HKD 455, recommended** / Family HKD 637 for the demo's 7-day trip); names/benefits stay local. On any failure Siri reports the fetch failed — no silent mock fallback | Headless, inside Siri | ⏳ Built, awaiting device re-test |
| 3 | 3-tier plan picker (tap or voice) | Siri disambiguation card | ✅ Working |
| 4 | Consent — Siri's native **Buy** confirmation with purchase summary snippet | Siri overlay | ✅ Working |
| 5 | **Face ID** — app comes to the foreground showing a full-screen **verification page** (plan + trip summary, "Confirm with Face ID"); the real Face ID sheet appears on top (passcode fallback). Cancel/failure dismisses the page and aborts before any payment | App (verification page) | ⏳ Built, awaiting device re-test |
| 6 | Mocked payment (always succeeds, 0.8 s delay) → policy written locally → verification page flips to the **in-app success card** (~2.5 s), then auto-dismisses to the home screen with the new policy on top. Siri does **not** speak/show the returned success dialog — once the app foregrounds, the Siri overlay is gone (platform behavior, confirmed on device) | App (success page) | ✅ Working (device-tested 14 July) |
| — | Audit trail records every checkpoint (invocation → … → journey complete) | Local JSON, viewable in-app | ✅ Working |

If the device is locked when the phrase is spoken, the system additionally demands unlock before the intent runs at all (`requiresLocalDeviceAuthentication`).

---

## Platform constraints (hard limits — do not re-attempt)

Two iOS constraints, both confirmed on device, shaped the current design. Together they make **real Face ID** and a **Siri-presented success beat** mutually exclusive:

1. **No Face ID from a headless intent.** Since iOS 13, an intent running under Siri with the app backgrounded cannot present biometrics — `LAContext.evaluatePolicy` fails with `LAError.notInteractive` ("User interaction is required"). There is no App Intents API (through iOS 27) for a biometric prompt inside the Siri overlay, and `requiresLocalDeviceAuthentication` only prompts when the device is locked. The only way to get the real Face ID sheet is to bring the app to the foreground (`continueInForeground`).

2. **No Siri result dialog/card after the foreground hop.** Once `continueInForeground` transitions the app forward, the Siri overlay is dismissed for good. The `dialog` + snippet returned by `perform()` are **never presented** — not spoken, not shown — whether the app then stays foreground or backgrounds itself (both tested on device, 12–14 July; the private `suspend` trick does not bring Siri back). Siri's spoken/shown beats therefore end at the Buy confirmation. Error dialogs still surface normally for failures thrown *before* the hop (quote failure, and auth/payment aborts, which Siri announces because the intent throws).

**Consequence (accepted 14 July):** the success confirmation is visual and in-app only — verification page → success card → policy list. Don't move the `LAContext` call back before the foreground hop (fails per #1), and don't try to make Siri speak/show the success result after it (impossible per #2).

---

## What changed (10 July 2026)

### 1. Siri phrase routing — fixed

**Problem:** "I want to buy travel insurance" did nothing. All registered phrases had the form "Buy travel insurance *with TravelInsurance*" — App Shortcut phrases must contain the app name, and the natural sentence didn't.

**Fix:** The app's display name is now **"Travel Insurance"** (`CFBundleDisplayName`), and the phrases in `Intents/TravelInsuranceShortcuts.swift` embed the app name *as the noun itself*:

- "I want to buy \(.applicationName)" → spoken: *"I want to buy travel insurance"*
- "Buy \(.applicationName)", "Buy \(.applicationName) for this flight / for my trip"
- "Get \(.applicationName)", "Get \(.applicationName) for my flight", "I need \(.applicationName) for my trip"

So the user's natural sentence literally contains the app name and routes correctly — no app is ever named out loud.

> ⚠️ Phrases and the display name are indexed at install time. After changing them, **delete and reinstall** the app on the test device.

### 2. Biometric beat — root cause found, redesigned

**Problem:** After selecting a plan, payment "succeeded" with no Face ID.

**Root cause (platform, not a bug):** since iOS 13, a headless intent running under Siri **cannot present Face ID** — `LAContext` fails with `LAError.notInteractive` ("User interaction is required") because the app process is backgrounded. The original code silently swallowed this error and proceeded to the payment stub, which is why the demo showed success without biometrics. There is no App Intents API (through iOS 26 / WWDC26) for a biometric prompt inside the Siri overlay, and `requiresLocalDeviceAuthentication` only prompts when the device is *locked*.

**Fix (decision: real Face ID via brief app foreground):**

- The intent declares `supportedModes = [.background, .foreground(.dynamic)]` and, after the Buy confirmation, calls `continueInForeground(alwaysConfirm: false)` — the app opens just for the biometric beat.
- Now foregrounded, `LAContext` with `.deviceOwnerAuthentication` presents the **real Face ID sheet** (system passcode fallback if Face ID fails).
- **No silent skips remain.** Every failure path (cancel, failed auth, biometrics unavailable, unexpected error) throws `BuyTravelInsuranceError`, aborts *before* the payment stub, and records the exact reason in the audit trail. Siri says: *"The purchase wasn't authorized, so no payment was taken."*

### 3. Housekeeping

- `BuyTravelInsuranceError` gained an `authenticationUnavailable` case (device has no Face ID/passcode configured).
- Audit entries for the biometric step now record real outcomes/errors instead of "step skipped (demo fallback)".

---

## Deviations from `context.md` — flag for the demo script

1. **"App never opens" is no longer true — deliberately.** The brief (Step 6 / "Success stays in Siri") demanded the app icon never surface. iOS makes real Face ID impossible under that constraint, and once the app foregrounds Siri never presents the intent's result dialog/card (platform behavior, device-confirmed — with or without the suspend trick). The accepted design (14 July) is a **full foreground handoff**: the app opens for the biometric beat, shows a verification page, then an in-app success card that dismisses to the policy list. **Siri's spoken/shown beats end at the Buy confirmation** — the demo script must not promise a Siri-spoken success line. If the orals need the pure in-Siri story back, the alternative (system unlock policy only, Siri Buy button as the consent beat, no visible Face ID when unlocked) is a small revert.
2. **The spoken phrase changed shape.** The demo script should use *"I want to buy travel insurance"* or *"Buy travel insurance"* — not the old "…with TravelInsurance" forms.

---

## What changed (12 July 2026)

### 4. SPARK quote call — now real

`SparkQuoteService` calls the Coherent SPARK SIT `traveltest` Execute endpoint with the trip dates and maps the returned prices onto the local tier metadata (`QuoteTierCatalog`). Failures throw `BuyTravelInsuranceError.quoteServiceUnavailable` — the demo fails loudly rather than falling back to mocks.

> ⚠️ **Before every demo session:** the Keycloak bearer token expires ~2 hours after login. Paste a fresh token into `TravelInsurance/Services/SparkSecrets.swift` (gitignored, as is `sparkapi.txt`). Grab it from the SPARK API Tester's curl export.

**Demo script price change:** prices now come live from the rules engine and *vary with the trip dates* (the demo's rolling +14/+21-day trip quoted Standard 350 / Elite 455 / Family 637 HKD on 12 July) — don't script the old canned 468/562/702.

### 5. App auto-suspends after Face ID *(superseded 14 July — see §6)*

After successful authentication (and the payment stub + policy write), the intent calls the private `UIApplication` `suspend` selector so the app slides back to Mail/home and the success dialog + card land on the Siri surface. **Demo-only:** private API, would be rejected by App Review — strip before any store submission.

---

## What changed (14 July 2026)

### 6. Suspend removed — success beat moved in-app

**Problem:** Device testing showed that after the private `suspend` call backgrounded the app mid-intent, **Siri never rendered the success dialog/card** — the journey visibly dead-ended on the home screen.

**Fix:** The suspend (and its App Review liability) is gone. The app now stays in the foreground after the Face ID hop:

- A new `PurchaseFlowPresenter` (`@Observable`, shared) + `PurchaseVerificationView` full-screen cover (wired at the app root in `TravelInsuranceApp`) own the in-app beats: when the intent foregrounds the app it presents a verification page (plan + trip summary, "Confirm with Face ID") beneath the real Face ID sheet; after payment the page flips to the success card for ~2.5 s, then auto-dismisses to `HomeView` with the new policy at the top.
- Any auth/payment failure resets the page before Siri surfaces the error — no policy is written, and the audit trail records the exact reason.
- Presenter phase transitions are unit-tested in `PurchaseFlowPresenterTests`.

**Platform constraint discovered (14 July device re-test — see "Platform constraints" above):** the hoped-for dual-surface success — Siri speaking/showing the returned dialog + card over the foregrounded app — **does not happen**. Once `continueInForeground` runs, the Siri overlay is dismissed and the result dialog/snippet returned by `perform()` is never presented, whether the app suspends afterwards or stays foreground. Siri's spoken/shown beats end at the Buy confirmation; error dialogs still surface for failures thrown before the hop. Accepted decision: the success confirmation is **visual, in-app only**. The intent still returns the dialog + snippet (harmless, and correct for any context that never foregrounds), but the demo script must not promise a Siri-spoken success line.

---

## Still mocked (unchanged from the brief)

- Flight context: hardcoded `FlightDetails.demo` (Cathay CX785, HKG → Bali) — no real email extraction.
- Payment: `MockPaymentService`, always succeeds.
- Policy + audit log: written to local JSON only.

## Verification state

- ✅ Project builds clean (Xcode, iOS 27 target).
- ✅ Previous device test confirmed: phrase → quotes → tier selection → Buy confirmation → abort-on-auth-failure all behave, with the audit trail capturing the exact error.
- ✅ The foreground hop + real Face ID sheet, and the "Travel Insurance" display name / new phrases after a clean reinstall.
- ✅ `PurchaseFlowPresenter` phase transitions covered by unit tests.
- ✅ Device re-test (14 July): verification page under the Face ID sheet, in-app success beat, auto-dismiss to the policy list with the new policy on top.
- ✅ Device re-test (14 July) confirmed the platform constraint: Siri does not present the result dialog/card after the foreground hop — success is in-app only (accepted).
