import Narratore
import SimpleSetting

public typealias SimpleStory = SimpleSetting

extension SimpleStory {
  public static func initialScene() -> some SceneType<Self> {
    Car()
  }
}

extension SceneType {
  typealias Game = SimpleStory
}

extension SimpleStory: Story {
  public static let scenes: [RawScene<SimpleStory>] = Array([
    Apartment7.scenes,
    Bookshop.scenes,
    [Car.raw],
    [DarkAlley.raw],
    GroceryStore.scenes,
    LookForHelp.scenes,
    Street.scenes,
  ].joined())
}

// MARK: - Generic

extension SimpleStory.World.Value {
  static let positive: Self = "positive"
  static let negative: Self = "negative"
}

// MARK: - Deductions

enum Deduction: String, Codable, CaseIterable {
  case targetMovedToNeighborhoodBecauseOfBookshop
  case targetIsInterestedInBooksAboutOccultRituals
  case targetIsFeedingSomething
}

extension SimpleStory.World {
  mutating func didDeduce(_ deduction: Deduction) {
    list["deductions", default: []].append(.init(stringLiteral: deduction.rawValue))
  }

  func hasDeduced(_ deduction: Deduction) -> Bool {
    list["deductions", default: []].contains(.init(stringLiteral: deduction.rawValue))
  }
}

// MARK: - DiscoveredPlaces

enum Place: String, Codable {
  case bookshop
  case groceryStore
  case darkAlley
  case apartment7
}

extension SimpleStory.World.Value {
  static func place(_ place: Place) -> Self {
    .init(stringLiteral: place.rawValue)
  }
}

extension SimpleStory.Message.ID {
  static func didDescribe(_ place: Place) -> Self {
    .init(stringLiteral: "Did describe \(place.rawValue)")
  }
}

extension SimpleStory.World {
  mutating func didDiscover(_ place: Place) {
    list["discoveredPlaces", default: []].append(.place(place))
  }

  func hasDiscovered(_ place: Place) -> Bool {
    list["discoveredPlaces", default: []].contains(.place(place))
  }
}

extension Script where Game == SimpleStory {
  func hasDescribed(_ place: Place) -> Bool {
    didNarrate(.didDescribe(place))
  }
}

// MARK: - MentalHealth

extension SimpleStory.World {
  mutating func increaseMentalHealth() {
    guard mentalHealth < 5 else { return }
    list[.mentalHealth, default: []].append(.positive)
  }

  mutating func decreaseMentalHealth() {
    guard mentalHealth > 0 else { return }
    list[.mentalHealth, default: []].append(.negative)
  }

  var mentalHealth: Int {
    list[.mentalHealth, default: []].reduce(into: 4) {
      switch $1 {
      case .positive:
        if $0 < 5 {
          $0 += 1
        }

      case .negative:
        if $0 > 0 {
          $0 -= 1
        }

      default:
        break
      }
    }
  }
}

extension DO where Scene.Game == SimpleStory {
  static func checkMentalHealth() -> SceneStep<Scene> {
    DO.check {
      switch $0.world.mentalHealth {
      case 0:
          .tell {
            "Suddenly, you feel agitated and paranoid"
            "You're senses are leaving you..."
            "It's like falling asleep..."
          } then: {
            .transitionTo(PassedOut())
          }

      case 1 where !$0.script.didNarrate(.gotToMentalHealth1):
          .tell {
            "You feel confused"
            "It seems like you're sweating"
            "You're hands are shaking a bit".with(id: .gotToMentalHealth1)
          }

      case 2 where !$0.script.didNarrate(.gotToMentalHealth2):
          .tell {
            "You feel a little disoriented"
            "It seems like someone is following you"
            "Or maybe you're being watched"
            "You can't say, but you better watch you back".with(id: .gotToMentalHealth2)
          }

      case 3 where !$0.script.didNarrate(.gotToMentalHealth3):
          .tell {
            "You feel a little dizzy"
            "Maybe you're just tired"
            "Let's hope this case ends soon".with(id: .gotToMentalHealth3)
          }

      default:
          .skip
      }
    }
  }
}

struct PassedOut: SceneType {
  private var typeName = Self.identifier

  var steps: Steps {
    "You fall on the ground"
    "You're eyes are closing"
    "With the last light, you see a strange creature in the distance"
    "It's like it's watching you..."
    "...watching you..."
    "..."
    "..."
  }
}

extension SimpleStory.World.Key {
  /// list
  static let mentalHealth: Self = "mentalHealth"
}

extension SimpleStory.Message.ID {
  fileprivate static let gotToMentalHealth1: Self = "gotToMentalHealth1"
  fileprivate static let gotToMentalHealth2: Self = "gotToMentalHealth2"
  fileprivate static let gotToMentalHealth3: Self = "gotToMentalHealth3"
}

// MARK: - Choices

//

// MARK: areYouWeird

extension SimpleStory.World {
  var areYouWeird: Bool {
    get {
      value["areYouWeird"] == .positive
    }
    set {
      value["areYouWeird"] = newValue ? .positive : .negative
    }
  }
}

// MARK: targetPersonSex

extension SimpleStory.World {
  var targetPersonPronoun: (they: String, their: String, them: String) {
    switch value[.targetPersonSex] {
    case .male?:
      (
        they: "he",
        their: "his",
        them: "him"
      )

    case .female?:
      (
        they: "she",
        their: "her",
        them: "her"
      )

    default:
      (
        they: "they",
        their: "their",
        them: "them"
      )
    }
  }
}

extension SimpleStory.World.Key {
  /// value
  static let targetPersonSex: Self = "targetPersonSex"
}

extension SimpleStory.World.Value {
  static let male: Self = "male"
  static let female: Self = "female"
}

// MARK: whatTheCreatureLookedLike

extension SimpleStory.World {
  var theCreatureLookedLike: Value? {
    get {
      value["whatTheCreatureLookedLike"]
    }
    set {
      value["whatTheCreatureLookedLike"] = newValue
    }
  }
}

extension SimpleStory.World.Value {
  static let anAlienBeing: Self = "anAlienBeing"
  static let aFish: Self = "aFish"
  static let aDarkShadow: Self = "aDarkShadow"
}

// MARK: - Events

extension SimpleStory.World {
  var wasTheBookshopTrashed: Bool {
    get {
      value["wasTheBookshopTrashed"] == .positive
    }
    set {
      value["wasTheBookshopTrashed"] = newValue ? .positive : .negative
    }
  }

  var wasTheDoorClosed: Bool {
    get {
      value["wasTheDoorClosed"] == .positive
    }
    set {
      value["wasTheDoorClosed"] = newValue ? .positive : .negative
    }
  }

  var wasTheKeyFound: Bool {
    get {
      value["wasTheKeyFound"] == .positive
    }
    set {
      value["wasTheKeyFound"] = newValue ? .positive : .negative
    }
  }

  var wasTheSlimyGooeySubstanceObservedInTheDarkAlley: Bool {
    get {
      value["wasTheSlimyGooeySubstanceObservedInTheDarkAlley"] == .positive
    }
    set {
      value["wasTheSlimyGooeySubstanceObservedInTheDarkAlley"] = newValue ? .positive : .negative
    }
  }
}
