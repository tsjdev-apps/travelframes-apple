# TravelFrames

A native, offline collage app for iPhone and iPad (iOS/iPadOS 26+).

Phase 1 provides an English/German overview, creation of an in-memory blank
collage, adaptive editor tools and native back navigation. Photos, Files,
templates, export and saved drafts arrive in later phases.

Open `src/TravelFrames.xcodeproj` in Xcode 26 or later and select the shared
**TravelFrames** scheme. No third-party dependencies are required.

Pull requests run both test targets on an iPhone 17 simulator using a direct
`xcodebuild test` command, following the Image Sortr pipeline. Run
`bash scripts/test.sh iPhone` and `bash scripts/test.sh iPad` for additional local
bundle-identifier and device checks. See
[Development](docs/Development.md) for destinations, verification and the
Phase 2 handoff. Commits, pushes and pull requests are initiated by the developer.
