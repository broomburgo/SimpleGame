import Narratore
import SimpleSetting

enum GroceryStore {
  static let scenes: [RawScene<SimpleStory>] = [
    Main.raw,
    LookAround.raw,
    AskAboutTheTarget.raw,
    AskAboutTheBeans.raw,
  ]

  struct Main: SceneType {
    enum Anchor: Codable & Hashable {
      case whatToDo
    }

    var didLookAroundOnce: Bool = false
    var didNoticeMissingBeans: Bool = false
    var didAskAboutTheTarget: Bool = false

    var steps: Steps {
      "A simple, well lit grocery store"
      "There's an old woman at the checkout, but no customers around"
      "The woman appears to be reading a magazine"

      "What will you do?".with(anchor: .whatToDo)

      DO.choose {
        let (they, _, _) = $0.world.targetPersonPronoun

        if didLookAroundOnce {
          "Look around some more".onSelect {
            .tell {
              "You take another look around"
            } then: {
              .replaceWith(LookAround(main: self))
            }
          }
        } else {
          "Look around".onSelect {
            .tell {
              "You take a look around"
            } then: {
              .replaceWith(LookAround(main: self))
            }
          }
        }

        if !didAskAboutTheTarget {
          "Ask about the target".onSelect {
            .tell {
              "You ask the woman at the checkout about the person you're looking for"
            } then: {
              .replaceWith(AskAboutTheTarget(main: self))
            }
          }
        }

        if didAskAboutTheTarget, didNoticeMissingBeans {
          "Ask about the beans".onSelect {
            .tell {
              "'Did \(they) buy all the beans in the store?'"
            } then: {
              .replaceWith(AskAboutTheBeans())
            }
          }
        }

        "Get our of here".onSelect {
          .tell {
            "You decide to leave the grocery store"
            "'Goodbye'"
          }
        }
      }
    }
  }

  struct LookAround: SceneType {
    var main: Main

    var steps: Steps {
      "It's a regular grocery store"
      "Nothing much to say"
      "The target likely purchased some stuff here"

      if main.didLookAroundOnce {
        "But not beans"
        "You just noticed"
        "The canned food isle is completely missing beans"
        "There's a whole column empty"
        DO.then { .replaceWith(main.updating { $0.didNoticeMissingBeans = true }, at: .whatToDo) }
      } else {
        "You would too, probably, if you were hungry or something"
        "But you had a serious lunch, and don't feel like dinner yet"
        DO.then { .replaceWith(main.updating { $0.didLookAroundOnce = true }, at: .whatToDo) }
      }
    }
  }

  struct AskAboutTheTarget: SceneType {
    var main: Main

    var steps: Steps {
      "'Excuse me ma'am, can you ask you some questions?'"
      "'Of course dear'"
      "'Did you see...'"
      "'But first, purchase something'"
      "'Er...'"
      "'Information has a price, you know?'"
      "'But I'm willing to give it away for free, as an extra item in a transaction'"
      "It looked to good to be true"
      "'What transaction should take place, my dear?'"
      "You like being called \"dear\""
      "But not in the midst of a \"transaction\""

      DO.choose { _ in
        "'I'll buy this pack of gum'".onSelect {
          .tell {
            "'I'll buy this pack of gum'"
            "'That's it? Do you think it could cover, even partially, the cost of the information?'"
            "'I'll buy 10 packs of gum'"
            "You really can't think about anything else"
          }
        }

        "'I'll buy this newspaper'".onSelect {
          .tell {
            "'I'll buy this newspaper'"
            "'It's from yesterday'"
            "'I'd like to buy it ma'am'"
            "'It doesn't contain today's news, it's not much of a \"news\"paper'"
            "'I like yesterday's news'"
            "'Got it, it's your money'"
          } update: {
            $0.increaseMentalHealth()
          }
        }

        "'I'll buy a pack of cigarettes'".onSelect {
          .tell {
            "'I'll buy a pack of cigarettes'"
            "'You smoke?'"
            "'Ahem..'"
            "Gotcha"
            "You don't smoke"
            "It's bad for you"
            "But you needed something"
            "'I do'"
            "'How many cigarettes a day?'"
            "You don't actually have a ready estimate"
            "You don't really know how much a smoker smokes"
            "'Ahem... seven?'"
            "'Is that a question?'"
            "'No, it's an answer: seven'"
            "'You don't know what you're talking about, do you?'"
            "'What do you mean?'"
            "'Smoke one right now'"
            "'I don't... I don't want to'"
            "'Whatever, it's your money'"
          } update: {
            $0.decreaseMentalHealth()
          }
        }
      }

      checkMentalHealth()

      "'And this cute pocket diary' says the woman, pointing at a small agenda on the desk"
      "'What?'"
      "'You don't like it?'"
      "'I...'"
      "'Look, it's cute, and pocket'"
      "'Er... I don't need it'"
      "'I don't need a lot of things, but the economy: the economy needs US'"
      "You buy the whole lot, then, as fast as you can, you get the target person's photo out of your pocket and show it to the woman, lest she decides to charge you an extra for the time"
      "'Have you seen this person?'"

      DO.tell {
        let (they, _, them) = $0.world.targetPersonPronoun

        "'Yeah, I've probably seen \(them)'"
        "'\(they.capitalized) kept buying beans'"
        "'Other than that, \(they) seemed a perfectly normal person'"
      }

      "This was pointless"
      DO.then { .replaceWith(main.updating { $0.didAskAboutTheTarget = true }, at: .whatToDo) }
    }
  }

  struct AskAboutTheBeans: SceneType {
    private var typeName = Self.identifier

    var steps: Steps {
      "'I'm not sure, maybe yes'"
      "'But you know what? Something strange happened a couple of days ago, when she bought so many beans that she needed a shopping cart to carry them, a cart that she brought herself here'"
      "'What happened'"
      "'I'm sorry sir, but I think your recent purchase won't cover the costs of this additional information'"
      "You harness your reaction speed powers..."
      "...then you quickly grab some loose change from your pocket..."
      "...and throw it on the desk."
      "'20 packs of gum please'"

      DO.tell {
        let (they, _, _) = $0.world.targetPersonPronoun
        "'Instead of using the front door, \(they) got out from the back'"
        "'There's a rather shady alley back there'"
        "'And I think I heard something, a clashing sound"
        "'Like \(they) dumped the whole lot of canned beans somewhere'"
      }

      "'Can I also get out of the back door?'"
      "'The lock is broken, I've been waiting for the kid from the hardware store to fix it, but he doesn't seem interested enough in the economy'"
      "You really can't blame him..."

      "'But you don't need to go through there: you can access the back alley right from the street, just exit through the front door and turn right'".with {
        $0.didDiscover(.darkAlley)
      }

      "'Thanks ma'am'"
      "'Thank you, for getting the economy moving'"
      "You exit the store, happy for having done your part"
    }
  }
}
