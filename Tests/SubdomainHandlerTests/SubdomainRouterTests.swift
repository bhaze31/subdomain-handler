//
//  SubdomainRouterTests.swift
//
//
//  Created by Brian Hasenstab on 9/11/24.
//

import XCTest
@testable import SubdomainHandler

final class SubdomainRouterTests: XCTestCase {
  func testFetchingDomainList() throws {
    let router = SubdomainHandler()
    
    let _ = try router.insertSubdomain(subdomain: "omega.beta.alpha")
    let _ = try router.insertSubdomain(subdomain: "beta.alpha")
    let _ = try router.insertSubdomain(subdomain: "*.alpha")
    let _ = try router.insertSubdomain(subdomain: "zulu.alpha")
    let _ = try router.insertSubdomain(subdomain: "zulu.omega.beta.alpha")
    let _ = try router.insertSubdomain(subdomain: "app")
    let _ = try router.insertSubdomain(subdomain: "zulu.beta")
    
    let domains = router.fetchSubdomains()
    
    XCTAssertEqual(domains.count, 7, "Should contain 5 domains")
    
    XCTAssertIncludes(domains, "zulu.omega.beta.alpha")
    XCTAssertIncludes(domains, "omega.beta.alpha")
    XCTAssertIncludes(domains, "beta.alpha")
    XCTAssertIncludes(domains, "*.alpha")
    XCTAssertIncludes(domains, "zulu.alpha")
    XCTAssertIncludes(domains, "app")
    XCTAssertIncludes(domains, "zulu.beta")
  }
  
  func testResolvingWildcardDomains() throws {
    let router = SubdomainHandler()
    
    let _ = try router.insertSubdomain(subdomain: "omega.beta.alpha")
    let _ = try router.insertSubdomain(subdomain: "beta.alpha")
    let _ = try router.insertSubdomain(subdomain: "*.alpha")
    let _ = try router.insertSubdomain(subdomain: "*")
    
    var result = router.buildSubdomainForResponders(subdomain: "charlie.alpha")
    
    XCTAssertEqual("*.alpha", result)
    
    result = router.buildSubdomainForResponders(subdomain: "omega")
    
    XCTAssertEqual("*", result)
  }
}

func XCTAssertIncludes<T: Equatable & Hashable>(_ collection: Array<T>, _ item: T, message: String? = nil) {
  if collection.contains(item) {
    XCTAssert(true)
  } else {
    XCTFail(message ?? "Item not found in collection")
  }
}
