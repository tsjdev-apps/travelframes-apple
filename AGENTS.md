# TravelFrames contributor guidance

TravelFrames is an offline, universal SwiftUI app for iOS/iPadOS 26 or later,
using Swift 6. Keep code and technical documentation in English. User-facing
strings and accessibility labels belong in the English/German catalog at
`src/TravelFrames/Resources/Localizable.xcstrings`.

The shared scheme is `TravelFrames` in `src/TravelFrames.xcodeproj`.
App sources are under `src/TravelFrames`; unit/UI tests are under `tests`.
CI runs `xcodebuild test -project src/TravelFrames.xcodeproj -scheme TravelFrames
-destination 'platform=iOS Simulator,name=iPhone 17,OS=latest'
CODE_SIGNING_ALLOWED=NO`. Run additional local bundle-identifier and device checks
with `bash scripts/test.sh iPhone` and `bash scripts/test.sh iPad`.
See `docs/Development.md` for toolchain setup.

`DraftSession` is the authoritative owner of the in-memory draft identity and
selected tool. Views own presentation state such as inspector expansion.
Phase 2 should extend `CollageDraft` with imported assets and connect real
Photos/Files import actions to the Photos tool in `EditorView`. Do not populate
production drafts with preview fixtures or imply that drafts persist yet.
Keep adaptive decisions testable and preserve native back navigation.

Git changes belong to the developer. Leave edits in the working tree. Do not
stage, commit, push, create branches or open pull requests unless the user
explicitly requests that operation. Do not change issue state. Update issue
checkboxes only when explicitly requested and supported by verification.
