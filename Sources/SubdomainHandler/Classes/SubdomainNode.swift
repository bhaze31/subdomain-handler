//
//  SubdomainNode.swift
//
//
//  Created by Brian Hasenstab on 9/11/24.
//

import Foundation
import Vapor

// The routes should be resolved from the final subdomain router
// We should organize it in reverse order by node, and then assign a subdomain router at that node
// So for example if we have three subdomains of *.app, app, and beta.app the nodes should then appear as
// app:
//   routes: Routes
//   hasWildcard: true
//   nodes:
//     beta:
//       routes: Routes
//       nodes: []
//     *:
//       routes: Routes
//       nodes: []
//
// The wildcard should be denoted at the level above the wildcard, so that it can properly resolve.
//
// We should also store the items in a hash so that they are easy to look up. We also should raise
//   if we get an existing match with an item


public final class SubdomainNode {
  struct CachedRoute {
    let route: Route
    let responder: Responder
  }

  public var subdomain: String
  public var routes: Routes?
  
  public var route: SubdomainRouter?
  
  public var hasWildcard: Bool
  
  var router: TrieRouter<CachedRoute> = TrieRouter()

  public var children: [String: SubdomainNode]
  
  public init(subdomain: String) {
    self.subdomain = subdomain
    self.children = [:]
    self.hasWildcard = false
  }
  
  // Say we have omega.beta.alpha, zulu.alpha, and *.alpha
  // When we return at the base, we get returns of:
  // [omega], [zulu], and [*]
  // then, we need to combine with the parents, and return that array:
  // [omega.beta], [zulu.alpha, *.alpha], which then recursively becomes
  // [omega.beta.alpha, zulu.alpha, *.alpha]
  
  func gatherSubnodes() -> [String] {
    if children.isEmpty {
      // We have reached the base node, return itself
      return [subdomain]
    }
    
    var domains: [String] = []
    
    if routes != nil {
      domains.append(subdomain)
    }
    
    for node in children.values {
      for element in node.gatherSubnodes() {
        domains.append([element, subdomain].joined(separator: "."))
      }
    }
    
    return domains
  }
  
  public func fetchNode(parts: inout [String]) -> SubdomainNode? {
    guard let nextPart = parts.popLast() else { return self }
    
    if let nextNode = children[nextPart] {
      return nextNode.fetchNode(parts: &parts)
    }
    
    if hasWildcard {
      if let wildcard = children["*"] {
        return wildcard.fetchNode(parts: &parts)
      }
    }
    
    return nil
  }
}
