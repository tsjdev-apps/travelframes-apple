# Phase 1 verification — 2026-11-28

The results below record the original device-matrix verification. CI has since
been aligned with Image Sortr: one `Build and Test` job runs both test targets
through a direct `xcodebuild test` on iPhone 17, with Xcode's default scheduling.
The extended phone/tablet script remains available locally. See
`docs/Development.md` for the current PR command; hosted timing must be measured
on the next pull request.

## Implementation

The production path is overview → New Collage → blank editor → native Back.
English and German catalogs, compact tools, a collapsible wide inspector,
adaptive work surfaces and accessibility selection traits are implemented.
Drafts remain in memory; importing and persistence are Phase 2 work.

Principal files:

- `src/TravelFrames.xcodeproj`: universal app, unit/UI targets and shared scheme.
- `src/TravelFrames/Models/DraftSession.swift`: draft identity, lifecycle and tool state.
- `src/TravelFrames/Views/OverviewView.swift` and `EditorView.swift`: normal navigation and adaptive editor.
- `src/TravelFrames/Resources`: English/German catalog and appearance-aware colors.
- `tests/TravelFramesTests` and `tests/TravelFramesUITests`: state, resources and navigation regressions.
- `scripts/test.sh` and `.github/workflows/build-and-test.yml`: local/PR verification.
- `AGENTS.md` and `docs/Development.md`: contributor conventions and Phase 2 handoff.

The layout uses available dimensions, with an inspector at 1000+ points wide
and 500+ points high. Accessibility text uses compact tools. The canvas color
is a UI surface in this phase; exported background color will be document data.

## Executed checks

Toolchain: **Xcode 27.2 (27B52)**, selected with the process environment
`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`. The machine's global
Xcode selection was left unchanged. Simulator tests use iOS 27.2 and unsigned
builds. The project deployment target remains iOS/iPadOS 26.0.

| Command/check | Result |
| --- | --- |
| `xcodebuild -list -project src/TravelFrames.xcodeproj` | Shared TravelFrames scheme and all three targets discovered |
| `xcodebuild -showdestinations -project src/TravelFrames.xcodeproj -scheme TravelFrames` | Compatible installed phone/tablet simulators discovered |
| Debug and Release `-showBuildSettings -json`, asserted by the test script | Main app identifier equals `de.tsjdev-apps.travelframes` in both configurations |
| `bash scripts/test.sh iPad` | Passed: 3 unit tests + 3 UI tests, zero failures, iPad mini (A20 Pro) |
| `bash scripts/test.sh iPhone` | Passed: 3 unit tests + 3 UI tests, zero failures, iPhone 17e |
| Release build with generic iOS Simulator destination and `CODE_SIGNING_ALLOWED=NO` | Passed |
| Project plist lint, workflow YAML parsing, `bash -n scripts/test.sh`, `git diff --check` | Passed |

The Release build command was:

```sh
xcodebuild build -project src/TravelFrames.xcodeproj -scheme TravelFrames \
  -configuration Release -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/travelframes-release CODE_SIGNING_ALLOWED=NO
```

All three UI cases create a draft through the normal button, select Photos,
rotate to landscape and back, check unchanged draft identity and tool selection,
and return to the overview. Standard-text cases run in English/light and
German/light. The third runs in German/dark with accessibility text size 1.
On iPad, standard-text cases also collapse and reopen the inspector.
Draft identity is exposed to automation only through an explicit Debug test
launch flag; production VoiceOver does not announce the UUID.

The resource test resolves compiled catalog colors in both appearances and
checks opacity and distinct workspace/canvas surfaces. This protects against
invisible surfaces caused by incorrectly formatted catalog components.

Result bundles contain portrait and landscape screenshots for all UI cases.
The iPad German light/wide and German dark/accessibility/portrait screenshots
were exported and visually inspected: canvas edges, selected-tool checkmarks,
labels and native back navigation are visible. This is simulator screenshot
review; the SwiftUI previews were supplied but not rendered during this task.
The final phone German dark/accessibility landscape screenshot was also
inspected: the short canvas caption fits and all tool labels and the selection
checkmark remain visible; the tool description is available by scrolling.

Final iPad result bundle: `build/Tests-20261128-195643.xcresult`.
Final iPhone result bundle: `build/Tests-20261128-195834.xcresult`.

## Remaining acceptance checks

- Actual iPad multitasking at a narrow window width, including safe-area behavior,
  needs manual review. Full-screen mini portrait and automated compact-layout
  decisions passed; those do not constitute a real multitasking-window test.
- VoiceOver reading/focus restoration, hardware keyboard traversal and system
  Reduce Motion/Transparency settings need device/manual review.
- iOS 26 and an older small iPhone/physical iPad mini were not exercised. The
  available simulator models and runtime are identified above.
- Hosted GitHub Actions execution awaits a developer-controlled commit/push or
  pull request. Both matrix commands are exercised locally; no Git operations
  were performed by the agent.

Issue acceptance items are checked only for completed, evidenced work. The
localization/appearance/narrow-window item stays open for the actual narrow
iPad multitasking check. The app shell for that presentation is implemented.
