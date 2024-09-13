import Vapor
import SubdomainHandler

public func configure(_ app: Application) async throws {
  app.http.server.configuration.port = 7070
  
  
  
  app.middleware.use(SubdomainMiddleware(app: app))
}
