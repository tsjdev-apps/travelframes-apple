#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Use the selected Xcode. Override DEVELOPER_DIR locally when xcode-select
# points at Command Line Tools. No signing identity is needed for simulators.
xcodebuild -version
for configuration in Debug Release; do
    settings=$(mktemp)
    xcodebuild -project src/TravelFrames.xcodeproj -scheme TravelFrames \
        -configuration "$configuration" -showBuildSettings -json > "$settings"
    python3 - "$settings" "$configuration" <<'PY'
import json, sys
with open(sys.argv[1]) as stream:
    targets = json.load(stream)
app = [t for t in targets if t['target'] == 'TravelFrames']
assert len(app) == 1, 'Expected exactly one main app target'
identifier = app[0]['buildSettings']['PRODUCT_BUNDLE_IDENTIFIER']
assert identifier == 'de.tsjdev-apps.travelframes', identifier
print(f'{sys.argv[2]} app identifier: {identifier}')
PY
    rm "$settings"
done

if [[ -z "${SIMULATOR_ID:-}" ]]; then
    devices=$(mktemp)
    xcrun simctl list devices available -j > "$devices"
    SIMULATOR_ID=$(python3 - "$devices" "${1:-iPhone}" <<'PY'
import json, re, sys
with open(sys.argv[1]) as stream:
    devices = json.load(stream)['devices']
candidates = []
for runtime, entries in devices.items():
    version = re.search(r'iOS-(\d+)-(\d+)', runtime)
    if not version or int(version[1]) < 26:
        continue
    for device in entries:
        if device['isAvailable'] and device['name'].startswith(sys.argv[2]):
            candidates.append(((int(version[1]), int(version[2])), device['name'], device['udid']))
if not candidates:
    sys.exit(f'No available {sys.argv[2]} simulator with iOS 26 or later. Install a runtime in Xcode Settings > Components.')
# Prefer a mini for tablet coverage, then a smaller phone where available.
candidates.sort(key=lambda c: (c[0], 'mini' in c[1] or c[1].endswith('e'), c[1]), reverse=True)
print(candidates[0][2])
PY
)
    rm "$devices"
fi
echo "Testing simulator: $SIMULATOR_ID"
mkdir -p build
xcodebuild test -project src/TravelFrames.xcodeproj -scheme TravelFrames \
    -configuration Debug -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
    -parallel-testing-enabled NO \
    -derivedDataPath build/DerivedData \
    -resultBundlePath "build/Tests-$(date +%Y%m%d-%H%M%S).xcresult" \
    CODE_SIGNING_ALLOWED=NO
