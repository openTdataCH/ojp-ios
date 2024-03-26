#!/bin/sh

## Notes
## - docc-plugin doesn't support iOS libraries
## - Github Actions will be used to build and deploy the documentation: 
##   see examples: https://github.com/x-0o0/package-docc-example/blob/main/README_ENG.md#set-deployment-condition-to-github-actions

mkdir -p docs

# xcodebuild docbuild -scheme OJP \
#   -derivedDataPath ./.build/docs \
#   -destination 'generic/platform=iOS' \
#   OTHER_DOCC_FLAGS="--transform-for-static-hosting --hosting-base-path ojp-ios --output-path ./docs" ## -> somehow having a dash in the value for hosting-base-path breaks this. didn' find a way to escape it

xcodebuild docbuild -scheme OJP \
  -derivedDataPath ./.build/docs \
  -destination 'generic/platform=iOS';
$(xcrun --find docc) process-archive \
  transform-for-static-hosting ./.build/docs/Build/Products/Debug-iphoneos/OJP.doccarchive \
  --hosting-base-path ojp-ios \
  --output-path docs; # export to the path: docs
