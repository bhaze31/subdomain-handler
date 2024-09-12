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
    let router = SubdomainHandler()
    let _ = try router.insertSubdomain(subdomain: "app")
    
    XCTAssertNotNil(router.nodes["app"], "Should have had node created")
    
    XCTAssertNotNil(router.nodes["app"]?.routes, "Terminus node should have a router")
  }
  
  func testThreeDepthCase() async throws {
    let router = SubdomainHandler()
    
    let _ = try router.insertSubdomain(subdomain: "omega.beta.alpha")
    
    XCTAssertNotNil(router.nodes["alpha"])
    
    guard let alphaNode = router.nodes["alpha"] else {
      XCTFail("Could not retrieve node from the router")
      return
    }
    
    XCTAssertNil(alphaNode.routes, "There should be no router since this is not the final handler")
    
    guard let betaNode = alphaNode.children["beta"] else {
      XCTFail("Could not retrieve beta node from parent")
      return
    }
    
    XCTAssertNil(alphaNode.routes, "There should be no router since this is not the final handler")
    
    guard let omegaNode = betaNode.children["omega"] else {
      XCTFail("Could not retrieve omega node from parent")
      return
    }
    
    XCTAssertNotNil(omegaNode.routes, "This should have a router set since it is the last router")
  }
  
  func testMultipleSubdomainHandlers() async throws {
    let router = SubdomainHandler()
    
    let _ = try router.insertSubdomain(subdomain: "omega.beta.alpha")
    let _ = try router.insertSubdomain(subdomain: "zulu.alpha")
    
    XCTAssertNotNil(router.nodes["alpha"])
    
    guard let alphaNode = router.nodes["alpha"] else {
      XCTFail("Could not retrieve node from the router")
      return
    }
    
    XCTAssertNil(alphaNode.routes, "There should be no router since this is not the final handler")
    
    XCTAssert(alphaNode.children.keys.count == 2, "We should have appened zulu to the alpha node children")
    
    guard let betaNode = alphaNode.children["beta"] else {
      XCTFail("Could not retrieve beta node from parent")
      return
    }
    
    XCTAssertNil(alphaNode.routes, "There should be no router since this is not the final handler")
    
    guard let omegaNode = betaNode.children["omega"] else {
      XCTFail("Could not retrieve omega node from parent")
      return
    }
    
    XCTAssertNotNil(omegaNode.routes, "This should have a router set since it is the last router")
    
    guard let zuluNode = alphaNode.children["zulu"] else {
      XCTFail("Could not retrieve zulu node from parent")
      return
    }
    
    XCTAssertNotNil(zuluNode.routes, "This should have a router set since it is the last router")
  }
  
  func testWildCardInsertionAtRoot() async throws {
    
  }
  
  func testWildCardInsertion() async throws {
    
  }
}
