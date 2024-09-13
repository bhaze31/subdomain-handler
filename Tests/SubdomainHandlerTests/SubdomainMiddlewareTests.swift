//
//  File.swift
//  
//
//  Created by Brian Hasenstab on 9/12/24.
//

import XCTest
@testable import SubdomainHandler
import Vapor

final class SubdomainMiddlewareTests: XCTestCase {
  func testHandlesSubdomains() async throws {
    let app = Application()

    try app.register(collection: TestController1(), at: "beta.alpha")
    try app.register(collection: TestController2())

    app.enableSubdomainRouters()
    
    let middleware = SubdomainMiddleware(app: app)
    
    let getRequest = Request(
      application: app,
      method: .GET,
      url: "/demo/path",
      version: .http1_1,
      headers: [
        "host": "beta.alpha.mydomain.tld"
      ],
      logger: app.logger,
      byteBufferAllocator: app.client.byteBufferAllocator,
      on: app.eventLoopGroup.any()
    )
    
    let defaultRequest = Request(
      application: app,
      method: .GET,
      url: "/demo/path",
      version: .http1_1,
      headers: [
        "host": "mydomain.tld"
      ],
      logger: app.logger,
      byteBufferAllocator: app.client.byteBufferAllocator,
      on: app.eventLoopGroup.any()
    )
    
    var result = try await middleware.respond(to: getRequest, chainingTo: app.responder).get()
    var body = try result.content.decode(String.self)
    
    XCTAssertEqual(body, "TestController1 - Get")
    
    result = try await middleware.respond(to: defaultRequest, chainingTo: app.responder).get()
    body = try result.content.decode(String.self)
    
    XCTAssertEqual(body, "TestController2 - Get")
  }
}
