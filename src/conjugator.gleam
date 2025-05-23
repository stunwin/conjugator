import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import types as t
import verbs as v

pub fn main() {
  let manger = t.Verb(infinitive: "manger", reflexive: False, ending: t.Er)
  let cuisiner = t.Verb(infinitive: "cuisiner", reflexive: False, ending: t.Er)
  let arriver = t.Verb(infinitive: "arriver", reflexive: False, ending: t.Er)
  let coucher = t.Verb(infinitive: "coucher", reflexive: True, ending: t.Er)
  echo conjugate(v.je, manger, t.Present)
  echo conjugate(v.tu, cuisiner, t.Present)
  echo conjugate(v.je, arriver, t.Present)
  echo conjugate(v.nous, arriver, t.Present)
  echo conjugate(v.il, coucher, t.Present)
}

pub fn conjugate(pronoun: t.Pronoun, verb: t.Verb, tense: t.Tense) -> String {
  let verb_string = process_verb(pronoun, verb, tense)
  let pronoun_string = process_pronoun(pronoun, verb, verb_string)

  pronoun_string <> verb_string
  // let agreement = process_agreement(pronoun_string, verb_string)
}

pub fn process_pronoun(
  pronoun: t.Pronoun,
  verb: t.Verb,
  verb_string: String,
) -> String {
  let pronoun_string = case verb.reflexive {
    True -> pronoun.string <> " " <> pronoun.reflexive
    False -> pronoun.string
  }

  let pronoun_vowel =
    vowel_check(result.unwrap(
      string.last(pronoun_string),
      "pronoun vowel error ",
    ))
  let verb_vowel =
    vowel_check(result.unwrap(string.first(verb_string), "verb vowel error "))

  case pronoun_vowel, verb_vowel {
    True, True -> string.drop_end(pronoun_string, 1) <> "'"
    _, _ -> pronoun_string <> " "
  }
}

pub fn vowel_check(letter: String) -> Bool {
  case letter {
    "a" | "e" | "i" | "o" | "u" -> True
    _ -> False
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
  list.find(v.conjugations, fn(x) {
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
//   list.find(v.er_present.suffixes, fn(x){case x {
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
