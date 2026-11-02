#!/bin/bash
# Archives the app in Release and uploads it to App Store Connect.
#
# Usage:
#   scripts/release.sh                 # archive + upload, using the build number in the project
#   BUILD_NUMBER=2 scripts/release.sh  # override the build number (e.g. to re-upload the same version)
#   UPLOAD=0 scripts/release.sh        # archive + export an .ipa locally, without uploading
#
# Signing is automatic: Xcode must be signed in to the team's Apple account
# (Xcode > Settings > Accounts). -allowProvisioningUpdates lets xcodebuild create
# missing certificates/profiles and use cloud signing for distribution.

set -euo pipefail
cd "$(dirname "$0")/.."

BUILD_DIR="build/release"
ARCHIVE_PATH="$BUILD_DIR/QuoteDroplet.xcarchive"
EXPORT_OPTIONS="scripts/ExportOptions.plist"

BUILD_SETTINGS=()
if [[ -n "${BUILD_NUMBER:-}" ]]; then
    BUILD_SETTINGS+=("CURRENT_PROJECT_VERSION=$BUILD_NUMBER")
fi

if [[ "${UPLOAD:-1}" == "0" ]]; then
    # Same options, but write the .ipa to disk instead of uploading it
    EXPORT_OPTIONS="$BUILD_DIR/ExportOptions-local.plist"
    mkdir -p "$BUILD_DIR"
    cp scripts/ExportOptions.plist "$EXPORT_OPTIONS"
    /usr/libexec/PlistBuddy -c "Set :destination export" "$EXPORT_OPTIONS"
fi

rm -rf "$ARCHIVE_PATH" "$BUILD_DIR/export"

echo "==> Archiving"
xcodebuild archive \
    -workspace "Quote Droplet.xcworkspace" \
    -scheme "Quote Droplet" \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates \
    ${BUILD_SETTINGS[@]+"${BUILD_SETTINGS[@]}"}

VERSION=$(/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleShortVersionString" "$ARCHIVE_PATH/Info.plist")
BUILD=$(/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleVersion" "$ARCHIVE_PATH/Info.plist")
echo "==> Archived version $VERSION ($BUILD)"

echo "==> Exporting"
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    -exportPath "$BUILD_DIR/export" \
    -allowProvisioningUpdates

if [[ "${UPLOAD:-1}" == "0" ]]; then
    echo "==> Done: $BUILD_DIR/export"
else
    echo "==> Uploaded $VERSION ($BUILD) to App Store Connect. It appears under the version's Build section once processing finishes."
fi
