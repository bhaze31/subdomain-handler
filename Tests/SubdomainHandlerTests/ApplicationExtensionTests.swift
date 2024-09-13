//
//  ApplicationExtensionTests.swift
//
//
//  Created by Brian Hasenstab on 9/12/24.
//

import Foundation
import XCTest
@testable import SubdomainHandler

final class ApplicationExtensionTests: XCTestCase {
  func testRegister() throws {
    try app.register(collection: TestController1(), at: "beta.alpha")
    try app.register(collection: TestController2(), at: "beta.alpha")
    
    app.enableSubdomainRouters()
    
    XCTAssertNotNil(app.handleRequest(request: getRequest))
  }
}
