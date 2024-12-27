import Narratore
import SimpleSetting

enum Apartment7 {
  static let scenes: [RawScene<SimpleStory>] = [
    Main.raw,
    TheApartment.raw,
  ]

  struct Main: SceneType {
    enum Anchor: Codable, Hashable, Sendable {
      case atTheDoor
    }

    var breakTheDoorCounter: Int = 0

    var steps: Steps {
      "You get to apartment 7"

      tell {
        if !$0.world.didDescribeTheApartment7Door {
          "The door looks different than other doors"
          "It has the same \"moldy\" look as the building facade"
          "You think that even if you didn't get a lead about apartment 7, this door would probably have look suspicious in any case"
        }
      } update: {
        $0.didDescribeTheApartment7Door = true
      }

      "The door is locked".with {
        $0.wasTheDoorClosed = true
      }

      choose(.atTheDoor) {
        if $0.world.wasTheKeyFound {
          "Open the door with the key".onSelect {
            .tell {
              "You put the key in the locket and turn it counterclockwise"
              "The door unlocks"
              "You feel happy, and enter the apartment"
            } then: {
              .transitionTo(TheApartment())
            }
          }
        }

        switch breakTheDoorCounter {
        case 0:
          "Try to break down the door".onSelect {
            .tell {
              "You try break down the door with a push"
              "The door doesn't bulge"
            } then: {
              .replaceWith(updating { $0.breakTheDoorCounter = 1 }, at: .atTheDoor)
            }
          }

        case 1:
          "Try to break down the door again".onSelect {
            .tell {
              "You try again"
              "You're pushing as hard as you can, but your \"build\" is not exactly one of a door-breaker"
            } then: {
              .replaceWith(updating { $0.breakTheDoorCounter = 2 }, at: .atTheDoor)
            }
          }

        case 2:
          "Keep pushing".onSelect {
            .tell {
              "You're basically hurting yourself"
              "It almost feels like the door is made of granite"
              "But it's more likely that you're body is made of jelly"
            } then: {
              .replaceWith(updating { $0.breakTheDoorCounter = 3 }, at: .atTheDoor)
            }
          }

        default:
          "Look for help".onSelect {
            .tell {
              "You simply can't break the door down"
              "Maybe you should look for help"
              "It's going to be weird to ask someone to help you break into an apartment"
              "But you don't see many alternatives"
            } then: {
              .replaceWith(LookForHelp.Main())
            }
          }
        }

        "Go back in the street".onSelect {
          .tell {
            "You decide to exit the building"
          }
        }
      }
    }
  }

  struct TheApartment: SceneType {
    private var typeName = Self.identifier

    var steps: Steps {
      "It's really dark, the windows are shut, and the lights don't work"
      "You activate the flashlight on your smartphone, but the battery is almost dead, it's not going to last long"
      "You ask if someone is there, with a voice loud enough to be clearly heard within the apartment, but not so that would disturb the neighbors"
      "There seems to be no one around, though"
      "The apartment itself is a mess"
      "There's books everywhere, some probably from the bookshop"
      "But no clear clue of where's the person you're looking for"

      tell {
        if Deduction.allCases.allSatisfy($0.world.hasDeduced) {
          "But everything leads here"
          "The target moved to this neighborhood because of that peculiar bookshop"
          "The target is interested in books about occult rituals"
          "The target is feeding something from a hole in the street close to this apartment"
          "It must be it"
        }
      }

      choose {
        let (_, their, _) = $0.world.targetPersonPronoun

        "This must be \(their) apartment".onSelect {
          .tell {
            "This must be \(their) apartment"
            "Everything leads to this"
            "You must trust your instinct"
          } update: {
            $0.increaseMentalHealth()
          }
        }

        "Maybe this is not \(their) apartment".onSelect {
          .tell {
            "Maybe this is not \(their) apartment"
            "You have some doubts now"
            "You feel tired"
            "You not trusting your judgement so much anymore"
            "But this is the only lead"
          } update: {
            $0.decreaseMentalHealth()
          }
        }
      }

      checkMentalHealth()

      "You push yourself deeper into the apartment"
      "You decide to decrease the intensity of the flashlight, as to preserve battery"
      "Then you reach a strange door: it's open, but the insides are completely dark"
      "You get closer, and start hearing some kind of \"humming\", probably coming from the door"
      "You look in: it seems like an elevator shaft, but with no elevator, and a ladder going down"
      "You have no choice here: you decide to go down the ladder"
      "Keeping an eye on the smartphone battery"
      "There's some kind of basement, and the floor is slippery"
      "The humming intensifies, it clearly comes form here"
      "You start exploring the darkness of this place"
      "It's like a very large room, with columns, probably supporting the building above"

      choose { _ in
        "Turn off the flashlight".onSelect {
          .tell {
            "You temporarily turn off the flashlight, to look for sources of light"
            "A faint light comes from one of sides of the room"
            "You go towards the light"
          }
        }

        "Increase the flashlight intensity".onSelect {
          .tell {
            "You temporarily increase the flashlight intensity, to look for clues"
            "There seems to be a table near one the side of the room"
            "You go towards it"
          } update: {
            $0.didDepleteTheBatteryFaster = true
          }
        }
      }

      "You see an empty wooden table"
      "There's a drawer; you open it, and there'a rusty key inside"
      "You take the key: there must be some door around"
      "On the ceiling, a small hole, from which it drips a gooey substance"

      tell {
        if $0.world.wasTheSlimyGooeySubstanceObservedInTheDarkAlley {
          "It must be the same substance you found in the dark alley"
          "And this must be that hole"
          "This means that the target was \"feeding\" something with those beans"
          "And this \"something\" must be here, in this basement"
        }
      }

      "You go look for the door, scouting the perimeter of this basement"
      "The wall is dirty and moldy, but not like those of abandoned basements"
      "It almost looks like someone did this on purpose"

      check {
        .inCase($0.world.didDepleteTheBatteryFaster) {
          .tell {
            "Your smartphone battery runs off"
            "You're left in the dark"
            "You can only feel the walls, while looking for the door"
          } update: {
            $0.decreaseMentalHealth()
          }
        }
      }

      checkMentalHealth()

      "You keep going"
      "After turning a corner, you finally find a door"
      "It's a wooden door, seems extremely old, and not really appropriate for this building"
      "The door is locked"
      "You unlock it with the key"
      "You enter, and notice a light switch with a small red led attached"
      "You turn the switch on, and a alien, artificial white light hits your eyes"
      "There'a corridor, of modern making, with plain white walls, floor and ceiling"
      "The corridor is rather long, it with several weird and unexplained corners"
      "It's almost like the corridor is spiraling around a room, with the spires getting smaller and smaller"
      "At the end, and opening on the side"
      "You cross the opening"
      "There's a small room"
      "You widen your eyes"
      "You try to understand what you're seeing"
      "There'a strange, vaguely anthropomorphic creature, in the middle of the room"
      "Sitting on a chair"
      "Near the creature, \"something\" is working"
      "Almost like a barber shop, where the barber is an unexplained entity"
      "The entity turns towards you"
      "You feel frozen"
      "You heart is pounding"
      "You're sweating, you're terrified, but you can't move"
      "You can't really describe the entity with words"
      "You can only think that it probably was your target, once"
      "The missing person"
      "But it's not a person anymore"
      "It's like a small child, with fervid imagination, tried to draw a person with pencils, in the most abstract way possible"
      "It doesn't even really \"move\", it's more like it changes configuration in steps, snapping in place each time"
      "Or maybe you're becoming crazy"
      "And where its face should be, there's a abstract paint"
      "With vague human features"
      "You feel faint"
      "You're passing out"
      "But not due to the terror"
      "A new world is opening in front of your eyes"
      "A vast, secret new world"
      "And you can't take it"
      "You can't take it..."
      "..."
      "..."
      "..."
    }
  }
}

extension SimpleStory.World {
  fileprivate var didDescribeTheApartment7Door: Bool {
    get {
      value["didDescribeTheApartment7Door"] == .positive
    }
    set {
      value["didDescribeTheApartment7Door"] = newValue ? .positive : .negative
    }
  }

  fileprivate var didDepleteTheBatteryFaster: Bool {
    get {
      value["didDepleteTheBatteryFaster"] == .positive
    }
    set {
      value["didDepleteTheBatteryFaster"] = newValue ? .positive : .negative
    }
  }
}
