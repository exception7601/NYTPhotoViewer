// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "NYTPhotoViewer",
  platforms: [.iOS(.v12)],
  products: [
    .library(
      name: "NYTPhotoViewer",
      targets: [
        "NYTPhotoViewer",
      ]
    ),
  ],

  targets: [
    .binaryTarget(
      name: "NYTPhotoViewer",
      url: "https://github.com/exception7601/NYTPhotoViewer/releases/download/5.0.8.1758562923/NYTPhotoViewer.adfc4df767980aa0.zip",
      checksum: "659eccef7a567ada72cba9ea8f801c748b24dc25389e5a81ab3014748a7b73fb"
    )
  ]
)
