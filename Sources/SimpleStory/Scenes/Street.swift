import Narratore
import SimpleSetting

public enum Street {
  public static let scenes: [RawScene<SimpleStory>] = [
    Main.raw,
    LookingAround.raw,
  ]

  public struct Main: SceneType {
    public var steps: Steps {
      "It's a rainy evening, and the street is almost empty"
      "Few people live in this part of town. This is one of those neighborhoods that, while not exactly bad per se, has a fame of being inhabited by 'weird' people"
      "You can say that it even attracts people that think of themselves as 'weird'"
      "In fact, you considered it for yourself in the past, but.."
      "...it probably would have interfered with you private eye game"
      "Wait, are you 'weird'?"

      choose {
        let theCreatureLookedLike = $0.world.theCreatureLookedLike

        "Yep".onSelect {
          tell {
            "Yes you are, what was I thinking?"
            "Occasionally, you might have a weird dream or two"
            "But you like the normal world"
            "No alternate realities for you"
            "And that helps a lot with your line of work"
          } update: {
            $0.areYouWeird = true
          }
        }

        "Nope".onSelect {
          tell {
            "Not really"
            "It's more like 'it's complicated'"
            "Sometimes you like weird things"
            "Like thinking about alternate realities"
            "Or have weird thoughts"
            "Or dreams"

            switch theCreatureLookedLike {
            case .anAlienBeing?:
              "For example, that alien being you dreamed about"
            case .aFish?:
              "Like of weird fishes"
            case .aDarkShadow?:
              "Dark dreams, of dark shadows"
            default:
              skip()
            }

            "But you're still a well-rounded person"
            "Easy to talk to"
            "Not thinking about weird things at all..."
          } update: {
            $0.areYouWeird = false
          }
        }
      }

      "You learned early in you career that you need to project an image of self confidence and security"
      "Clients ask you to find their missing loved ones (or their most hated), so they must sure that you'll do the job in a professional, detached way, without messing up with the aforementioned loved ones"
      "But you dealt with seriously messed up people in your life, and sometimes the curiosity – to ask about what the hell are they doing in a certain place, or why the hell are they doing a certain thing – is simply too strong"
      "But anyway, let's see what fate is preparing for you in this rainy evening"

      "And let's get to work"

      then { .transitionTo(LookingAround()) }
    }
  }

  public struct LookingAround: SceneType {
    public enum Anchor: Codable & Hashable {
      case backInStreet
    }

    public var steps: Steps {
      "The rain is thin but persistent"

      update {
        $0.didDiscover(.bookshop)
        $0.didDiscover(.groceryStore)
      }

      "You look around".with(anchor: .backInStreet)

      tell {
        if $0.world.hasDiscovered(.bookshop), !$0.script.hasDescribed(.bookshop) {
          "You see a faint blue sign on a wall, lost in the darkness of the dirty bricks of a building on the other side of the street"
          "The sign says, intermittently, 'Books'"
          "Books..."
          "Books..."
          "Books..."
          "Your mind start to wander"
          "Thankfully, the feeling of the rain pressing on you thick hat somehow guarantees a good grasp on reality"
          "The person you're looking for was seen carrying around a bunch of books"
          "Books are likely a lead here"
          "And the bookshop is likely the first place to go and ask around"
          "Elementary, Watson".with(id: .didDescribe(.bookshop))
        }

        if $0.world.hasDiscovered(.groceryStore), !$0.script.hasDescribed(.groceryStore) {
          "There's a well lit grocery store, down the road"
          "Almost too lit"
          "It doesn't go well with the general dark feel of this street"
          "You just notice, in fact, that most streetlights are off, or soon to be"
          "The grocery store windows create a sphere of light"
          "Almost like a bonfire, a resting place for unlikely travelers passing through this obscure corner of the town"
          "You realize: you're one of them"
          "But anyway, the target must have purchased groceries, at some point..."
          "...so the grocery store is definitely a place to ask around"
          "Your detective senses seem to be working fine".with(id: .didDescribe(.groceryStore))
        }

        if $0.world.hasDiscovered(.darkAlley), !$0.script.hasDescribed(.darkAlley) {
          "There's a dark, narrow alley near the grocery store"
          "You can't see much inside, and you're not sure if there's someone there"
          "There's a pair of garbage bins, on the side of the grocery store"
          "A faint light illuminates the other side, probably another lightly-lit street"
          "You don't know why, but some kind of ominous atmosphere permeates the alley"
          "Something dark happened there, recently"
          "Could it be related with the person you're looking for?"
            .with(id: .didDescribe(.darkAlley))
        }

        if $0.world.hasDiscovered(.apartment7), !$0.script.hasDescribed(.apartment7) {
          "There's an apartment block, next to the grocery store"
          "It's a rather typical one, at least fort this part of the town"
          "You notice, though, that the facade of the building seems... moldy"
          "Like it's wrapped in a thin layer of blackish goo"
          "It's almost unnoticeable, you need to look for it"
          "But there's something in the way it looks that separates it from the neighboring buildings"
          "Look rather ominous, but it could be the case that the target lived there while staying in this neighborhood"
            .with(id: .didDescribe(.apartment7))
        }
      }

      "Where will you go now?"

      choose { context in
        if context.script.hasDescribed(.bookshop), !context.world.wasTheKeyFound {
          "The bookshop".onSelect {
            "You enter the bookshop".then {
              .runThrough(Bookshop.Main(
                status: context.world.wasTheBookshopTrashed
                  ? .trashed
                  : .regular
              ))
            }
          }
        }

        if context.script.hasDescribed(.groceryStore) {
          "The grocery store".onSelect {
            "You go to the grocery store".then {
              .runThrough(GroceryStore.Main())
            }
          }
        }

        if context.script.hasDescribed(.darkAlley) {
          "The dark alley".onSelect {
            "You enter the dark alley".then {
              .runThrough(DarkAlley(world: context.world))
            }
          }
        }

        if context.script.hasDescribed(.apartment7) {
          "The apartment block".onSelect {
            "You enter the building".then {
              .runThrough(Apartment7.Main())
            }
          }
        }
      }

      "You're back in the street"

      then { .replaceWith(self, at: .backInStreet) }
    }
  }
}
