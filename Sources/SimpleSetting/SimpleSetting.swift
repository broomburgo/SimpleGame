import Narratore
import Foundation

public enum SimpleSetting: Setting {
  public struct World: Codable {
    public var value: [Key: Value] = [:]
    public var list: [Key: [Value]] = [:]
    
    public init() {}

    public struct Key: ExpressibleByStringLiteral & CustomStringConvertible & Codable & Equatable & Hashable {
      public var description: String
      public init(stringLiteral value: String) {
        description = value
      }
    }

    public struct Value: ExpressibleByStringLiteral & CustomStringConvertible & Codable & Equatable {
      public var description: String
      public init(stringLiteral value: String) {
        description = value
      }
    }
  }
  
  public struct Message: Messaging {
    public var id: ID?
    public var text: String
    
    public init(id: ID?, text: String) {
      self.id = id
      self.text = text
    }
    
    public struct ID: Hashable & Codable & ExpressibleByStringLiteral & CustomStringConvertible {
      public var description: String
      
      public init(stringLiteral value: String) {
        self.description = value
      }
    }
  }
  
  public struct Tag: Tagging & CustomStringConvertible {
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
    public static var getFixedRandomRatio: (() -> Double)? = nil
    public static var getFixedUniqueString: (() -> String)? = nil

    public static func randomRatio() -> Double {
      getFixedRandomRatio?() ?? Double((0...1000).randomElement()!)/1000
    }
    
    public static func uniqueString() -> String {
      getFixedUniqueString?() ?? UUID().uuidString
    }
  }  
}
