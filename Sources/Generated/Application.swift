import Foundation
import Kitura
import LoggerAPI
import Configuration
import KituraNet
import SwiftyJSON

import SwiftMetrics
import SwiftMetricsDash
import SwiftMetricsBluemix

import CouchDB

public let router = Router()
public let manager = ConfigurationManager()
public var port: Int = 8080


// Set up the cloudant
internal var database: Database?

public func initialize() throws {

    func executableURL() -> URL? {
        var executableURL = Bundle.main.executableURL
        #if os(Linux)
            if (executableURL == nil) {
                executableURL = URL(fileURLWithPath: "/proc/self/exe").resolvingSymlinksInPath()
            }
        #endif
            return executableURL
    }

    func findProjectRoot(fromDir initialSearchDir: URL) -> URL? {
        let fileManager = FileManager()
        var searchDirectory = initialSearchDir
        while searchDirectory.path != "/" {
            let projectFilePath = searchDirectory.appendingPathComponent(".swiftservergenerator-project").path
            if fileManager.fileExists(atPath: projectFilePath) {
                return searchDirectory
            }
            searchDirectory.deleteLastPathComponent()
        }
        return nil
    }

    guard let searchDir = executableURL()?.deletingLastPathComponent(),
          let projectRoot = findProjectRoot(fromDir: searchDir) else {
        Log.error("Cannot find project root")
        exit(1)
    }

    manager.load(file: projectRoot.appendingPathComponent("config.json").path)
                .load(.environmentVariables)

    let sm = try SwiftMetrics()
let _ = try SwiftMetricsDash(swiftMetricsInstance : sm, endpoint: router)

    let _ = AutoScalar(swiftMetricsInstance: sm)



    // Configuring cloudant
    let cloudantService = try manager.getCloudantService(name: "cloudantCrudService")
let dbClient = CouchDBClient(service: cloudantService)


    let factory = AdapterFactory(manager: manager)

// Host swagger definition
router.get("/explorer/swagger.yml") { request, response, next in
    // TODO(tunniclm): Should probably just pass the root into init()
    let swaggerFileURL = projectRoot.appendingPathComponent("definitions/demos.yaml")
    do {
        try response.send(fileName: swaggerFileURL.path).end()
    } catch {
        Log.error("Failed to serve OpenAPI Swagger definition from \(swaggerFileURL.path)")
    }
}

try TodoResource(factory: factory).setupRoutes(router: router)

}

public func run() throws {
    Kitura.addHTTPServer(onPort: port, with: router)
    Kitura.run()
}
