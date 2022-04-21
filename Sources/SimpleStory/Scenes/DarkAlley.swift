import Narratore
import SimpleSetting

public struct DarkAlley: Scene {
  public typealias Game = SimpleStory

  private let shouldHearBookshopTrashing: Bool

  public init(world: Game.World) {
    shouldHearBookshopTrashing = !world.wasTheBookshopTrashed
  }

  public static let branches: [RawBranch<SimpleStory>] = [
    Main.raw,
  ]

  public enum Main: Branch {
    @BranchBuilder<Self>
    public static func getSteps(for scene: DarkAlley) -> [BranchStep<Self>] {
      if !scene.shouldHearBookshopTrashing {
        "Same dark alley as before"
        "Nothing more to see here"
      } else {
        "You're looking at a dark alley"
        "Not much to say, actually"
        "Garbage bins, here and there"
        
        check {
          if $0.world.theCreatureLookedLike == .aDarkShadow {
            tell {
              "The only thing that could lurk here is the shadow that you were dreaming about"
              "But that was just a dream"
              "..."
              "Was it?"
            }
          }
        }
        
        check {
          if $0.world.theCreatureLookedLike == .aDarkShadow {
            choose {
              "It was just a dream".onSelect {
                "Yes, it was".with {
                  $0.increaseMentalHealth()
                }
              }
              
              "Maybe... not?".onSelect {
                tell {
                  "Maybe not"
                  "These thoughts are not helping..."
                } update: {
                  $0.decreaseMentalHealth()
                }
              }
            }
          }
        }
        
        checkMentalHealth()
        
        "But you notice something weird"
        "A bunch of flattened cardboard boxes, stacked against a wall near one of the bins"
        "You don't know why, but they picked your curiosity"

        choose {
          "I bet there's a corpse underneath".onSelect {
            tell {
              "There must be a corpse underneath"
              "You're a private investigator, this is an investigation, and you're in a dark alley"
              "A corpse must be involved in this".with(id: .didSpeculatedAboutTheCorpse)
            }
          }
          
          if $0.world.theCreatureLookedLike == .anAlienBeing {
            "Maybe that alien that I was dreaming about".onSelect {
              tell {
                "Maybe that alien"
                "You dreamed about it, it must mean something"
                "Or alternatively..."
                "...you should stop with these useless thoughts, and move on with the investigation"
              }
            }
          }
          
          "Let's not linger and move the boxes".onSelect {
            "Maybe it's the investigator 6th sense"
          }
        }
        
        "You move the cardboard boxes"
        
        check {
          if $0.script.didNarrate(.didSpeculatedAboutTheCorpse) {
            "Of course there's no corpse underneath"
          }
        }
        
        "There's a weird 'hole' on the ground"
        "A black, deep hole"
        "And a weird slimy substance seems to be dripping from the walls of the hole".with {
          $0.wasTheSlimyGooeySubstanceObservedInTheDarkAlley = true
        }
        "You have no idea what's that about, but then you remember"
        "The grocery store owner told that the person that you're looking for seemed to be dumping here a bunch of bean cans"
        
        check {
          "Maybe \($0.world.targetPersonPronoun.they) dumped that in this hole?"
        }
        
        choose {
          let (they, their, them) = $0.world.targetPersonPronoun
          
          "\(they.capitalized) must be \"feeding\" something".onSelect {
            tell {
              "\(they.capitalized) must be \"feeding\" something"
              "And whatever it is, it must be close"
            } update: {
              $0.didDeduce(.targetIsFeedingSomething)
            }
          }
          
          "\(they.capitalized) really hates beans".onSelect {
            tell {
              "\(they.capitalized) really hates beans"
              "And \(they) wants to devoid the world of them"
              "You can almost hear \(them): 'away with those goddamn beans'"
            }
          }
          
          "\(they.capitalized) is nuts".onSelect {
            tell {
              "\(they.capitalized) is nuts"
              "It's simple"
              "You need to ask more money to \(their) parents"
              "You take an extra for crazy targets"
            }
          }
        }
        
        "Suddenly, you hear some noise from the street, on the side where the bookshop is".with {
          $0.wasTheBookshopTrashed = true
        }
        "You should go and take a look"
      }
    }
  }
}

extension SimpleStory.Message.ID {
  fileprivate static let didSpeculatedAboutTheCorpse: Self = "didSpeculatedAboutTheCorpse"
}
