import Narratore
import SimpleSetting

enum LookForHelp {
  static let scenes: [RawScene<SimpleStory>] = [
    Main.raw,
    Conversation.raw,
  ]

  struct Main: SceneType {
    private var typeName = Self.identifier

    var steps: Steps {
      "You start wandering about the corridors of the ground floor of this building"
      "How should you ask for help?"
      "\"Hi, please help me break into that apartment?\""
      "That doesn't really sound wise"
      "There's a big guy waling around"
      "Big is good, but it could backfire"
      "Should you be up front?"
      "Make an excuse?"
      "\"Sorry, I got locked out of my apartment\""
      "You're never been a great liar, though"
      "He's coming"
      "Here we go"
      "'Hello sir, can you help me?'"
      DO.then { .replaceWith(Conversation()) }
    }
  }

  struct Conversation: SceneType {
    typealias Anchor = Int

    var hasInformedAboutTargetDisappearance = false
    var hasLiedAboutApartment17 = false
    var canAskToBreakDownTheDoor = false

    var steps: Steps {
      DO.choose(anchor: 0) {
        let (they, _, them) = $0.world.targetPersonPronoun

        "I got locked out of my apartment".onSelect {
          .tell {
            "'I got locked out of my apartment'"
            "'What?'"
            "'I got locked out...'"
            "'I've never seen you, you live here?'"
            "'...yeah'"
            "'Since when?'"
          } then: {
            .replaceWith(self, at: 1)
          }
        }

        "I'm looking for someone".onSelect {
          .tell {
            "'I'm looking for someone'"
            "'Who?'"
            "'This person'"
            "'Hey, I know \(them)'"
            "'Yes, \(they) live here'"
            "'Are you some kind of stalker?'"
          } then: {
            .replaceWith(self, at: 5)
          }
        }
      }

      DO.choose(anchor: 1) { _ in
        "Yesterday".onSelect {
          .tell {
            "'Yesterday'"
            "'Nothing happened yesterday'"
            "'I happened yesterday'"
            "'You \"happened\" yesterday?'"
            "'It's... a joke'"
            "'Didn't get it'"
          } then: {
            .replaceWith(self, at: 10)
          }
        }

        "Some time ago".onSelect {
          .tell {
            "'Some time ago'"
            "'I've never seen you'"
            "'Yeah, you said that'"
            "'Then it's not true'"
            "'What?'"
            "You are admittedly confused already"
            "'That you live here'"
          } then: {
            .replaceWith(self, at: 2)
          }
        }

        "I don't remember".onSelect {
          .tell {
            "'I... don't remember'"
            "'You don't remember?'"
            "'I...'"
            "Let's start again"
          } then: {
            .replaceWith(self, at: 0)
          }
        }
      }

      DO.choose(anchor: 2) { _ in
        "But I do live here!".onSelect {
          .tell {
            "'But I do live here!'"
            "At this point, you're too committed to back off"
            "Let the lie continue"
            "'Ok, which apartment'"
            "'Ahem... apartment 7'"
            "'Are you sure?'"
            "'You asking if I'm sure about my apartment number?'"
            "'Yes'"
            "'I am sure'"
            "You should've backed off"
            "'Cool, I've seen the tenant yesterday, and it's definitely not you'"
          } then: {
            .replaceWith(self, at: 3)
          }
        }

        "You're right, I don't live here".onSelect {
          .tell {
            "'You're right, I don't live here'"
            "'I knew it! I'm good at remembering faces'"
            "'Bravo'"
            "'Indeed'"
            "The guy pauses for a second, then he continues"
            "'Now, should I beat you?'"
            "'Beat me?'"
            "'Yes, beat you'"
            "'Why would you do such a thing?'"
            "'Because you tricked me'"
          } then: {
            .replaceWith(self, at: 4)
          }
        }
      }

      DO.choose(anchor: 3) {
        let (_, their, them) = $0.world.targetPersonPronoun

        "'THIS tenant?'".onSelect {
          .tell {
            "'THIS tenant?' you ask, while showing \(their) photo, with complete nonchalance, like you didn't even try to trick this guy"
            "'I know \(them)'"
            "'Have you seen \(them) recently?'"
            "'Yes I... wait, you tried to trick me!'"
            "'Who, me?'"
            "'Yes, you'"
          } then: {
            .replaceWith(updating { $0.canAskToBreakDownTheDoor = true }, at: 4)
          }
        }

        if !hasLiedAboutApartment17 {
          "Sorry, I meant apartment 17".onSelect {
            .tell {
              "'Sorry, I meant apartment 17'"
              "'You're making it up'"
              "'I'm most certainly not!'"
              "'Ok, I'll bite... and since when have you lived in apartment 17?'"
            } then: {
              .replaceWith(updating { $0.hasLiedAboutApartment17 = true }, at: 1)
            }
          }
        }
      }

      DO.choose(anchor: 4) {
        let (they, _, _) = $0.world.targetPersonPronoun

        "Tricking people is part of my job".onSelect {
          .tell {
            "'Tricking people is part of my job, I'm a private investigator'"
            "'Seriously?'"
            "'Yes sir'"
            "'And what are you investigating?'"
            "'The disappearance of this person'"
            "'\(they.capitalized)'s disappeared?'"
            "'Yes sir'"
          } then: {
            .replaceWith(updating { $0.hasInformedAboutTargetDisappearance = true }, at: 10)
          }
        }

        "I'm ashamed of myself".onSelect {
          .tell {
            "'I'm sorry, I'm ashamed of myself, I shouldn't have done that'"
            "'Hey don't get yourself down'"
            "'I'm terrible at my job'"
            "'Don't say that!'"
            "'But it's true'"
            "'What it is that you want exactly?'"
          } then: {
            .replaceWith(self, at: 10)
          }
        }
      }

      DO.choose(anchor: 5) { _ in
        "I'm not \"stalking\" anybody".onSelect {
          .tell {
            "'I'm not \"stalking\" anybody, I look for people for a living'"
            "'How's that not stalking?'"
            "'I'm a private investigator'"
            "'So, a professional stalker'"
            "'What?'"
            "'You're literally being paid for stalking'"
          } then: {
            .replaceWith(self, at: 10)
          }
        }

        "I suppose I am".onSelect {
          .tell {
            "'I suppose I am, in a sense'"
            "'What sense?'"
            "'I'm a private investigator'"
            "'And what are you investigating?'"
            "'The disappearance of a person'"
            "'Seems serious'"
            "'It is'"
          } then: {
            .replaceWith(updating { $0.canAskToBreakDownTheDoor = true }, at: 10)
          }
        }
      }

      DO.choose(anchor: 10) { _ in
        "Forget about it, let's start over".onSelect {
          .tell {
            "'Forget about it, let's start over'"
          } then: {
            .replaceWith(self, at: 0)
          }
        }

        if canAskToBreakDownTheDoor {
          "Help me break down a door".onSelect {
            .tell {
              "'Can you please help me break down a door?'"

              if hasInformedAboutTargetDisappearance {
                "'The door of that person's apartment?'"
                "'Yes'"
              }

              "'Why didn't you say that immediately? I love it'"
              "'Love what?'"
              "'I actively look for opportunities to break down doors'"
              "'You do'"
              "'I love the physical sensation of overpowering a wooden door with my mere body'"
              "'Well, that's convenient'"
              "'Let's go'"
            }
          }
        }
      }

      "You go back to the door"
      "'Is this the door?' the guy asks"
      "'Yep'"
      "'Stand back'"
      "The guy smiles, then he throws himself to the door"
      "The door snaps with a resounding 'crack' sound"
      "'That was fun'"
      "The guy walks away"
      "You enter the apartment"
      DO.then { .transitionTo(Apartment7.TheApartment()) }
    }
  }
}
