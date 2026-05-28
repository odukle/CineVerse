# Data Safety Working Notes (Draft)

Validate and finalize before publishing.

## Likely data types used
- Account identifiers (Firebase Auth user ID, possibly email/name from Google Sign-In)
- App activity (watchlist, watched history, notes, preferences)
- Device/app diagnostics (crash/performance logs via platform/runtime)

## Likely processing
- Recommendation requests sent to backend function
- Third-party API fetches for movie metadata/providers
- Local storage for preferences/history

## Actions before submission
- Confirm exact data collected and whether optional/required.
- Confirm whether data is shared with third parties.
- Confirm data deletion/account deletion behavior.
- Confirm transport encryption in transit.
- Update Play Data safety form to match final behavior exactly.
