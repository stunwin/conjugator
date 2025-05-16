import gleam/io
import gleam/option.{type Option}
import gleam/result
import gleam/string

pub type Verb {
  Er(infinitive: String, reflexive: Bool, definition: String)
  Ir(infinitive: String, reflexive: Bool, definition: String)
  Re(infinitive: String, reflexive: Bool, definition: String)
  Irregular(infinitive: String, reflexive: Bool, definition: String)
}

pub type Tense {
  Present
  PasseCompose(aux: Verb)
  FuturProche
}

pub type Pronoun {
  Je(gender: Gender)
  Tu(gender: Gender)
  Il
  Elle
  Nous(gender: Gender)
  Vous(gender: Gender)
  Ils
  Elles
}

pub type Noun {
  Noun(
    french: String,
    english: String,
    gender: Gender,
    countable: Bool,
    plural: Bool,
  )
}

pub type Gender {
  M
  F
}

pub fn main() {
  let manger = Er(infinitive: "manger", reflexive: False, definition: "to eat")
  let cuisiner =
    Er(infinitive: "cuisiner", reflexive: False, definition: "to eat")
  let arriver =
    Er(infinitive: "arriver", reflexive: False, definition: "to eat")
  echo conjugate(Je(M), manger, Present)
  echo conjugate(Tu(M), cuisiner, Present)
  echo conjugate(Je(M), arriver, Present)
  echo conjugate(Nous(M), arriver, Present)
}

pub fn conjugate(pronoun: Pronoun, verb: Verb, tense: Tense) -> String {
  let pronoun_string = process_pronoun(pronoun, verb)
  let verb_string = process_verb(pronoun, verb, tense)

  pronoun_string <> verb_string
  // let agreement = process_agreement(pronoun_string, verb_string)
}

pub fn process_pronoun(pronoun: Pronoun, verb: Verb) -> String {
  let first_vowel = case result.unwrap(string.first(verb.infinitive), "X") {
    "a" | "e" | "i" | "o" | "u" -> True
    _ -> False
  }

  case pronoun, first_vowel {
    Je(_), False -> "je "
    Je(_), True -> "j'"
    Tu(_), _ -> "tu "
    Il, _ -> "il "
    Elle, _ -> "elle "
    Nous(_), _ -> "nous "
    Vous(_), _ -> "vous "
    Ils, _ -> "ils "
    Elles, _ -> "elles "
  }
}

pub fn process_verb(pronoun: Pronoun, verb: Verb, tense: Tense) -> String {
  case tense {
    Present -> conjugate_present(pronoun:, verb:)
    PasseCompose(_) -> conjugate_passe_compose(pronoun:, verb:)
    FuturProche -> conjugate_futur_proche(pronoun:, verb:)
  }
}

fn conjugate_futur_proche(pronoun pronoun: Pronoun, verb verb: Verb) -> String {
  todo
}

fn conjugate_passe_compose(pronoun pronoun: Pronoun, verb verb: Verb) -> String {
  todo
}

fn conjugate_present(pronoun pronoun: Pronoun, verb verb: Verb) -> String {
  let root = string.drop_end(verb.infinitive, 2)
  case verb {
    Er(..) ->
      case pronoun {
        Je(_) -> root <> "e"
        Tu(_) -> root <> "es"
        Il -> root <> "e"
        Elle -> root <> "e"
        Nous(_) -> root <> "ons"
        Vous(_) -> root <> "enz"
        Ils -> root <> "ent"
        Elles -> root <> "ent"
      }
    Ir(..) -> "ir verb"
    Re(..) -> "re verb"
    Irregular(..) -> "irregular verb"
  }
}
