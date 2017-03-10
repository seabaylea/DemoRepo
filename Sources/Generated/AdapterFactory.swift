import Foundation
import Configuration
import CloudFoundryConfig
import CouchDB

public class AdapterFactory {
    let manager: ConfigurationManager

    init(manager: ConfigurationManager) {
        self.manager = manager
    }

    public func getTodoAdapter() throws -> TodoAdapter {
      let service = try manager.getCloudantService(name: "cloudantCrudService")
      return TodoCloudantAdapter(ConnectionProperties(
          host:     service.host,
          port:     Int16(service.port),
          secured:  true, // FIXME Fix CloudConfiguration
          username: service.username,
          password: service.password
      ))
    }

}
