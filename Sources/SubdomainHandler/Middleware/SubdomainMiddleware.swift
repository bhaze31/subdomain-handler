//
//  SubdomainMiddleware.swift
//
//
//  Created by Brian Hasenstab on 9/11/24.
//

import Foundation
import Vapor

public final class SubdomainMiddleware: AsyncMiddleware, @unchecked Sendable {
  public init(app: Application) {
    app.subdomainHandler.enableRouters(app: app)
  }

  public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
    if let responder = request.application.subdomainHandler.handleRequest(request: request) {
      return try await responder.respond(to: request).get()
    }
    
    return try await next.respond(to: request)
  }
}
