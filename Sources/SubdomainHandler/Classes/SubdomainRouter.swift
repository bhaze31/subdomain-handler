//
//  SubdomainRouter.swift
//  
//
//  Created by Brian Hasenstab on 9/12/24.
//

import Foundation
import Vapor

public final class SubdomainRouter {
  struct CachedRoute {
    var route: Route
    var responder: Responder
  }

  public var routes = Routes()
  
  var trieRouter = TrieRouter(CachedRoute.self)
  
  public func register(app: Application, userInfo: [AnySendableHashable: Sendable]? = nil) {
    let middleware = app.middleware.resolve()
    
    for route in routes.all {
      if let userInfo {
        route.userInfo.merge(userInfo, uniquingKeysWith: { (first, _) in first })
      }
      
      let cached = CachedRoute(
        route: route,
        responder: middleware.makeResponder(chainingTo: route.responder)
      )
      
      let path = route.path.filter { component in
        switch component {
          case .constant(let string):
            return string != ""
          default:
            return true
        }
      }
      
      trieRouter.register(cached, at: [.constant(route.method.string)] + path)
    }
  }
  
  public func respondsToRequest(request: Request) -> Route? {
    let pathComponents = request.url.path.split(separator: "/").map(String.init)
    
    if let route = trieRouter.route(path: [request.method.string] + pathComponents, parameters: &request.parameters)?.route {
      return route
    } else {
      return nil
    }
  }
}
