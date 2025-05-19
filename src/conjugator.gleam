import gleam/io
import gleam/option.{type Option}
import gleam/result
import gleam/string
import types as t
import verbs

pub fn main() {
  echo verbs.er_present

  let manger =
    t.Er(infinitive: "manger", reflexive: False, definition: "to eat")
  let cuisiner =
    t.Er(infinitive: "cuisiner", reflexive: False, definition: "to eat")
  let arriver =
    t.Er(infinitive: "arriver", reflexive: False, definition: "to eat")
  echo conjugate(t.Je(t.M), manger, t.Present)
  echo conjugate(t.Tu(t.M), cuisiner, t.Present)
  echo conjugate(t.Je(t.M), arriver, t.Present)
  echo conjugate(t.Nous(t.M), arriver, t.Present)
}

pub fn conjugate(pronoun: t.Pronoun, verb: t.Verb, tense: t.Tense) -> String {
  let pronoun_string = process_pronoun(pronoun, verb)
  let verb_string = process_verb(pronoun, verb, tense)

  pronoun_string <> verb_string
  // let agreement = process_agreement(pronoun_string, verb_string)
}

pub fn process_pronoun(pronoun: t.Pronoun, verb: t.Verb) -> String {
  let first_vowel = case result.unwrap(string.first(verb.infinitive), "X") {
    "a" | "e" | "i" | "o" | "u" -> True
    _ -> False
  }

  case pronoun, first_vowel {
    t.Je(_), False -> "je "
    t.Je(_), True -> "j'"
    t.Tu(_), _ -> "tu "
    t.Il, _ -> "il "
    t.Elle, _ -> "elle "
    t.Nous(_), _ -> "nous "
    t.Vous(_), _ -> "vous "
    t.Ils, _ -> "ils "
    t.Elles, _ -> "elles "
  }
}

pub fn process_verb(pronoun: t.Pronoun, verb: t.Verb, tense: t.Tense) -> String {
  case tense {
    t.Present -> conjugate_present(pronoun:, verb:)
    // t.PasseCompose(_) -> conjugate_passe_compose(pronoun:, verb:)
    // t.FuturProche -> conjugate_futur_proche(pronoun:, verb:)
    _ -> ""
  }
}

fn conjugate_present(pronoun pronoun: t.Pronoun, verb verb: t.Verb) -> String {
  let root = string.drop_end(verb.infinitive, 2)
  case verb {
    t.Er(..) ->
      case pronoun {
        t.Je(_) -> root <> "e"
        t.Tu(_) -> root <> "es"
        t.Il -> root <> "e"
        t.Elle -> root <> "e"
        t.Nous(_) -> root <> "ons"
        t.Vous(_) -> root <> "enz"
        t.Ils -> root <> "ent"
        t.Elles -> root <> "ent"
      }
    t.Ir(..) -> "ir verb"
    t.Re(..) -> "re verb"
    t.Irregular(..) -> "irregular verb"
  }
}
// fn conjugate_futur_proche(pronoun pronoun: Pronoun, verb verb: Verb) -> String {
//   todo
// }
//
// fn conjugate_passe_compose(pronoun pronoun: Pronoun, verb verb: Verb) -> String {
//   todo
// }
