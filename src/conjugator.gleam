import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import types as t
import verbs as v

pub fn main() {
  let manger = t.Verb(infinitive: "manger", ending: t.Er)
  let cuisiner = t.Verb(infinitive: "cuisiner", ending: t.Er)
  let arriver = t.Verb(infinitive: "arriver", ending: t.Er)
  let coucher = t.Verb(infinitive: "coucher", ending: t.Er)
  let imaginer = t.Verb(infinitive: "imaginer", ending: t.Er)
  let promener = t.Verb(infinitive: "promener", ending: t.Er)
  let aller = t.Verb(infinitive: "aller", ending: t.Irregular)

  let test1 =
    t.Context(
      pronoun: v.je,
      verb: get_verb("manger"),
      tense: t.Present,
      is_reflexive: False,
      is_negated: False,
    )
  let test2 =
    t.Context(
      pronoun: v.nous,
      verb: get_verb("aller"),
      tense: t.Present,
      is_reflexive: False,
      is_negated: False,
    )
  let test3 =
    t.Context(
      pronoun: v.je,
      verb: get_verb("manger"),
      tense: t.FuturProche,
      is_reflexive: False,
      is_negated: False,
    )

  echo conjugate(test1)
  echo conjugate(test2)
  echo conjugate(test3)
  // echo conjugate(v.tu, cuisiner, t.Present, reflexive: False, negated: False)
  // echo conjugate(v.je, arriver, t.Present, reflexive: False, negated: False)
  // echo conjugate(v.nous, arriver, t.Present, reflexive: False, negated: False)
  // echo conjugate(v.il, coucher, t.Present, reflexive: True, negated: False)
  // echo conjugate(v.il, imaginer, t.Present, reflexive: True, negated: True)
}

pub fn get_verb(input: String) -> t.Verb {
  let verbdict = dict.from_list(v.verblist)
  let assert Ok(verb) = dict.get(verbdict, input)
  verb
}

pub fn conjugate(context: t.Context) -> String {
  case get_sentence_structure(context) {
    Ok(sentence_order) -> Ok(build_sentence(sentence_order, context))
    _ -> Error(Nil)
  }
  |> result.unwrap("error getting sentence structure")
}

fn get_sentence_structure(context: t.Context) -> Result(t.SentenceOrder, Nil) {
  list.find(v.sentences, fn(x) {
    x.tense == context.tense
    && x.is_reflexive == context.is_reflexive
    && x.is_negated == context.is_negated
  })
}

fn build_sentence(sentence: t.SentenceOrder, context: t.Context) -> String {
  list.map(sentence.grammar_units, fn(x) {
    case x {
      t.Pronoun -> context.pronoun.string
      t.ReflexivePronoun -> context.pronoun.reflexive
      t.MainVerb(t.Conjugated) -> process_verb(context)
      t.MainVerb(t.Infinitive) -> context.verb.infinitive
      t.MainVerb(t.Participle) -> process_participle(context)
      t.AuxiliaryVerb -> {
        let aux_verb = select_aux(context)
        let context = t.Context(..context, tense: t.Present, verb: aux_verb)
        process_verb(context)
      }
      t.Ne -> "ne"
      t.Pas -> "pas"
      t.Object -> "object"
    }
  })
  |> join_sentence()
}

fn process_participle(context: t.Context) -> String {
let root = string.drop_end(context.verb.infinitive, 2) 
  case context.tense {
t.PasseCompose -> case context.verb.ending { 
      t.Er -> 
// TODO: this is where we left off. need to figur eout what order to make these decisions in 
}
  }
}

fn select_aux(context: t.Context) -> t.Verb {
  case context.tense {
    t.FuturProche -> get_verb("aller")
    t.PasseCompose ->
      case list.contains(v.passe_compose_etre_verbs, context.verb.infinitive) {
        True -> get_verb("etre")
        False -> get_verb("avoir")
      }
    _ -> get_verb("manger")
  }
}

/// this function both joins and looks for elisions 
fn join_sentence(sentence: List(String)) -> String {
  case sentence {
    [first, second, ..rest] ->
      elision_check(first, second) <> join_sentence([second, ..rest])
    [lastword] -> lastword
    _ -> "something happened during elision"
  }
}

fn elision_check(first: String, second: String) -> String {
  let firstend =
    vowel_check(string.last(first) |> result.unwrap("first word elision error"))
  let secondstart =
    vowel_check(
      string.first(second) |> result.unwrap("second word elision error"),
    )
  case firstend, secondstart {
    True, True -> string.drop_end(first, 1) <> "'"
    _, _ -> first <> " "
  }
}

pub fn vowel_check(letter: String) -> Bool {
  case letter {
    "a" | "e" | "i" | "o" | "u" -> True
    _ -> False
  }
}

pub fn process_verb(context: t.Context) -> String {
  case select_suffix_list(context) {
    Ok(x) -> select_verb_ending(x, context)
    _ -> "error finding suffix list"
  }
}

fn select_suffix_list(context: t.Context) -> Result(t.ConjugationPattern, Nil) {
  case context.verb.ending {
    t.Irregular ->
      list.find(v.conjugations, fn(x) {
        x.tense == context.tense
        && list.key_find(x.suffixes, v.infinitive)
        == Ok(context.verb.infinitive)
      })
    _ ->
      list.find(v.conjugations, fn(x) {
        x.tense == context.tense && x.ending == context.verb.ending
      })
  }
}

fn select_verb_ending(
  suffixlist: t.ConjugationPattern,
  context: t.Context,
) -> String {
  let match =
    list.key_find(suffixlist.suffixes, context.pronoun)
    |> result.unwrap("error finding verb ending")
  case context.verb.ending {
    t.Irregular -> match
    _ -> {
      let root = string.drop_end(context.verb.infinitive, 2)
      root <> match
    }
  }
}
// fn conjugate_futur_proche(pronoun pronoun: Pronoun, verb verb: Verb) -> String {
//   todo
// }
//
// fn conjugate_passe_compose(pronoun pronoun: Pronoun, verb verb: Verb) -> String {
//   todo
// }
// pub fn process_pronoun(
//   pronoun: t.Pronoun,
//   verb: t.Verb,
//   verb_string: String,
// ) -> String {
//   let pronoun_string = case verb.reflexive {
//     True -> pronoun.string <> " " <> pronoun.reflexive
//     False -> pronoun.string
//   }
//
//   let pronoun_vowel =
//     vowel_check(result.unwrap(
//       string.last(pronoun_string),
//       "pronoun vowel error ",
//     ))
//   let verb_vowel =
//     vowel_check(result.unwrap(string.first(verb_string), "verb vowel error "))
//
//   case pronoun_vowel, verb_vowel {
//     True, True -> string.drop_end(pronoun_string, 1) <> "'"
//     _, _ -> pronoun_string <> " "
//   }
// }
