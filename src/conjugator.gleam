import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import simplifile
import types as t

pub type ConjugationError {
  VerbNotFound
  SentenceOrderNotFound
  SuffixListNotFound
  VerbEndingNotFound
  ElisionError1
  ElisionError2
  AuxVerbNotFound
}

pub const emptyverb = t.Verb("empty", t.Irregular)

pub const infinitive = t.Je("", "", t.M)

pub const je = t.Je("je", "me", t.M)

pub const tu = t.Tu("tu", "te", t.M)

pub const il = t.Il("il", "se", t.M)

pub const elle = t.Elle("elle", "se", t.F)

pub const nous = t.Nous("nous", "nous", t.M)

pub const vous = t.Vous("vous", "vous", t.M)

pub const ils = t.Ils("ils", "se", t.M)

pub const elles = t.Elles("elles", "se", t.F)

pub fn main() {
  let test1 =
    t.Context(
      pronoun: je,
      verblookup: "manger",
      verb: emptyverb,
      tense: t.Present,
      is_reflexive: False,
      is_negated: False,
    )
  let test2 =
    t.Context(
      pronoun: nous,
      verblookup: "aller",
      verb: emptyverb,
      tense: t.Present,
      is_reflexive: False,
      is_negated: False,
    )
  let test3 =
    t.Context(
      pronoun: je,
      verblookup: "manger",
      verb: emptyverb,
      tense: t.FuturProche,
      is_reflexive: False,
      is_negated: False,
    )

  let test4 =
    t.Context(
      pronoun: tu,
      verblookup: "aimer",
      verb: emptyverb,
      tense: t.PasseCompose,
      is_reflexive: False,
      is_negated: False,
    )

  echo conjugate(test1) |> result_to_string()
  echo conjugate(test2) |> result_to_string()
  echo conjugate(test3) |> result_to_string()
  echo conjugate(test4) |> result_to_string()
}

pub fn result_to_string(input: Result(String, ConjugationError)) -> String {
  case input {
    Ok(sentence) -> sentence
    Error(VerbNotFound) -> "input verb string not found"
    Error(SentenceOrderNotFound) ->
      "input context did not yield sentence structure"
    Error(SuffixListNotFound) -> "suffix list not found"
    Error(VerbEndingNotFound) -> "verb ending not found"
    Error(ElisionError1) ->
      "elision error in first word (probably an empty string)"
    Error(ElisionError2) ->
      "elision error in second word (probably an empty string)"
    Error(AuxVerbNotFound) -> "auxiliary verb not found"
  }
}

pub fn conjugate(context: t.Context) -> Result(String, ConjugationError) {
  use verbstruct <- result.try(get_verb(context.verblookup))
  use sentence_order <- result.try(get_sentence_structure(context))
  let context = t.Context(..context, verb: verbstruct)
  build_sentence(sentence_order, context)
}

pub fn get_verb(input: String) -> Result(t.Verb, ConjugationError) {
  // let verbdict = dict.from_list(verblist)
  let assert Ok(records) = simplifile.read("./data/verbs.json")
  let assert Ok(verbdict) = json.parse(records, verb_list_decoder())

  dict.get(verbdict, input)
  |> result.replace_error(VerbNotFound)
}

fn get_sentence_structure(
  context: t.Context,
) -> Result(t.SentenceOrder, ConjugationError) {
  let assert Ok(file) = simplifile.read("./data/sentences.json")
  let assert Ok(sentences) =
    json.parse(file, decode.list(sentence_order_decoder()))

  list.find(sentences, fn(x) {
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
  use listresult <- result.map(result.all(processed_list))
  join_sentence(listresult)
  |> result_to_string()
}

fn join_sentence(sentence: List(String)) {
  let words = prep_elisions(sentence)
  use outputresult <- result.map(result.all(words))
  string.concat(outputresult)
}

fn prep_elisions(
  sentence: List(String),
) -> List(Result(String, ConjugationError)) {
  case sentence {
    ["tu", ..rest] -> list.append([Ok("tu ")], prep_elisions(rest))
    [first, second, ..rest] ->
      list.append(
        [elision_check(first, second)],
        prep_elisions([second, ..rest]),
      )
    [last] -> [Ok(last)]
    [] -> []
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
    t.PasseCompose -> {
      let etre_verbs = get_passe_compose_etre_list()

      case list.contains(etre_verbs, context.verb.infinitive) {
        True -> get_verb("etre")
        False -> get_verb("avoir")
      }
    }
    _ -> Error(AuxVerbNotFound)
  }
}

fn select_suffix_list(
  context: t.Context,
) -> Result(t.ConjugationPattern, ConjugationError) {
  let patternlist = patterns_from_json()
  case context.verb.ending {
    t.Irregular ->
      list.find(patternlist, fn(x) {
        x.tense == context.tense
        && list.key_find(x.suffixes, infinitive) == Ok(context.verb.infinitive)
      })
    _ ->
      list.find(patternlist, fn(x) {
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

//[[JSON]]------------------------------------------------------------------------------------//

fn get_passe_compose_etre_list() {
  let assert Ok(file) = simplifile.read("./data/passe_compose_etre_verbs.json")
  let assert Ok(verblist) = json.parse(file, decode.list(decode.string))
  verblist
}

fn patterns_from_json() -> List(t.ConjugationPattern) {
  let assert Ok(file) = simplifile.read("./data/conjugations.json")
  let assert Ok(patternlist) = json.parse(file, conjugation_list_decoder())
  list.map(patternlist, hydrate_pattern)
}

fn verb_list_decoder() -> decode.Decoder(dict.Dict(String, t.Verb)) {
  decode.dict(decode.string, verb_decoder())
}

fn conjugation_list_decoder() -> decode.Decoder(List(t.RawConjugationPattern)) {
  decode.list(raw_conjugation_pattern_decoder())
}

fn hydrate_pattern(pattern: t.RawConjugationPattern) -> t.ConjugationPattern {
  t.ConjugationPattern(
    tense: pattern.tense,
    ending: pattern.ending,
    suffixes: list.map(pattern.suffixes, fn(x) {
      let pronoun = case x.0 {
        "Tu" -> tu
        "Il" -> il
        "Nous" -> nous
        "Vous" -> vous
        "Ils" -> ils
        "Infinitive" -> infinitive
        _ -> je
      }
      #(pronoun, x.1)
    }),
  )
}

fn sentence_order_decoder() -> decode.Decoder(t.SentenceOrder) {
  use tense <- decode.field("tense", tense_decoder())
  use is_reflexive <- decode.field("is_reflexive", decode.bool)
  use is_negated <- decode.field("is_negated", decode.bool)
  use grammar_units <- decode.field(
    "grammar_units",
    decode.list(grammar_unit_decoder()),
  )
  decode.success(t.SentenceOrder(
    tense:,
    is_reflexive:,
    is_negated:,
    grammar_units:,
  ))
}

fn grammar_unit_decoder() -> decode.Decoder(t.GrammarUnit) {
  use variant <- decode.then(decode.string)
  case variant {
    "Pronoun" -> decode.success(t.Pronoun)
    "ReflexivePronoun" -> decode.success(t.ReflexivePronoun)
    "AuxiliaryVerb" -> decode.success(t.AuxiliaryVerb)
    // NOTE: we're handling all the main verb subtypes in this decoder for now. probably not futureproof
    "MainVerbInfinitive" <> _ -> decode.success(t.MainVerb(t.Infinitive))
    "MainVerbConjugated" <> _ -> decode.success(t.MainVerb(t.Conjugated))
    "MainVerbParticiple" <> _ -> decode.success(t.MainVerb(t.Participle))
    "Ne" -> decode.success(t.Ne)
    "Pas" -> decode.success(t.Pas)
    "Object" -> decode.success(t.Object)
    _ -> panic as "unknown grammar unit"
  }
}

fn verb_decoder() -> decode.Decoder(t.Verb) {
  use infinitive <- decode.field("infinitive", decode.string)
  use ending <- decode.field("ending", ending_decoder())
  decode.success(t.Verb(infinitive:, ending:))
}

fn raw_conjugation_pattern_decoder() -> decode.Decoder(t.RawConjugationPattern) {
  use ending <- decode.field("ending", ending_decoder())
  use tense <- decode.field("tense", tense_decoder())
  use suffixes <- decode.field(
    "suffixes",
    decode.list({
      use a <- decode.field("pronoun", decode.string)
      use b <- decode.field("suffix", decode.string)

      decode.success(#(a, b))
    }),
  )
  decode.success(t.RawConjugationPattern(ending:, tense:, suffixes:))
}

fn ending_decoder() -> decode.Decoder(t.Ending) {
  use variant <- decode.then(decode.string)
  case variant {
    "Er" -> decode.success(t.Er)
    "Ir" -> decode.success(t.Ir)
    "Re" -> decode.success(t.Re)
    "Irregular" -> decode.success(t.Irregular)
    _ -> panic as "unknown ending!!"
  }
}

fn tense_decoder() -> decode.Decoder(t.Tense) {
  use variant <- decode.then(decode.string)
  case variant {
    "Present" -> decode.success(t.Present)
    "PasseCompose" -> decode.success(t.PasseCompose)
    "FuturProche" -> decode.success(t.FuturProche)
    _ -> panic as "unknown tense!"
  }
}
// fn gender_decoder() -> decode.Decoder(t.Gender) {
//   use variant <- decode.then(decode.string)
//   case variant {
//     "M" -> decode.success(t.M)
//     "F" -> decode.success(t.F)
//     _ -> panic as "unknown gender!"
//   }
// }
