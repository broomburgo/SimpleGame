import Narratore
import SimpleSetting

public struct GroceryStore: Scene {
  public typealias Game = SimpleStory
  
  public var didLookAroundOnce: Bool = false
  public var didNoticeMissingBeans: Bool = false
  public var didAskAboutTheTarget: Bool = false
  
  public init() {}
  
  public static let branches: [RawBranch<SimpleStory>] = [
    Main.raw
  ]
  
  public enum Main: Branch {
    public enum Anchor {
      case whatToDo
    }
    
    @BranchBuilder<Self>
    public static func getSteps(for scene: GroceryStore) -> [BranchStep<Self>] {
      "A simple, well lit grocery store"
      "There's an old woman at the checkout, but no customers around"
      "The woman appears to be reading a magazine"
      
      "What will you do?".with(anchor: .whatToDo)
      
      choose {
        let (they, _, _) = $0.world.targetPersonPronoun

        if scene.didLookAroundOnce {
          "Look around some more".onSelect {
            "You take another look around"
              .then(.replaceWith(LookAround.self, scene: scene))
          }
        } else {
          "Look around".onSelect {
            "You take a look around"
              .then(.replaceWith(LookAround.self, scene: scene))
          }
        }
        
        if !scene.didAskAboutTheTarget {
          "Ask about the target".onSelect {
            "You ask the woman at the checkout about the person you're looking for"
              .then(.replaceWith(AskAboutTheTarget.self, scene: scene))
          }
        }
        
        if scene.didAskAboutTheTarget, scene.didNoticeMissingBeans {
          "Ask about the beans".onSelect {
            "'Did \(they) buy all the beans in the store?'"
              .then(.replaceWith(AskAboutTheBeans.self, scene: scene))
          }
        }
        
        "Get our of here".onSelect {
          tell {
            "You decide to leave the grocery store"
            "'Goodbye'"
          }
        }
      }
    }
  }
  
  public enum LookAround: Branch {
    @BranchBuilder<Self>
    public static func getSteps(for scene: GroceryStore) -> [BranchStep<Self>] {
      "It's a regular grocery store"
      "Nothing much to say"
      "The target likely purchased some stuff here"

      if scene.didLookAroundOnce {
        "But not beans"
        "You just noticed"
        "The canned food isle is completely missing beans"
        "There's a whole column empty"
        then(.replaceWith(Main.self, at: .whatToDo, scene: scene.updating { $0.didNoticeMissingBeans = true }))
      } else {
        "You would too, probably, if you were hungry or something"
        "But you had a serious lunch, and don't feel like dinner yet"
        then(.replaceWith(Main.self, at: .whatToDo, scene: scene.updating { $0.didLookAroundOnce = true }))
      }
    }
  }
  
  public enum AskAboutTheTarget: Branch {
    @BranchBuilder<Self>
    public static func getSteps(for scene: GroceryStore) -> [BranchStep<Self>] {
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
      
      choose { _ in
        "'I'll buy this pack of gum'".onSelect {
          tell {
            "'I'll buy this pack of gum'"
            "'That's it? Do you think it could cover, even partially, the cost of the information?'"
            "'I'll buy 10 packs of gum'"
            "You really can't think about anything else"
          }
        }
        
        "'I'll buy this newspaper'".onSelect {
          tell {
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
          tell {
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
      
      tell {
        let (they, _, them) = $0.world.targetPersonPronoun
        
        "'Yeah, I've probably seen \(them)'"
        "'\(they.capitalized) kept buying beans'"
        "'Other than that, \(they) seemed a perfectly normal person'"
      }
      
      "This was pointless"
      then(.replaceWith(Main.self, at: .whatToDo, scene: scene.updating { $0.didAskAboutTheTarget = true }))
    }
  }
  
  public enum AskAboutTheBeans: Branch {
    @BranchBuilder<Self>
    public static func getSteps(for _: GroceryStore) -> [BranchStep<Self>] {
      "'I'm not sure, maybe yes'"
      "'But you know what? Something strange happened a couple of days ago, when she bought so many beans that she needed a shopping cart to carry them, a cart that she brought herself here'"
      "'What happened'"
      "'I'm sorry sir, but I think your recent purchase won't cover the costs of this additional information'"
      "You harness your reaction speed powers..."
      "...then you quickly grab some loose change from your pocket..."
      "...and throw it on the desk."
      "'20 packs of gum please'"
      
      tell {
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
