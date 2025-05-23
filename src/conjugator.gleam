import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import types as t
import verbs

pub fn main() {
  let manger = t.Verb(infinitive: "manger", reflexive: False, ending: t.Er)
  let cuisiner = t.Verb(infinitive: "cuisiner", reflexive: False, ending: t.Er)
  let arriver = t.Verb(infinitive: "arriver", reflexive: False, ending: t.Er)
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
  let suffixlist = select_suffix_list(verb, tense)
  case suffixlist {
    Ok(x) if x.ending == t.Irregular -> irregular_endings(x, pronoun:, verb:)
    Ok(x) -> regular_endings(x, pronoun:, verb:)
    _ -> "problemo, homie"
  }
}

fn select_suffix_list(verb: t.Verb, tense: t.Tense) {
  list.find(verbs.conjugations, fn(x) {
    x.tense == tense && x.ending == verb.ending
  })
}

fn regular_endings(
  suffixlist: t.ConjugationPattern,
  pronoun pronoun: t.Pronoun,
  verb verb: t.Verb,
) -> String {
  //first decide which ending we're working with

  //grab the verb and strip the last two letters
  let root = string.drop_end(verb.infinitive, 2)
  // find the ending from a list using the pronoun
  let match = list.find(suffixlist.suffixes, fn(x) { x.0 == pronoun })
  //grab the ending out of that last
  let ending = case match {
    Ok(#(_, x)) -> x
    _ -> "error"
  }
  root <> ending
}

fn irregular_endings(
  suffixlist,
  pronoun pronoun: t.Pronoun,
  verb verb: t.Verb,
) -> String {
  "irregular guy"
}
//   list.find(verbs.er_present.suffixes, fn(x){case x {
//   #(x, _) if x == pronoun -> True
//   #(_, _) -> False
// }})

// fn conjugate_futur_proche(pronoun pronoun: Pronoun, verb verb: Verb) -> String {
//   todo
// }
//
// fn conjugate_passe_compose(pronoun pronoun: Pronoun, verb verb: Verb) -> String {
//   todo
// }
