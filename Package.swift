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
    dependencies: [],
    targets: [
        .target(
            name: "SocraticJournal",
            dependencies: [],
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
