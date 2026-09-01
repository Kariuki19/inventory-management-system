# Demo Mode — Expiration & Exit Workflow Implementation

This document outlines the implementation of the demo mode expiration and exit workflow as specified.

## Implementation Overview

### 1. Demo Timer Expiration (Trigger 1)
**Files involved:** `demo_provider.dart`, `demo_service.dart`, `demo_workspace_screen.dart`

- The app runs a backend-tracked timer (stored in SharedPreferences with session token)
- Timer is validated server-side via backend (commented in code for implementation)
- When remaining time reaches zero:
  - `DemoProvider._refreshRemaining()` detects expiration
  - Sets `_endReason = DemoEndedReason.timeExpired`
  - Calls `_handleSessionEnd()` which cancels the timer and clears the session
  - The callback `_onExpired` is triggered, calling `_redirectToExpired()`
  - User sees a toast notification: "Your demo session has expired"
  - After 500ms delay, user is navigated to `DemoExpiredScreen` with `demoEndReason: timeExpired`

### 2. Manual Exit (Trigger 2)
**Files involved:** `demo_workspace_screen.dart`, `demo_countdown_banner.dart`

- **Exit button location:** Top navigation bar (in `DemoCountdownBanner` widget)
- **Confirmation dialog:**
  - Text: "Exit demo mode? You can restart anytime."
  - Actions: Cancel / Exit
- **On confirmation:**
  - Calls `_exitDemo()` in `DemoWorkspaceScreen`
  - Sets `_isExiting = true` and `_expiredHandled = true` (double-trigger protection)
  - Logs analytics event: `demoExitClicked`
  - Calls `DemoService.clearSession(reason: DemoEndedReason.manualExit)`
  - Redirects to `DemoExpiredScreen` with `demoEndReason: manualExit`

### 3. Demo Ended Screen (Unified Destination)
**File:** `demo_expired_screen.dart`

Both expiration and manual exit paths lead to the exact same screen with consistent UI:

**Visual Elements:**
- Timer icon (off) in soft orange circle (Color: 0xFFFF6B00, opacity: 0.1)
- Headline: "Your Demo Has Ended" (always the same)
- Subtext: "Your interactive demo session has expired. Choose a plan to continue using Cloudora."
- Primary CTA: "View Plans & Upgrade" → navigates to `UpgradePlanScreen`
- Secondary link: "Talk to Sales" → Opens consultation dialog
- "Send Feedback" button → Opens Google Form in external browser
- "Back to Home" button → Clears navigation stack and returns to `LandingScreen`

**State Parameter for Analytics (Not UI):**
```dart
enum DemoEndedReason { timeExpired, manualExit }
```
- Passed to screen via `demoEndReason` parameter
- Used only for analytics events (reason property in logs)
- Does NOT affect UI rendering

### 4. Analytics Events
**File:** `analytics_service.dart`

Events tracked with reason tracking (timeExpired / manualExit):

| Event | Reason | Purpose |
|-------|--------|---------|
| `demoStarted` | N/A | Session initiated |
| `demoExitClicked` | N/A | User clicked exit button |
| `demoEndedScreenViewed` | timeExpired / manualExit | User reached Demo Ended screen |
| `feedbackFormOpened` | timeExpired / manualExit | User opened feedback form |
| `viewPlansClicked` | N/A | User clicked "View Plans & Upgrade" |
| `talkToSalesClicked` | N/A | User clicked "Talk to Sales" |
| `backToHomeClicked` | N/A | User clicked "Back to Home" |

## Edge Case Handling

### Double-Trigger Protection
**Implementation:** `demo_workspace_screen.dart`

Two flags prevent double execution:
- `_isExiting`: Set to true in `_exitDemo()`, checked in `_handleDemoExpired()`
- `_expiredHandled`: Set to true in `_redirectToExpired()`, checked in `_redirectToExpired()` itself

If timer expires at the same moment user taps "Exit Demo Mode":
1. First method to execute sets both flags
2. Second method's entry guards short-circuit it
3. Result: Single navigation, single session close

### Network Loss During Demo
**Implementation:** `demo_provider.dart` - `handleNetworkLoss()` method

- App can't reach backend to confirm session closure
- Still routes user to Demo Ended screen locally
- Background retry with 2-second timeout:
  ```dart
  await DemoService.clearSession(reason: DemoEndedReason.timeExpired)
      .timeout(const Duration(seconds: 2))
      .catchError((_) { /* silently fail if network down */ });
  ```
- User experience not blocked by network failures

### Re-Entry Prevention
**Implementation:** `demo_service.dart` - Session validation

- Once session is cleared via `clearSession()`, both timestamp and token are removed
- `validateSession()` checks for token existence
- `isSessionExpired()` verifies remaining time <= zero
- "Back to Home" uses `pushAndRemoveUntil()` to clear navigation stack
- Cannot silently re-enter expired session

### Repeat Demos
- New demo sessions start from entry point elsewhere in the app
- `DemoExpiredScreen` has no path to restart demo
- Only option: "View Plans & Upgrade", "Talk to Sales", or "Back to Home"

## Session State Management

**SharedPreferences Keys:**
- `demo_session_start`: ISO8601 timestamp of session start
- `demo_session_token`: Server-side validation token
- `demo_session_ended_reason`: Last demo end reason (timeExpired / manualExit)

**Session Duration:**
```dart
static const Duration guestDemoDuration = Duration(minutes: 5);
```

**Session Token:**
- Generated on each session start: `DateTime.now().millisecondsSinceEpoch.toString()`
- Used for server-side validation (backend integration ready)
- Cleared on session end

## Important Notes

1. **"Start 14-Day Free Trial" button:** Explicitly removed from Demo Ended screen and flows. Not present anywhere in the demo expiration path per spec.

2. **Consistent UI:** The `DemoExpiredScreen` now has ONE component/route, not duplicates. The `DemoExpiryReason` enum was removed in favor of using only `DemoEndedReason` for analytics differentiation.

3. **Toast notification:** Shown before navigation jump (non-blocking) to make the transition feel less abrupt to the user.

4. **Feedback form:** Opens in external browser using `url_launcher` with `LaunchMode.externalApplication` to prevent blocking the app.

5. **Backend integration ready:** Code structure and comments indicate where backend validations should occur for:
   - Session token validation
   - Server-side redundancy (not just client-side timers)
   - Tamper prevention

## Testing Checklist

- [ ] Timer counts down and auto-expires after 5 minutes
- [ ] Manual exit shows confirmation dialog and responds correctly
- [ ] Demo Ended screen appears from both paths
- [ ] All CTA buttons navigate correctly
- [ ] Feedback form opens without blocking
- [ ] Analytics events fire with correct reason property
- [ ] Double-trigger protection prevents duplicate navigation
- [ ] Network loss doesn't block Demo Ended screen appearance
- [ ] Re-entry to expired session is prevented
- [ ] "Back to Home" clears navigation stack properly
