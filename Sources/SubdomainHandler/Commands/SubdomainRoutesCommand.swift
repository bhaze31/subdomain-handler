//
//  SubdomainRoutesCommand.swift
//
//
//  Created by Brian Hasenstab on 9/11/24.
//

import Foundation
import ConsoleKit
import RoutingKit

/// Displays all routes registered to the `Application`'s `Router` in an ASCII-formatted table.
///
///     $ swift run Run routes
///     +------+------------------+---------+
///     | GET  | /search          | \*.app  |
///     +------+------------------+---------|
///     | GET  | /hash/:string    | default |
///     +------+------------------+---------+
///
/// A colon preceding a path component indicates a variable parameter. A colon with no text following
/// is a parameter whose result will be discarded.
///
/// The path will be displayed with the same syntax that is used to register a route.
public final class SubdomainRoutesCommand: AsyncCommand {
  public struct Signature: CommandSignature {
    public init() { }
  }
  
  public var help: String {
    return "Displays all registered routes and their subdomains."
  }
  
  init() { }
  
  public func run(using context: ConsoleKitCommands.CommandContext, signature: Signature) async throws {
    //    let routes = context.application.routes
    //
    //    let includeDescription = !routes.all.filter { $0.userInfo["description"] != nil }.isEmpty
    //
    //    let pathSeparator = "/".consoleText()
    
    //    let defaultTable = routes.all.map { route -> [ConsoleText] in
    //      var column = [route.method.string.consoleText()]
    //      if route.path.isEmpty {
    //        column.append(pathSeparator)
    //      } else {
    //        column.append(route.path
    //          .map { pathSeparator + $0.consoleText() }
    //          .reduce("".consoleText(), +)
    //        )
    //      }
    //
    //      column.append("default")
    //
    //      if includeDescription {
    //        let desc = route.userInfo["description"]
    //          .flatMap { $0 as? String }
    //          .flatMap { $0.consoleText() } ?? ""
    //        column.append(desc)
    //      }
    //
    //      return column
    //    }
    
    
    //    context.console.outputASCIITable(defaultTable)
  }
}

extension PathComponent {
  func consoleText() -> ConsoleText {
    switch self {
      case .constant:
        return description.consoleText()
      default:
        return description.consoleText(.info)
    }
  }
}

extension Console {
  func outputASCIITable(_ rows: [[ConsoleText]]) {
    var columnWidths: [Int] = []
    
    // calculate longest columns
    for row in rows {
      for (i, column) in row.enumerated() {
        if columnWidths.count <= i {
          columnWidths.append(0)
        }
        if column.description.count > columnWidths[i] {
          columnWidths[i] = column.description.count
        }
      }
    }
    
    func hr() {
      var text: ConsoleText = ""
      for columnWidth in columnWidths {
        text += "+"
        text += "-"
        for _ in 0..<columnWidth {
          text += "-"
        }
        text += "-"
      }
      text += "+"
      self.output(text)
    }
    
    for row in rows {
      hr()
      var text: ConsoleText = ""
      for (i, column) in row.enumerated() {
        text += "| "
        text += column
        for _ in 0..<(columnWidths[i] - column.description.count) {
          text += " "
        }
        text += " "
      }
      text += "|"
      self.output(text)
    }
    
    hr()
  }
}
