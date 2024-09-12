//
//  SubdomainHandler.swift
//
//
//  Created by Brian Hasenstab on 9/11/24.
//


import Foundation
import Vapor

public final class SubdomainHandler: @unchecked Sendable {
  public var nodes: [String: SubdomainNode]
  
  public var catchAll: SubdomainNode?
  
  public init() {
    self.nodes = [:]
  }
  
  // MARK: Inserting Subdomains
  
  struct NotFoundError: Error {}
  
  public func insertSubdomain(subdomain: String) throws -> SubdomainNode {
    var parts = subdomain.split(separator: ".").map { String($0) }
    
    if let root = parts.popLast() {
      if let node = nodes[root] {
        return try traverseNodeInsertion(node: node, remainingParts: &parts)
      } else {
        // Create a node, set it, and traverse
        let node = SubdomainNode(subdomain: root)
        
        // We are creating a wildcard route at the root, which means any
        if root == "*" {
          self.catchAll = node
        }
        
        nodes[root] = node
        
        return try traverseNodeInsertion(node: node, remainingParts: &parts)
      }
    } else {
      throw NodeInsertionError()
    }
  }
  
  struct NodeInsertionError: Error {}
  
  private func traverseNodeInsertion(node: SubdomainNode, remainingParts: inout [String]) throws -> SubdomainNode {
    if let nextPath = remainingParts.popLast() {
      if let existingNode = node.children[nextPath] {
        return try traverseNodeInsertion(node: existingNode, remainingParts: &remainingParts)
      } else {
        let nextNode = SubdomainNode(subdomain: nextPath)
        
        if nextPath == "*" {
          node.hasWildcard = true
        }
        
        node.children[nextPath] = nextNode
        
        return try traverseNodeInsertion(node: nextNode, remainingParts: &remainingParts)
      }
      // Else, create one and continue
    } else {
      // We have reached the bottom, check if this node has a router, and if so raise
      if node.routes != nil {
        // It has existing routes, throw an error
        throw NodeInsertionError()
        
      } else {
        node.routes = Routes()
        
        return node
      }
    }
  }
  
  // MARK: Fetching Subdomains
  public func fetchSubdomainRouteCollection(subdomain: String) -> SubdomainNode? {
    var parts = subdomain.split(separator: ".").map { String($0) }
    
    var node: SubdomainNode?
    
    guard let root = parts.popLast() else { return node }
    
    if let current = nodes[root] {
      node = current.fetchNode(parts: &parts)
    } else if root == "*" && catchAll != nil {
      // We have a wildcard,
      node = catchAll?.fetchNode(parts: &parts)
    }
    
    return node
  }
  
  public func fetchSubdomains() -> [String] {
    var domains: [String] = []
    
    for node in nodes.values {
      domains += node.gatherSubnodes()
    }
    
    return domains
  }
  
  func buildSubdomainForResponders(subdomain: String) -> String? {
    var parts = subdomain.split(separator: ".").map { String($0) }
    
    var node: SubdomainNode
    
    guard let root = parts.popLast() else {
      return subdomain
    }
    
    var constructed: [String] = []
    
    if let rootNode = nodes[root] {
      node = rootNode
      constructed.append(root)
    } else if let catchAll  {
      node = catchAll
      constructed.append("*")
    } else {
      return nil
    }
    
    while !parts.isEmpty {
      guard let nextPart = parts.popLast() else {
        continue
      }
      
      if let nextNode = node.children[nextPart] {
        constructed.append(nextPart)
        node = nextNode
      } else if node.hasWildcard, let wildCardNode = node.children["*"] {
        constructed.append("*")
        node = wildCardNode
      } else {
        return nil
      }
    }
    
    return Array(constructed.reversed()).joined(separator: ".")
  }
  
  func fetchSubdomainNode(subdomain: inout [String]) -> SubdomainNode? {
    
    return nil
  }
  
  public func handleRequest(request: Request) -> Responder? {
    if let host = request.headers["host"].first {
      let parts = host.split(separator: ".").map { String($0) }
      
      // If we have something like mydomain.io, we have no subdomain, therefore don't return a repsonder
      if parts.count <= 2 {
        return nil
      }
      
      // If we have something like www.mydomain.io, we want to treat it with the default subdomain
      if parts.count == 3 && parts[0] == "www" {
        return nil
      }
      
      // We have a valid subdomain, attempt to retrieve a SubdomainRoute
      // This will grab the remaing subdomain, for example if we beta.app.mydomain.io
      // the subdomain will be ["beta", "app"]
      var subdomain = Array(parts[0..<parts.count - 2])
      if let subdomainRoute = fetchSubdomainNode(subdomain: &subdomain)?.route {
        if let route = subdomainRoute.respondsToRequest(request: request) {
          return route.responder
        }
      }
    }
    
    return nil
  }
}


public struct SubdomainRouterKey: StorageKey {
  public typealias Value = SubdomainHandler
}

