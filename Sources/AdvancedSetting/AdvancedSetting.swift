import Narratore
import SimpleSetting

public protocol SettingExtra {
  associatedtype CustomWorld: Codable
  associatedtype InventoryItem: Codable & Hashable
}

public protocol Localizing {
  associatedtype Language: Hashable & Codable
  static var base: Language { get }
  static var current: Language { get set }
}

public enum AdvancedSetting<Extra: SettingExtra, Localization: Localizing>: Setting {
  public typealias Generate = SimpleSetting.Generate
  public typealias Message = LocalizedMessage<Localization>
  public typealias Tag = SimpleSetting.Tag

  public struct World: Codable {
    public var attributes: Attributes
    public var custom: Extra.CustomWorld
    public var inventory: [Extra.InventoryItem: Int]

    public init(
      attributes: Attributes,
      custom: Extra.CustomWorld,
      inventory: [Extra.InventoryItem: Int]
    ) {
      self.attributes = attributes
      self.custom = custom
      self.inventory = inventory
    }

    public struct Attributes: Codable {
      public var impact: Int
      public var dexterity: Int
      public var intelligence: Int
      public var perception: Int
      public var charisma: Int
      public var empathy: Int

      public init(
        impact: Int,
        dexterity: Int,
        intelligence: Int,
        perception: Int,
        charisma: Int,
        empathy: Int
      ) {
        self.impact = impact
        self.dexterity = dexterity
        self.intelligence = intelligence
        self.perception = perception
        self.charisma = charisma
        self.empathy = empathy
      }
    }
  }
}

public struct LocalizedMessage<Localization: Localizing>: Messaging {
  public var text: String {
    let templated: String
    if Localization.current != Localization.base,
       let translated = translations[Localization.current]
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
  public var translations: [Localization.Language: String]
  public var values: [String: String]

  public init(
    id: ID?,
    baseText: String,
    translations: [Localization.Language: String],
    values: [String: String]
  ) {
    self.id = id
    self.baseText = baseText
    self.translations = translations
    self.values = values
  }

  public init(id: ID?, text: String) {
    self.init(id: id, baseText: text, translations: [:], values: [:])
  }

  public struct ID: Hashable, Codable, ExpressibleByStringLiteral, CustomStringConvertible {
    public var description: String

    public init(stringLiteral value: String) {
      description = value
    }
  }
}

extension String {
  public func localized<B: Branch, Localization: Localizing>(
    anchor: B.Anchor? = nil,
    id: B.Game.Message.ID? = nil,
    values: [String: String] = [:],
    translations: [Localization.Language: String] = [:]
  ) -> BranchStep<B> where B.Game.Message == LocalizedMessage<Localization> {
    .init(
      anchor: anchor,
      getStep: .init { _ in
        .init(
          narration: .init(
            messages: [
              .init(
                id: id,
                baseText: self,
                translations: translations,
                values: values
              ),
            ],
            tags: [],
            update: nil
          )
        )
      }
    )
  }
}
