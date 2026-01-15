// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SocraticJournal",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SocraticJournal",
            targets: ["SocraticJournal"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0")
    ],
    targets: [
        .target(
            name: "SocraticJournal",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk")
            ],
            path: "Sources/SocraticJournal",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SocraticJournalTests",
            dependencies: ["SocraticJournal"],
            path: "Tests/SocraticJournalTests"
        )
    ]
)
