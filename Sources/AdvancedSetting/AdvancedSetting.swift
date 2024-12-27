import Narratore
import SimpleSetting

/// Describes the attributes of the player character (like "vigor" and "wisdom".
public protocol AdvancedSettingAttribute: Codable, Hashable, Sendable {
  associatedtype Value: Codable, Sendable
}

/// Describes the possible inventory items.
public protocol AdvancedSettingInventoryItem: Codable, Hashable, Sendable {
  associatedtype Count: Codable, Sendable
}

/// Adds extra concepts to the `Setting`.
public protocol AdvancedSettingExtra: Sendable {
  associatedtype Attribute: AdvancedSettingAttribute
  associatedtype InventoryItem: AdvancedSettingInventoryItem
  associatedtype CustomWorld: Codable, Sendable
}

/// A `World` type that includes the `Extra` concepts.
public struct AdvancedWorld<Extra: AdvancedSettingExtra>: Codable, Sendable {
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

/// Adds localization to the `Setting`.
public protocol Localizing {
  associatedtype Language: Hashable, Codable
  static var base: Language { get }
  static var current: Language { get set }
  static var translations: [String: [Language: String]] { get }
}

/// A type of `Message` that uses `Localization` to provide a localized text, based the `base: Language` text, and `templateValues` (if needed).
public struct LocalizedMessage<Localization: Localizing>: Messaging {
  public var text: String {
    guard !baseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return ""
    }

    let templated: String =
      if Localization.current != Localization.base,
      let translated = Localization.translations[baseText]?[Localization.current] {
        translated
      } else {
        baseText
      }

    return templateValues.reduce(templated) {
      $0.replacingOccurrences(of: $1.key, with: $1.value)
    }
  }

  public var id: ID?
  public var baseText: String
  public var templateValues: [String: String]

  public init(
    id: ID?,
    baseText: String,
    templateValues: [String: String]
  ) {
    self.id = id
    self.baseText = baseText
    self.templateValues = templateValues
  }

  public init(id: ID?, text: String) {
    self.init(id: id, baseText: text, templateValues: [:])
  }

  public struct ID: Hashable, Codable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
    public var description: String

    public init(stringLiteral value: String) {
      description = value
    }
  }
}

/// A `Setting` that includes extra concepts, and message localization.
public protocol AdvancedSetting: Setting where
  World == AdvancedWorld<Extra>,
  Message == LocalizedMessage<Localization> {
  associatedtype Extra: AdvancedSettingExtra
  associatedtype Localization: Localizing
}

/// A possible `AdvancedSetting` type.
///
/// This adds to basic `SimpleSetting` concepts:
/// - some specific definitions for attributes and inventory;
/// - `.english` and `.italian` localizations.
public enum MyAdvancedSetting: AdvancedSetting {
  public enum Extra: AdvancedSettingExtra {
    public struct Attribute: AdvancedSettingAttribute {
      public var name: String

      public init(name: String) {
        self.name = name
      }

      public enum Value: Codable, Sendable {
        case weak
        case fair
        case strong
      }
    }

    public struct InventoryItem: AdvancedSettingInventoryItem {
      public var name: String

      public init(name: String) {
        self.name = name
      }

      public typealias Count = UInt
    }

    public typealias CustomWorld = SimpleSetting.World
  }

  public enum Localization: Localizing {
    public enum Language: Hashable, Codable, Sendable {
      case english
      case italian
    }

    public static var base: Language { .english }

    public static var current: Language {
      get {
        Current.language
      }
      set {
        Current.language = newValue
      }
    }

    public static var translations: [String: [Language: String]] {
      Current.translations
    }
  }

  public typealias Generate = SimpleSetting.Generate
  public typealias Tag = SimpleSetting.Tag
}

private enum Current {
  /// The current selected language.
  nonisolated(unsafe) static var language: MyAdvancedSetting.Localization.Language = .english

  /// Translations will go here, and could be generated from a file.
  static let translations: [String: [MyAdvancedSetting.Localization.Language: String]] = [
    "Good morning, %PC_NAME%!": [
      .italian: "Buongiorno, %PC_NAME%!",
    ],
  ]
}
