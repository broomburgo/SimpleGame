import Narratore
import SimpleSetting

enum Bookshop {
  static let scenes: [RawScene<SimpleStory>] = [
    Main.raw,
    ShowPhoto.raw,
    ShowPhotoAgain.raw,
    AboutTheShop.raw,
    TheFeelingShop.raw,
  ]

  enum Status: Codable {
    case regular
    case trashed
  }

  struct Main: SceneType {
    enum Anchor: Codable & Hashable {
      case askQuestions
    }

    var status: Status = .regular

    var steps: Steps {
      switch status {
      case .regular:
        "The bookshop is barely lit, with some fake candles on the top shelves projecting a faint, shimmering light"
        "There's lots of bookshelves, some full of books, some almost empty"

        tell {
          if !$0.script.didNarrate(.didMeetTheOwner) {
            "You don't see people in the store"
            "You're quite sure, because you easily see through the empty shelves"
            "You get the idea that the owner must be rather messy"
            "Maybe one of those old librarian types, old, curved, with glasses, and incapable of listening to whoever is speaking to them for more that 10 seconds"
            "Or maybe a young boy or girl, with their head in the clouds, proud of being the only person on this planet to be able to navigate this mess"
            "Or maybe is better to call for someone, instead of guessing who the owner is"
            "'Is anybody around?', you ask, loudly"
            "No response"
            "'Anyone?'"
            "Nope"
            "'Come on, there must...'"
            "'I'm here, I'm here', you hear a voice coming from the back of the store"
            "You don't see anybody, and decide to venture further into the store"
            "'Come closer...'"
            "You feel a little uneasy"
            "Seriously, where is this voice coming from?"
            "You arrive to the desk, or at least you think it's a desk"
            "Piles of books, paper sheets, various colorful office supplies, and lots of plain garbage is amassed on the desk"
            "'Hello?'"
            "'I'm under the desk'"
            "An old man emerges from the desk, behind a pile of books that might or might not be about botanics"

            "'Yes?'".with(id: .didMeetTheOwner)
          }
        }

        "You take out the photo, and get near the owner"

        choose(.askQuestions) {
          if $0.script.didNarrate(.didShowPhotoOnce) {
            "Show photo again".onSelect {
              .tell {
                "You show the photo to the owner one more time"
              } then: {
                .runThrough(ShowPhotoAgain())
              }
            }
          } else {
            "Show photo".onSelect {
              .tell {
                "You show the photo to the owner".with(id: .didShowPhotoOnce)
              } then: {
                .runThrough(ShowPhoto())
              }
            }
          }

          if !$0.script.didNarrate(.didWitnessALargerWorld) {
            "Ask about the shop".onSelect {
              .tell {
                "'How's the shop doing?'"
              } then: {
                .runThrough(AboutTheShop())
              }
            }
          }

          "Ask about the neighborhood".onSelect {
            .tell {
              "'Is this a good neighborhood?'"
              "'It is, a guess.'"
              "You're mildly surprised by the straightforward answer"
              "You sort of expected some more fruitless ramblings"
              "'I wouldn't worry about the neighborhood.'"
              "'There's worse things out there than annoying neighbors.'"
            }
          }
        }

        "You think about your next steps"

        choose { _ in
          "Ask more questions".onSelect {
            .tell {
              "Maybe you should ask a few more questions"
            } then: {
              .replaceWith(self, at: .askQuestions)
            }
          }

          "Leave".onSelect {
            .tell {
              "Thank you for your time sir"
            }
          }
        }

      case .trashed:
        "The place is a mess"
        "And you don't see the owner"
        "What they were looking for?"
        "Maybe some books"
        "You go towards the counter"
        "Something shiny catches you eye"
        "It's a key"
        "The key holder says 'Apartment 7'".with {
          $0.wasTheKeyFound = true
        }

        check {
          if $0.world.hasDiscovered(.apartment7) {
            .tell {
              "It's likely the key to the apartment in that apartment block"
            }
          } else {
            .tell {
              "You did notice an apartment block, next to the grocery store"
              "You should go take a look"
            } update: {
              $0.didDiscover(.apartment7)
            }
          }
        }

        check {
          .inCase($0.world.wasTheDoorClosed) {
            .tell {
              "The door was closed, but now you have a key to enter"
            }
          }
        }
      }
    }
  }

  struct ShowPhoto: SceneType {
    private var typeName = Self.identifier

    var steps: Steps {
      "'Have you seen this person?'"
      "'mmm...'"
      "'Let me take a look...'"
      "'mmm...'"
      "Your arm is hurting from keeping the photo up"
      "'mmm...'"
      "Still no response"
      "'mmm...'"
      "'Sir?'"
      "'mmm...'"

      "Ok, now your arm hurt real bad".with(tags: [.init("You feel pain in your arm")]) {
        $0.decreaseMentalHealth()
      }

      checkMentalHealth()

      "You lower the photo"
      "'Hey, I was looking at that!'"
      "You feel a sudden urge to punch someone"
      "And you have, in fact, someone in front of you"
      "But you're in the private investigation business for the long run, so you contain the urge"

      tell {
        let (they, _, them) = $0.world.targetPersonPronoun

        "'I've seen \(them), of course I did, \(they)'s been here many times last week.'"
        "Actually, \(they) needs to return some books"
        "Can you tell \(them) if you see \(them)?"
        "Be a dear..."
      }

      "You think about the fact that you're not liking this exchange, it doesn't seem fruitful"
      "The bookshop owner is not really giving you more info that what you could have guessed by the simple fact that your target recently moved to this neighborhood, and was seen with lots of books"

      choose {
        let (they, their, _) = $0.world.targetPersonPronoun

        "\(they.capitalized) wanted a place off the beaten path, to hide \(their) books".onSelect {
          .tell {
            "\(they.capitalized) wanted a place off the beaten path, to hide \(their) books"
            "The fact that a bookshop is here is a coincidence"
            "This conversation isn't going anywhere"
          }
        }

        "\(they.capitalized) intends to sell the books to the bookshop".onSelect {
          .tell {
            "\(they.capitalized) intends to sell to books to the bookshop"
            "And \(they)'s borrowing some books, to befriend the bookshop owner"
            "It must be it"
          }
        }

        "\(they.capitalized) wanted to buy some books that only this shop sells".onSelect {
          .tell {
            "\(they.capitalized) wanted to buy some books that only this shop sells"
            "This is probably the reason why \(they) moved here in the first place"
            "The bookshop is the key"
          } update: {
            $0.didDeduce(.targetMovedToNeighborhoodBecauseOfBookshop)
          }
        }
      }

      "'Are you still here?'"
      "The bookshop owner looks at you, slightly puzzled"
      "'I don't have time to lose, you know?"
    }
  }

  struct ShowPhotoAgain: SceneType {
    private var typeName = Self.identifier

    var steps: Steps {
      "'Have you seen this person?'"
      "'Pretty sure you already asked me that.'"
      "'I forgot the answer'"

      tell {
        let (they, _, them) = $0.world.targetPersonPronoun

        "'There's no answer, and don't know where \(they) is, but if you find \(them), please ask about my books'"
      }

      "'What books are we talking about anyway?'"
      "'The kind of books I usually sell.'"
      "'Go on.'"
      "'Where?'"
      "'What?'"
      "'Go on where?'"
      "'No I mean...'"
      "'Why don't you go on, on the street outside?'"
      "'I mean, what kind of books do you usually sell?'"

      "'Ancient books, about magic, occult rituals, demonic entities, this kind of stuff.'".with {
        $0.didDeduce(.targetIsInterestedInBooksAboutOccultRituals)
      }

      "The bookshop owner seems annoyed, like he was taking about the most obvious, mundane thing in the world"
      "Apparently, in this part of town, selling tomes about demonic entities is comparable to selling self-help books"
    }
  }

  struct AboutTheShop: SceneType {
    private var typeName = Self.identifier

    var steps: Steps {
      "'What do you mean?'"
      "'The shop, is doing fine?'"
      "'It's a bookshop, it doesn't feel emotions.'"

      check {
        .inCase($0.script.didNarrate(.didThinkAboutTheBookshopFeelings)) {
          .tell {
            "(or does it?)"
          }
        }
      }

      "You don't really know how to respond to that.."
      "...but you start thinking about what emotions a bookshop would feel if it COULD"
      "..."
      "It would probably feel \"dirty\", given how many people scroll through the pages of random books, before putting them back".with(id: .didThinkAboutTheBookshopFeelings)

      check {
        if $0.script.narrated[.didThinkAboutTheBookshopFeelings, default: 0] >= 3 {
          .tell {
            "..."
          } then: {
            .replaceWith(TheFeelingShop())
          }
        } else {
          .tell {
            "Let's discard this thought.."
            "..."
            "...for now"
          }
        }
      }
    }
  }

  struct TheFeelingShop: SceneType {
    private var typeName = Self.identifier

    var steps: Steps {
      "You really like this idea of a feeling bookshop, don't you?"
      "Let me indulge you"
      "You take a deep breath"
      "Clear you mind"
      "Find you center"
      "Focus your awareness"
      "You can feel it now"
      "The bookshop is talking to you"

      tell {
        let (they, their, them) = $0.world.targetPersonPronoun

        "I'VE SEEN \(them.uppercased())"
        "I KNOW \(them.uppercased())"
        "\(they.uppercased()) WILL CALL IT"
        "IT WILL CHANGE \(them.uppercased())"
        "\(their.uppercased()) BODY WILL BE DECONSTRUCTED"
        "\(their.uppercased()) SHAPE WILL BE INVERTED"
        "YOU WILL SEE"
        "GO TO APARTMENT 7"
      }

      "..."
      "..."
      "..."
      "You take a deep breath"
      "You're back"
      "You have no idea what just happened"
      "You never felt anything like it"
      "It was like being in the Matrix, and getting a glimpse of the true reality"
      "But just for an instant"
      "Just for an instant, you felt like being in a much larger world".with(id: .didWitnessALargerWorld)
      "An unseen plane of existence"
      "You felt like.."
      "A black dot on a piece of paper, that just for an instant.."
      "...jumps out of the paper.."
      "...and witnesses the 3D reality, before going back to its familiar 2D world"
      "Now, you're back in yours"
      "..."
      "..."
      "Apartment 7?"
      "You did notice an apartment block, next to the grocery store"
      "You should go take a look".with {
        $0.didDiscover(.apartment7)
      }
    }
  }
}

extension SimpleStory.Message.ID {
  fileprivate static let didMeetTheOwner: Self = "didMeetTheOwner"
  fileprivate static let didShowPhotoOnce: Self = "didShowPhotoOnce"
  fileprivate static let didThinkAboutTheBookshopFeelings: Self = "didThinkAboutTheBookshopFeelings"
  fileprivate static let didWitnessALargerWorld: Self = "didWitnessALargerWorld"
}
