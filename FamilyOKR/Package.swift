// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FamilyOKR",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "FamilyOKR",
            targets: ["FamilyOKR"]
        )
    ],
    targets: [
        .target(
            name: "FamilyOKR",
            path: "FamilyOKR"
        )
    ]
)
