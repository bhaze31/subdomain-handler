//
//  SubdomainNode.swift
//
//
//  Created by Brian Hasenstab on 9/11/24.
//

import Foundation
import Vapor


/// A node representing part of a subdomain route
///
/// Each part of a subdomain is represented by an individual node. For example, if the subdomain
/// omega.beta.alpha is added, there would be three nodes, representing omega, beta, and alpha each.
/// The node alpha would be the top node, having beta as a child node, and respectively beta having omega
/// as a terminus node. The omega node would then have specific route handlers that would only be
/// called if the domain was omega.beta.alpha.yourdomain.tld.
///
/// The routes should be resolved from the final subdomain router
/// We should organize it in reverse order by node, and then assign a subdomain router at that node
/// So for example if we have three subdomains of \*.app, app, and beta.app the nodes should then appear as
/// - app:
///   - router: SubdomainRouter
///   - hasWildcard: true
///   - nodes:
///     - beta:
///       - router: SubdomainRouter
///       - nodes: [:]
///     - \*:
///       - router: SubdomainRouter
///       - nodes: [:]
///
/// If a wildcard node was added as a child of a parent node, that parent will have `hasWildcard` marked as true so
/// that it knows how to handle requests that come through but don't explicitly match a child subdomain. Wildcards can only
/// exist as the top level domain, so registering \*.beta.alpha is valid, but omega.\*.alpha is not.
///
/// Each node may have a number of children used to continue navigating down to a different subdomain
///
/// - Parameters:
///   - subdomain: The part of the subdomain that the node is registered for
///
public final class SubdomainNode {
  private var subdomain: String
  
  public var router: SubdomainRouter?
  
  internal var hasWildcard: Bool

  internal var children: [String: SubdomainNode]
  
  public init(subdomain: String) {
    self.subdomain = subdomain
    self.children = [:]
    self.hasWildcard = false
  }
  
  public func enableRouter(app: Application) {
    if let router {
      router.register(app: app, userInfo: ["subdomain": subdomain])
    }
    
    for node in children.values {
      node.enableRouter(app: app)
    }
  }
}
