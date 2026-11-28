# Development and Phase 2 handoff

TravelFrames requires Xcode 26+ with an installed iOS 26+ simulator runtime.
The app uses Swift 6 and supports iPhone and iPad. Open
`src/TravelFrames.xcodeproj`, choose the shared `TravelFrames` scheme and an
installed simulator. Debug and Release both use the app identifier
`de.tsjdev-apps.travelframes`. Device signing is configured by the developer;
the repository does not contain a team or signing identity.

## Run the pull-request checks

If `xcodebuild -version` reports Command Line Tools, select Xcode for this shell:

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -list -project src/TravelFrames.xcodeproj
xcodebuild -showdestinations -project src/TravelFrames.xcodeproj -scheme TravelFrames
xcrun simctl list devices available
bash scripts/test.sh iPhone
bash scripts/test.sh iPad
```

The script checks the resolved main-app bundle identifier in both configurations,
then builds and runs both test targets. It selects an available simulator running
iOS 26 or later, preferring an iPad mini for tablet tests. Select an explicit
installed destination with:

```sh
SIMULATOR_ID='<available-UDID>' bash scripts/test.sh
```

The equivalent test command is:

```sh
xcodebuild test -project src/TravelFrames.xcodeproj -scheme TravelFrames \
  -configuration Debug -destination 'platform=iOS Simulator,id=<available-UDID>' \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
```

The `Build and Test` workflow uses a macOS runner and the same script for phone
and tablet destinations. It propagates the xcodebuild exit status, including
test failures, and uploads result bundles even after a failed test. Local result
bundles are in the ignored `build/` directory. If no suitable runtime exists,
the script fails with an installation hint; install one in Xcode Settings >
Components and rerun. No test accesses Photos, Files, a network or an account.

## Current flow and architecture

Overview → **New Collage / Neue Collage** → empty editor → native Back.
`App/TravelFramesApp.swift` retains the authoritative `Models/DraftSession.swift`.
The session allocates draft identity on creation and rejects repeated creation
while a draft is open. Closing drops the draft; reopening starts a new identity.
Drafts are intentionally in memory and do not survive restart.

`Views/OverviewView.swift` binds navigation to that authoritative session and
restores accessibility focus to the creation button after returning.
`Views/EditorView.swift` renders an empty canvas, selected tool and truthful
placeholder descriptions. It has no enabled export or pretend save operation.
The navigation trailing area is available for future save controls.

An inspector needs at least 1000 points of available width and 500 points of
height, with standard Dynamic Type. Otherwise the scrollable tool panel sits
below the canvas. This deliberately keeps an iPad mini in portrait compact.
Wide layouts reserve 300 points for a collapsible inspector. Its expansion is
view state; draft identity and selected tool are independent of presentation.
Accessibility sizes always use the compact panel. The controls can stack when
their labels need more width, and the panel scrolls in shallow windows.

`Resources/Assets.xcassets` owns the adaptive warm gray/charcoal workspace,
tool surface, empty canvas and terracotta accent. The canvas surface is currently
a UI resource; a future exported background must be a separate document value.
`Resources/Localizable.xcstrings` supplies English and German visible strings
and accessibility labels. There are no count-based strings requiring plurals
in this phase. Native navigation supplies localized back behavior. Buttons use
native keyboard/focus behavior and selection includes a checkmark and selected
accessibility trait. Native controls honor Reduce Motion/Transparency.

## Verification and visual review

`DraftSessionTests` covers duplicate creation, closure, a fresh subsequent draft,
selected-tool lifetime and compact/wide/shallow/accessibility layout decisions.
`NavigationTests` uses stable identifiers in English and German, verifies draft
identity and selection through rotation, and collapses/reopens the wide iPad
inspector. A third test exercises German, dark appearance and accessibility text.
Appearance/text launch overrides exist only in Debug and never add draft data.

For a representative regression, open a draft, choose Photos, rotate a tablet
to landscape, collapse/reopen tools, then return to portrait. Both the canvas
identity and Photos selection must survive. Returning to the overview must make
New Collage reachable again. The automated tests perform these actions.

Previews beside the views provide an empty German overview, a narrow German
accessibility/dark editor and wide open/collapsed inspectors, using the same
fixed draft fixture. Previews are source fixtures; they are not evidence that
they were rendered. See `docs/Verification.md` for checks actually run.

For manual review, use an iPad mini in German with large text and VoiceOver.
Check navigation → canvas → tools reading order, focus after Back, safe areas,
keyboard traversal, light/dark appearance and a narrow multitasking window.
Confirm the canvas boundary stays visible while scrolling the tool panel.
Automated rotation coverage does not replace real multitasking or VoiceOver
review.

## Phase 2 integration points

Extend `CollageDraft` with actual imported asset references. Keep allocation and
active-draft ownership in `DraftSession`; add real Photos and Files actions in
the Photos branch of `EditorView`. Imported data must be shared by both compact
and wide presentations. Add an injectable import boundary when implementing
repeatable cancellation/failure tests. Persistence, permissions and decoding
belong to that later work; there is no placeholder service to replace now.

All Git operations belong to the developer. Review working-tree edits, then
initiate commits, pushes and pull requests yourself.
