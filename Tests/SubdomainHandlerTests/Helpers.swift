import XCTest
@testable import SubdomainHandler
import Vapor

let app = Application()

let wwwRequest = Request(
  application: app,
  method: .GET,
  url: "/demo/path",
  version: .http1_1,
  headers: [
    "host": "www.mydomain.tld"
  ],
  logger: app.logger,
  byteBufferAllocator: app.client.byteBufferAllocator,
  on: app.eventLoopGroup.any()
)

let baseRequest = Request(
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

let badRequest = Request(
  application: app,
  method: .GET,
  url: "/bad/path",
  version: .http1_1,
  headers: [
    "host": "beta.alpha.mydomain.tld"
  ],
  logger: app.logger,
  byteBufferAllocator: app.client.byteBufferAllocator,
  on: app.eventLoopGroup.any()
)

let controlller2Request = Request(
  application: app,
  method: .GET,
  url: "/demo/path",
  version: .http1_1,
  headers: [
    "host": "omega.alpha.mydomain.tld"
  ],
  logger: app.logger,
  byteBufferAllocator: app.client.byteBufferAllocator,
  on: app.eventLoopGroup.any()
)

final class TestController1: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    routes.get("demo", "path") { request -> String in return "TestController1 - Get" }
  }
}

final class TestController2: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    routes.get("demo", "path") { request -> String in return "TestController2 - Get" }
  }
}
