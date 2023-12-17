import Narratore
import SimpleSetting

public protocol AdvancedSettingAttribute: Codable & Hashable {
  associatedtype Value: Codable
}

public protocol AdvancedSettingInventoryItem: Codable & Hashable {
  associatedtype Count: Codable
}

public protocol AdvancedSettingExtra {
  associatedtype Attribute: AdvancedSettingAttribute
  associatedtype InventoryItem: AdvancedSettingInventoryItem
  associatedtype CustomWorld: Codable
}

public protocol Localizing {
  associatedtype Language: Hashable & Codable
  static var base: Language { get }
  static var current: Language { get set }
  static var translations: [Language: String] { get }
}

public struct AdvancedWorld<Extra: AdvancedSettingExtra>: Codable {
  public var attributes: [Extra.Attribute: Extra.Attribute.Value]
  public var inventory: [Extra.InventoryItem: Extra.InventoryItem.Count]
  public var custom: Extra.CustomWorld

  public init(
    attributes: [Extra.Attribute: Extra.Attribute.Value],
    inventory: [Extra.InventoryItem: Extra.InventoryItem.Count],
    custom: Extra.CustomWorld
  ) {
    self.attributes = attributes
    self.inventory = inventory
    self.custom = custom
  }
}

public struct LocalizedMessage<Localization: Localizing>: Messaging {
  public var text: String {
    let templated: String =
      if Localization.current != Localization.base,
      let translated = Localization.translations[Localization.current]
    {
      translated
    } else {
      baseText
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

public protocol AdvancedSetting: Setting where
  World == AdvancedWorld<Extra>,
  Message == LocalizedMessage<Localization>
{
  associatedtype Extra: AdvancedSettingExtra
  associatedtype Localization: Localizing
}
