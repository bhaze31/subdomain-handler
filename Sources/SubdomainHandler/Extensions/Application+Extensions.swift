//
//  Application+Extensions.swift
//
//
//  Created by Brian Hasenstab on 9/11/24.
//

import Foundation
import Vapor


extension Application {
  public var subdomainHandler: SubdomainHandler {
    get {
      if let router = self.storage[SubdomainHandlerKey.self] {
        return router
      }
      
      let router = SubdomainHandler()
      
      self.storage[SubdomainHandlerKey.self] = router
      
      return router
    }
    set {
      self.storage[SubdomainHandlerKey.self] = newValue
    }
  }
  
  public func createSubdomain(subdomain: String) throws -> SubdomainNode {
    return try subdomainHandler.insertSubdomain(subdomain: subdomain)
  }
  
  public func register(collection: RouteCollection, at subdomain: String) throws {
    if let router = subdomainHandler.fetchSubdomainNode(subdomain: subdomain)?.router {
      // We only receive nodes when there is an existing router attached, so if we found
      // the subdomain node then the router will exist
      try router.routes.register(collection: collection)
    } else {
      // If we are here, we know that the router will exist, since we just registered it
      let node = try createSubdomain(subdomain: subdomain)
      try node.router!.routes.register(collection: collection)
    }
  }
}
