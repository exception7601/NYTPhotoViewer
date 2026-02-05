#!/bin/sh
set -e

set -- "iOS" "iOS Simulator"
ROOT=".build/xcframeworks"
FRAMEWORK_PATH="Products/Library/Frameworks/NYTPhotoViewer.framework"
BUILD_COMMIT=$(git log --oneline --abbrev=16 --pretty=format:"%h" -1)
NAME=NYTPhotoViewer.${BUILD_COMMIT}.zip
VERSION=5.0.8
REPO=exception7601/NYTPhotoViewer
ARCHIVE_NAME=nytphotoviewer
FRAMEWORK_NAME=NYTPhotoViewer
ORIGIN=$(pwd)
rm -rf $ROOT

for PLATFORM in "$@"; do
  xcodebuild archive \
    -project "$FRAMEWORK_NAME.xcodeproj" \
    -scheme "$FRAMEWORK_NAME" \
    -destination "generic/platform=$PLATFORM" \
    -archivePath "$ROOT/$ARCHIVE_NAME-$PLATFORM.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    DEBUG_INFORMATION_FORMAT=DWARF
done

xcodebuild -create-xcframework \
  -framework "$ROOT/$ARCHIVE_NAME-iOS.xcarchive/$FRAMEWORK_PATH" \
  -framework "$ROOT/$ARCHIVE_NAME-iOS Simulator.xcarchive/$FRAMEWORK_PATH" \
  -output "$ROOT/$FRAMEWORK_NAME.xcframework"

cd "$ROOT"
zip -rX "$NAME" "$FRAMEWORK_NAME.xcframework/"
mv "$NAME" "$ORIGIN"
cd "$ORIGIN"

SUM=$(swift package compute-checksum "${NAME}")
BUILD=$(date +%s)
NEW_VERSION=${VERSION}.${BUILD}
echo "$NEW_VERSION" >version

DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${NEW_VERSION}/${NAME}"

git add version
git commit -m "new Version ${NEW_VERSION}"
git tag -s -a "${NEW_VERSION}" -m "v${NEW_VERSION}"
git push origin HEAD --tags
gh release create "${NEW_VERSION}" "${NAME}" --notes "checksum \`${SUM}\`"

NOTES=$(
  cat <<END
SPM binaryTarget

\`\`\`swift
.binaryTarget(
    name: "NYTPhotoViewer",
    url: "${DOWNLOAD_URL}",
    checksum: "${SUM}"
)
\`\`\`
END
)

gh release edit "${NEW_VERSION}" --notes "${NOTES}"
echo "${NOTES}"
