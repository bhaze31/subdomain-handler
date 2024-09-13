//
//  SubdomainHandlerTests.swift
//
//
//  Created by Brian Hasenstab on 9/11/24.
//

import XCTest
@testable import SubdomainHandler

final class SubdomainHandlerTests: XCTestCase {
  func testSingularCase() async throws {
    let handler = SubdomainHandler()
    let _ = try handler.insertSubdomain(subdomain: "app")
    
    XCTAssertNotNil(handler.nodes["app"])
    
    XCTAssertNotNil(handler.nodes["app"]?.router)
  }
  
  func testThreeDepthCase() async throws {
    let handler = SubdomainHandler()
    
    let _ = try handler.insertSubdomain(subdomain: "omega.beta.alpha")
    
    XCTAssertNotNil(handler.nodes["alpha"])
    
    let alphaNode = handler.nodes["alpha"]!
    
    XCTAssertNil(alphaNode.router)
    
    let betaNode = alphaNode.children["beta"]!
    
    XCTAssertNil(betaNode.router)
    
    let omegaNode = betaNode.children["omega"]!
    
    XCTAssertNotNil(omegaNode.router)
  }
  
  func testMultipleSubdomainHandlers() async throws {
    let handler = SubdomainHandler()
    
    let _ = try handler.insertSubdomain(subdomain: "omega.beta.alpha")
    let _ = try handler.insertSubdomain(subdomain: "zulu.alpha")
    
    XCTAssertNotNil(handler.nodes["alpha"])
    
    let alphaNode = handler.nodes["alpha"]!
    
    XCTAssertNil(alphaNode.router)
    
    XCTAssert(alphaNode.children.keys.count == 2)
    
    let betaNode = alphaNode.children["beta"]!
    
    XCTAssertNil(betaNode.router)
    
    let omegaNode = betaNode.children["omega"]!
    
    XCTAssertNotNil(omegaNode.router)
    
    let zuluNode = alphaNode.children["zulu"]!
    
    XCTAssertNotNil(zuluNode.router)
  }
  
  func testWildCardInsertionAtRoot() async throws {
    let handler = SubdomainHandler()
    
    let _ = try handler.insertSubdomain(subdomain: "*")
    
    XCTAssertNotNil(handler.fetchSubdomainNode(subdomain: "alpha"))
    XCTAssertNotNil(handler.fetchSubdomainNode(subdomain: "beta"))
    XCTAssertNotNil(handler.fetchSubdomainNode(subdomain: "omega"))
  }
  
  func testWildCardInsertion() async throws {
    let handler = SubdomainHandler()
    
    XCTAssertThrowsError(try handler.insertSubdomain(subdomain: "beta.*.alpha"))
    XCTAssertThrowsError(try handler.insertSubdomain(subdomain: "*.*.alpha"))
  }
  
  func testReinsertingNodeFails() {
    let handler = SubdomainHandler()
    
    XCTAssertNoThrow(try handler.insertSubdomain(subdomain: "beta.alpha"))
    XCTAssertThrowsError(try handler.insertSubdomain(subdomain: "beta.alpha"))
  }
  
  func testFetchingSubdomains() async throws {
    let handler = SubdomainHandler()
    
    let _ = try handler.insertSubdomain(subdomain: "omega.beta.alpha")
    let _ = try handler.insertSubdomain(subdomain: "beta.alpha")
    let _ = try handler.insertSubdomain(subdomain: "*.alpha")
    let _ = try handler.insertSubdomain(subdomain: "zulu.alpha")
    let _ = try handler.insertSubdomain(subdomain: "app")
    let _ = try handler.insertSubdomain(subdomain: "zulu.beta")
    
    XCTAssertNotNil(handler.fetchSubdomainNode(subdomain: "omega.beta.alpha"))
    XCTAssertNotNil(handler.fetchSubdomainNode(subdomain: "beta.alpha"))
    XCTAssertNotNil(handler.fetchSubdomainNode(subdomain: "wildcard.alpha"))
    XCTAssertNotNil(handler.fetchSubdomainNode(subdomain: "zulu.alpha"))
    XCTAssertNotNil(handler.fetchSubdomainNode(subdomain: "app"))
    XCTAssertNotNil(handler.fetchSubdomainNode(subdomain: "zulu.beta"))
    
    XCTAssertNil(handler.fetchSubdomainNode(subdomain: "zulu.beta.alpha"))
    XCTAssertNil(handler.fetchSubdomainNode(subdomain: "alpha"))
  }
  
  func testHandleRequest() async throws {
    let handler = SubdomainHandler()
    
    let node = try handler.insertSubdomain(subdomain: "beta.alpha")
    
    try node.router!.routes.register(collection: TestController1())
    
    let node2 = try handler.insertSubdomain(subdomain: "omega.alpha")
    
    try node2.router!.routes.register(collection: TestController2())
    
    handler.enableRouters(app: app)

    var responder = handler.handleRequest(request: getRequest)
    
    XCTAssertNotNil(responder)
    
    var result = try await responder!.respond(to: getRequest).get()
    var body = try result.content.decode(String.self)
    
    XCTAssertEqual("TestController1 - Get", body)
    
    responder = handler.handleRequest(request: controlller2Request)
    
    result = try await responder!.respond(to: getRequest).get()
    body = try result.content.decode(String.self)
    
    XCTAssertEqual("TestController2 - Get", body)
    
    XCTAssertNil(handler.handleRequest(request: badRequest))
  }
  
  func testDefaultRoutes() async throws {
    let handler = SubdomainHandler()
    
    let node = try handler.insertSubdomain(subdomain: "beta.alpha")
    
    try node.router!.routes.register(collection: TestController1())
    
    handler.enableRouters(app: app)
    
    XCTAssertNil(handler.handleRequest(request: wwwRequest))
    XCTAssertNil(handler.handleRequest(request: baseRequest))
  }
  
  func testMaxDepth() async throws {
    let handler = SubdomainHandler()
    
    XCTAssertThrowsError(try handler.insertSubdomain(subdomain: "zulu.omega.alpha.beta"))
  }
  
}
