import Narratore
import SimpleSetting

public protocol SettingExtra {
  associatedtype Attribute: Codable & Hashable
  associatedtype InventoryItem: Codable & Hashable
  associatedtype CustomWorld: Codable
}

public protocol Localizing {
  associatedtype Language: Hashable & Codable
  static var base: Language { get }
  static var current: Language { get set }
  static var translations: [Language: String] { get }
}

public enum AdvancedSetting<Extra: SettingExtra, Localization: Localizing>: Setting {
  public typealias Generate = SimpleSetting.Generate
  public typealias Message = LocalizedMessage<Localization>
  public typealias Tag = SimpleSetting.Tag

  public struct World: Codable {
    public var attributes: [Extra.Attribute: Int]
    public var inventory: [Extra.InventoryItem: Int]
    public var custom: Extra.CustomWorld

    public init(
      attributes: [Extra.Attribute: Int],
      inventory: [Extra.InventoryItem: Int],
      custom: Extra.CustomWorld
    ) {
      self.attributes = attributes
      self.inventory = inventory
      self.custom = custom
    }
  }
}

public struct LocalizedMessage<Localization: Localizing>: Messaging {
  public var text: String {
    let templated: String
    if Localization.current != Localization.base,
       let translated = Localization.translations[Localization.current]
    {
      templated = translated
    } else {
      templated = baseText
    }

    return values.reduce(templated) {
      $0.replacingOccurrences(of: $1.key, with: $1.value)
    }
  }

  public var id: ID?
  public var baseText: String
  public var values: [String: String]

  public init(
    id: ID?,
    baseText: String,
    values: [String: String]
  ) {
    self.id = id
    self.baseText = baseText
    self.values = values
  }

  public init(id: ID?, text: String) {
    self.init(id: id, baseText: text, values: [:])
  }

  public struct ID: Hashable, Codable, ExpressibleByStringLiteral, CustomStringConvertible {
    public var description: String

    public init(stringLiteral value: String) {
      description = value
    }
  }
}
