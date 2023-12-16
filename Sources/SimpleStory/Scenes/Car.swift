import Narratore
import SimpleSetting

public struct Car: SceneType {
  public init() {}

  public var steps: Steps {
    requestText {
      "What's your name?"
    } validate: { text in
      if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        .valid(.init(text: text))
      } else {
        .invalid("[Invalid input, please retry]")
      }
    } ifValid: { _, validated in
      tell {
        "\(validated.text)? I like it"
        "OK, let's start"
      }
    }

    "You wake up from an unusual dream"
    "You were under the sea, walking on the ground as if there was no pull to the surface, nor any resistance from the water itself"
    "But you were definitely under the sea, fishes and everything, and the light of the sun reflected on the shimmering water surface, creating a dream-like movement"
    "In fact, it was a dream, and you were walking, but you don't remember towards what"
    "A strange light, or maybe a darkness, lined the horizon, while you felt a pull towards something unknown"
    "Then something happened, something filled your eyes, a creature maybe, swimming through the underwater currents"
    "You try to remember what the creature looked like.."

    choose { _ in
      "Some kind of alien?".onSelect {
        tell {
          "...then it comes to your mind: it was some kind of alien being"
          "An alien 'entity' could describe it better"
          "Eerie, otherworldly"
          "You sure have a great imagination, and a great knowledge of eldritch words"
          "Including 'eldritch'"
        } update: {
          $0.theCreatureLookedLike = .anAlienBeing
        }
      }

      "Looked like a fish!".onSelect {
        tell {
          "...and, unsurprisingly, it looked like a large fish"
          "You don't know much about fish: you barely know that there's a distinction between saltwater and freshwater"
          "Maybe, in the future, if you see a picture of that particular fish, the dream will come back to your mind"
          "But for now, better not to linger"
        } update: {
          $0.theCreatureLookedLike = .aFish
        }
      }

      "I don't know..".onSelect {
        tell {
          "...but you really don't"
          "You think about some kind of formless dark shadow"
          "But you don't struggle that much: it was just a dream, no use in wasting mental energy in trying to remember what naturally fades away"
        } update: {
          $0.theCreatureLookedLike = .aDarkShadow
        }
      }
    }

    check {
      if $0.world.theCreatureLookedLike == .anAlienBeing {
        "While your spirit enjoys the idea of an underwater alien haunting your dreams, your mind really doesn't"
          .with(tags: [.init("You feel scared, all of a sudden")]) {
            $0.decreaseMentalHealth()
          }
      }
    }

    checkMentalHealth()

    "You're in your car, it's late evening"
    "The car is off, parked on the side of the road, in front of a closed animal shop"
    "Your contact told you that this time would be the perfect time to look for that missing person"
    "..."
    "..."
    "..."
    "What person? Who are you?"
    "You dozed off pretty heavily, and the sound of falling rain didn't help in staying awake"

    choose { _ in
      "You had trouble sleeping recently".onSelect {
        tell(tags: [.init("You feel a sense of unease")]) {
          "You had trouble sleeping recently"
          "So the fact that you actually took a nap in late afternoon is rather weird"
          "What happened?"
          "You suddenly feel a sense of unease"
        } update: {
          $0.decreaseMentalHealth()
        }
      }

      "You usually only sleep at night".onSelect {
        tell(tags: [.init("You feel, unexpectedly, refreshed")]) {
          "You usually only sleep at night"
          "Napping in late afternoon is not something you do"
          "But actually, you liked the idea"
          "Was it a \"power nap\"? Not sure"
          "But you feel a sense of accomplishment"
        } update: {
          $0.increaseMentalHealth()
        }
      }

      "You use any opportunity to take a nap".onSelect {
        tell {
          "You use any opportunity to take a nap"
          "Nothing to see here, then"
        }
      }
    }

    checkMentalHealth()

    "Now, focus: who are you?"
    "..."
    "..."
    "..."
    "Reality is coming back at you"
    "You're a private investigator, and your current job is to look for a certain person, whose photograph is safely in your pocket"
    "By asking around, you discovered that the target could be in this neighborhood"
    "You look at the photograph"

    choose { _ in
      "A man".onSelect {
        "An anonymously looking man, in his thirties".with {
          $0.value[.targetPersonSex] = .male
        }
      }

      "A woman".onSelect {
        "An anonymously looking woman, in her thirties".with {
          $0.value[.targetPersonSex] = .female
        }
      }
    }

    tell {
      let (they, their, them) = $0.world.targetPersonPronoun

      "One of you contacts told you to have seen \(them) walking around here, about this hour in the evening, carrying what looked like a tower of books on \(their) hands"
      "The target didn't look in danger, or distressed in any way"
      "You suspect that \(they) actually wanted to get away from home"
      "But the parents are paying well"
      "They didn't tell you much about the target: \(they) seems interested in esoteric religions and occult rituals, and you knew that this part of town was the weirdest one when in comes to spiritual matters"
      "So, you knew who to ask, and where to look like, at least in general"
    }

    "It's time to get out of the car, and start looking around"

    then { .transitionTo(Street.Main()) }
  }
}
