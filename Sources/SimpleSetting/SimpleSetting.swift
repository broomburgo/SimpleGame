import Foundation
import Narratore

public enum SimpleSetting: Setting {
  public struct World: Codable, Sendable {
    public var value: [Key: Value] = [:]
    public var list: [Key: [Value]] = [:]

    public init() {}

    public struct Key: ExpressibleByStringLiteral, CustomStringConvertible, Codable, Equatable, Hashable, Sendable {
      public var description: String
      public init(stringLiteral value: String) {
        description = value
      }
    }

    public struct Value: ExpressibleByStringLiteral, CustomStringConvertible, Codable, Equatable, Sendable {
      public var description: String
      public init(stringLiteral value: String) {
        description = value
      }
    }
  }

  public struct Message: Messaging, ExpressibleByStringLiteral {
    public var id: ID?
    public var text: String

    public init(id: ID?, text: String) {
      self.id = id
      self.text = text
    }

    public init(stringLiteral value: String) {
      self.init(id: nil, text: value)
    }

    public struct ID: Hashable, Codable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
      public var description: String

      public init(stringLiteral value: String) {
        description = value
      }
    }
  }

  public struct Tag: Tagging, CustomStringConvertible {
    public var value: String
    public var shouldObserve: Bool

    public init(_ value: String, shouldObserve: Bool = false) {
      self.value = value
      self.shouldObserve = shouldObserve
    }

    public var description: String {
      value
    }
  }

  public enum Generate: Generating {
    public actor Fixed {
      public static let shared = Fixed()

      public var randomRatio: Double?
      public var uniqueString: String?

      public func set(randomRatio: Double?) {
        self.randomRatio = randomRatio
      }

      public func set(uniqueString: String?) {
        self.uniqueString = uniqueString
      }
    }

    public static func randomRatio() async -> Double {
      await Fixed.shared.randomRatio ?? Double((0...1000).randomElement()!) / 1000
    }

    public static func uniqueString() async -> String {
      await Fixed.shared.uniqueString ?? UUID().uuidString
    }
  }
}
