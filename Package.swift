import PackageDescription

let package = Package(
    name: "demos",
    targets: [
      Target(name: "demos", dependencies: [ .Target(name: "Generated") ])
    ],
    dependencies: [

        .Package(url: "https://github.com/IBM-Swift/CloudConfiguration.git", majorVersion: 1),
        .Package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git",  majorVersion: 1),

        .Package(url: "https://github.com/RuntimeTools/SwiftMetrics.git", majorVersion: 0),

        


        .Package(url: "https://github.com/IBM-Swift/Kitura.git",                 majorVersion: 1),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git",           majorVersion: 1)
    ],
    exclude: []
)
