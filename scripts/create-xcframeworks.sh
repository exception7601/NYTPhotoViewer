ROOT=".build/xcframeworks"
FRAMEWORK_PATH="Products/Library/Frameworks/NYTPhotoViewer.framework"
PLATAFORMS=("iOS" "iOS Simulator")
NAME=NYTPhotoViewer.xcframework.zip
VERSION=5.0.8
REPO=exception7601/PhotoBrowser
ARCHIVE_NAME=nytphotoviewer
FRAMEWORK_NAME=NYTPhotoViewer
ORIGIN=$(pwd)
set -e  # Saia no primeiro erro

rm -rf $ROOT

for PLATAFORM in "${PLATAFORMS[@]}"
do
xcodebuild archive \
    -project "$FRAMEWORK_NAME.xcodeproj" \
    -scheme "$FRAMEWORK_NAME" \
    -destination "generic/platform=$PLATAFORM"\
    -archivePath "$ROOT/$ARCHIVE_NAME-$PLATAFORM.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    DEBUG_INFORMATION_FORMAT=DWARF
done

xcodebuild -create-xcframework \
  -framework "$ROOT/$ARCHIVE_NAME-iOS.xcarchive/$FRAMEWORK_PATH" \
  -framework "$ROOT/$ARCHIVE_NAME-iOS Simulator.xcarchive/$FRAMEWORK_PATH" \
   -output "$ROOT/$FRAMEWORK_NAME.xcframework"

# Entre no diretório temporariamente
cd "$ROOT"

# # Crie o arquivo zip
zip -rX "$NAME" "$FRAMEWORK_NAME.xcframework/"
mv "$NAME" "$ORIGIN"
cd "$ORIGIN"

# Upload Version in Github
SUM=$(swift package compute-checksum ${NAME} )
BUILD=$(date +%s) 
NEW_VERSION=${VERSION}.${BUILD}
echo $NEW_VERSION > version

git add version
git commit -m "new Version ${NEW_VERSION}"
git tag -s -a ${NEW_VERSION} -m "v${NEW_VERSION}"
# git checkout -b release-v${VERSION}
git push origin HEAD --tags
gh release create ${NEW_VERSION} ${NAME} --notes "checksum \`${SUM}\`"

URL=$(gh release view ${NEW_VERSION} \
  --repo exception7601/PhotoBrowser \
  --json assets \
  -q '.assets[0].apiUrl'
)

NOTES=$(cat <<END
SPM binaryTarget

\`\`\`
.binaryTarget(
  name: "NYTPhotoViewer",
  url: "${URL}.zip",
  checksum: "${SUM}"
)
\`\`\`
END
)

gh release edit ${NEW_VERSION} --notes  "${NOTES}"
echo "${NOTES}"

