//
//  SubdomainHandler.swift
//
//
//  Created by Brian Hasenstab on 9/11/24.
//


import Foundation
import Vapor

public final class SubdomainHandler: @unchecked Sendable {
  internal var nodes: [String: SubdomainNode]
  
  internal var catchAll: SubdomainNode?

  internal init() {
    self.nodes = [:]
  }
  
  // MARK: Inserting Subdomains
  
  struct NotFoundError: Error {}
  
  public func insertSubdomain(subdomain: String) throws -> SubdomainNode {
    var parts = subdomain.split(separator: ".").map { String($0) }
    
    // Limit the depth of the subdomain to be max of 3
    if parts.count > 3 {
      throw NodeInsertionError(message: "Subdomain must be 3 or less parts")
    }
    
    if parts.contains("*") {
      // We have a wildcard somewhere, it must be top level only
      if parts.filter({ $0 == "*" }).count != 1 {
        throw NodeInsertionError(message: "Wildcard must only appear one time")
      }
      
      if parts[0] != "*" {
        throw NodeInsertionError(message: "Wildcard must only appear at the apex domain")
      }
    }

    let root = parts.popLast()!
    
    if let node = nodes[root] {
      return try traverseNodeInsertion(node: node, remainingParts: &parts)
    } else {
      // Create a node, set it, and traverse
      let node = SubdomainNode(subdomain: root)
      
      // We are creating a wildcard route at the root
      if root == "*" {
        self.catchAll = node
      }
      
      nodes[root] = node
      
      return try traverseNodeInsertion(node: node, remainingParts: &parts)
    }
  }
  
  struct NodeInsertionError: Error {
    var message: String
  }
  
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
      if node.router != nil {
        // It has existing routes, throw an error
        throw NodeInsertionError(message: "Terminus route already exists, exiting")
        
      } else {
        node.router = SubdomainRouter()
        
        return node
      }
    }
  }
  
  // MARK: Enabling routers

  public func enableRouters(app: Application)  {
    for node in nodes.values {
      node.enableRouter(app: app)
    }
  }

  public func fetchSubdomainNode(subdomain: String) -> SubdomainNode? {
    var parts = subdomain.split(separator: ".").map { String($0) }
    
    var currentNode: SubdomainNode
    
    let root = parts.popLast()!
    
    if let rootNode = nodes[root] {
      currentNode = rootNode
    } else if let catchAll  {
      currentNode = catchAll
    } else {
      return nil
    }
    
    while !parts.isEmpty {
      let nextPart = parts.popLast()!
      
      if let nextNode = currentNode.children[nextPart] {
        currentNode = nextNode
      } else if currentNode.hasWildcard, let wildCardNode = currentNode.children["*"] {
        currentNode = wildCardNode
      } else {
        return nil
      }
    }
    
    if currentNode.router != nil {
      return currentNode
    }

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
      let subdomain = Array(parts[0..<parts.count - 2]).joined(separator: ".")

      if let subdomainRouter = fetchSubdomainNode(subdomain: subdomain)?.router {
        if let route = subdomainRouter.respondsToRequest(request: request) {
          return route.responder
        }
      }
    }
    
    return nil
  }
}


public struct SubdomainHandlerKey: StorageKey {
  public typealias Value = SubdomainHandler
}

