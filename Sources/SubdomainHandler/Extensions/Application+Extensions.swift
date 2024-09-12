//
//  Application+Extensions.swift
//
//
//  Created by Brian Hasenstab on 9/11/24.
//

import Foundation
import Vapor


extension Application {
  public var subdomainRouter: SubdomainHandler {
    get {
      if let router = self.storage[SubdomainRouterKey.self] {
        return router
      }
      
      let router = SubdomainHandler()
      
      self.storage[SubdomainRouterKey.self] = router
      
      return router
    }
    set {
      self.storage[SubdomainRouterKey.self] = newValue
    }
  }
  
  public var subdomains: [String] {
    return subdomainRouter.fetchSubdomains()
  }
  
  public func createSubdomain(subdomain: String) throws -> SubdomainNode {
    return try subdomainRouter.insertSubdomain(subdomain: subdomain)
  }
}
