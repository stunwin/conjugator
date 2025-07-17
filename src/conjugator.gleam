import gleam/dict
import gleam/list

// import gleam/option.{type Option, None}
import gleam/result
import gleam/string
import types as t
import verbs as v

pub type ConjugationError {
  VerbNotFound
  SentenceOrderNotFound
  SuffixListNotFound
  VerbEndingNotFound
  ElisionError1
  ElisionError2
  AuxVerbNotFound
}

pub fn main() {
  let emptyverb = t.Verb("empty", t.Irregular)
  let test1 =
    t.Context(
      pronoun: v.je,
      verblookup: "manger",
      verb: emptyverb,
      tense: t.Present,
      is_reflexive: False,
      is_negated: False,
    )
  let test2 =
    t.Context(
      pronoun: v.nous,
      verblookup: "aller",
      verb: emptyverb,
      tense: t.Present,
      is_reflexive: False,
      is_negated: False,
    )
  let test3 =
    t.Context(
      pronoun: v.je,
      verblookup: "manger",
      verb: emptyverb,
      tense: t.FuturProche,
      is_reflexive: False,
      is_negated: False,
    )

  let test4 =
    t.Context(
      pronoun: v.tu,
      verblookup: "aimer",
      verb: emptyverb,
      tense: t.PasseCompose,
      is_reflexive: False,
      is_negated: False,
    )

  echo conjugate(test1)
  echo conjugate(test2)
  echo conjugate(test3)
  echo conjugate(test4)
}

pub fn result_to_string(input: Result(String, ConjugationError)) -> String {
  case input {
    Ok(sentence) -> sentence
    Error(VerbNotFound) -> "input verb string not found"
    Error(SentenceOrderNotFound) ->
      "input context did not yield sentence structure"
  }
}

pub fn conjugate(context: t.Context) -> Result(String, ConjugationError) {
  use verbstruct <- result.try(get_verb(context.verblookup))
  use sentence_order <- result.try(get_sentence_structure(context))
  let context = t.Context(..context, verb: verbstruct)
  build_sentence(sentence_order, context)
}

pub fn get_verb(input: String) -> Result(t.Verb, ConjugationError) {
  let verbdict = dict.from_list(v.verblist)
  dict.get(verbdict, input)
  |> result.replace_error(VerbNotFound)
}

fn get_sentence_structure(
  context: t.Context,
) -> Result(t.SentenceOrder, ConjugationError) {
  list.find(v.sentences, fn(x) {
    x.tense == context.tense
    && x.is_reflexive == context.is_reflexive
    && x.is_negated == context.is_negated
  })
  |> result.replace_error(SentenceOrderNotFound)
}

fn build_sentence(
  sentence: t.SentenceOrder,
  context: t.Context,
) -> Result(String, ConjugationError) {
  let processed_list =
    list.map(sentence.grammar_units, fn(x) {
      case x {
        t.Pronoun -> Ok(context.pronoun.string)
        t.ReflexivePronoun -> Ok(context.pronoun.reflexive)
        t.MainVerb(t.Conjugated) -> process_verb(context)
        t.MainVerb(t.Infinitive) -> Ok(context.verb.infinitive)
        t.MainVerb(t.Participle) -> Ok(process_participle(context))
        t.AuxiliaryVerb -> {
          use aux_verb <- result.try(select_aux(context))
          let context = t.Context(..context, tense: t.Present, verb: aux_verb)
          process_verb(context)
        }
        t.Ne -> Ok("ne")
        t.Pas -> Ok("pas")
        t.Object -> Ok("object")
      }
    })
  case result.all(processed_list) {
    Ok(stringlist) -> Ok(join_sentence(stringlist))
    Error(e) -> Error(e)
  }
}

fn process_participle(context: t.Context) -> String {
  let root = string.drop_end(context.verb.infinitive, 2)
  case context.verb.ending {
    t.Er -> root <> "é"
    t.Ir -> root <> "i"
    t.Re -> root <> "u"
    t.Irregular -> "TODO: irregular participle"
  }
}

fn select_aux(context: t.Context) -> Result(t.Verb, ConjugationError) {
  case context.tense {
    t.FuturProche -> get_verb("aller")
    t.PasseCompose ->
      case list.contains(v.passe_compose_etre_verbs, context.verb.infinitive) {
        True -> get_verb("etre")
        False -> get_verb("avoir")
      }
    _ -> Error(AuxVerbNotFound)
  }
}

// TODO: this is where we left off refactorng from the bottom up. it's... a little confusing now.

fn join_sentence(sentence: List(String)) {
  case sentence {
    // remember we don't elide tu
    ["tu", ..rest] -> "tu " <> join_sentence(rest)
    [first, second, ..rest] ->
      elision_check(first, second) <> join_sentence([second, ..rest])
    [lastword] -> lastword
    _ -> "something happened during elision"
  }
}

fn elision_check(
  first: String,
  second: String,
) -> Result(String, ConjugationError) {
  use firstend <- result.try(
    string.last(first) |> result.replace_error(ElisionError1),
  )
  use secondstart <- result.map(
    string.first(second) |> result.replace_error(ElisionError2),
  )
  case vowel_check(firstend), vowel_check(secondstart) {
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

pub fn process_verb(context: t.Context) -> Result(String, ConjugationError) {
  use suffixlist <- result.try(select_suffix_list(context))
  select_verb_ending(suffixlist, context)
}

fn select_suffix_list(
  context: t.Context,
) -> Result(t.ConjugationPattern, ConjugationError) {
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
  |> result.replace_error(SuffixListNotFound)
}

fn select_verb_ending(
  suffixlist: t.ConjugationPattern,
  context: t.Context,
) -> Result(String, ConjugationError) {
  use match <- result.map(
    list.key_find(suffixlist.suffixes, context.pronoun)
    |> result.replace_error(VerbEndingNotFound),
  )

  case context.verb.ending {
    t.Irregular -> match
    _ -> string.drop_end(context.verb.infinitive, 2) <> match
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
