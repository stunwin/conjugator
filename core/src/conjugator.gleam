import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import simplifile

// [TYPES] -------------------------------------------------------
type ConjugationError {
  VerbNotFound
  SentenceOrderNotFound
  SuffixListNotFound
  VerbEndingNotFound
  ElisionError1
  ElisionError2
  AuxVerbNotFound
}

pub type Context {
  Context(
    pronoun: Pronoun,
    tense: Tense,
    verblookup: String,
    verb: Verb,
    is_reflexive: Bool,
    is_negated: Bool,
  )
}

type ConjugationPattern {
  ConjugationPattern(
    tense: Tense,
    ending: Ending,
    suffixes: List(#(Pronoun, String)),
  )
}

type RawConjugationPattern {
  RawConjugationPattern(
    tense: Tense,
    ending: Ending,
    suffixes: List(#(String, String)),
  )
}

type SentenceOrder {
  SentenceOrder(
    tense: Tense,
    is_reflexive: Bool,
    is_negated: Bool,
    grammar_units: List(GrammarUnit),
  )
}

type GrammarUnit {
  Pronoun
  ReflexivePronoun
  MainVerb(VerbForm)
  AuxiliaryVerb
  Ne
  Pas
  Object
}

type VerbForm {
  Infinitive
  Conjugated
  Participle
}

pub type Verb {
  Verb(infinitive: String, ending: Ending)
}

type VerbEntry =
  #(String, Verb)

pub type Ending {
  Er
  Ir
  Re
  Irregular
}

pub type Tense {
  Present
  PasseCompose
  FuturProche
}

pub type Pronoun {
  Je(string: String, reflexive: String, gender: Gender)
  Tu(string: String, reflexive: String, gender: Gender)
  Il(string: String, reflexive: String, gender: Gender)
  Elle(string: String, reflexive: String, gender: Gender)
  Nous(string: String, reflexive: String, gender: Gender)
  Vous(string: String, reflexive: String, gender: Gender)
  Ils(string: String, reflexive: String, gender: Gender)
  Elles(string: String, reflexive: String, gender: Gender)
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

pub const emptyverb = Verb("empty", Irregular)

pub const infinitive = Je("", "", M)

pub const je = Je("je", "me", M)

pub const tu = Tu("tu", "te", M)

pub const il = Il("il", "se", M)

pub const elle = Elle("elle", "se", F)

pub const nous = Nous("nous", "nous", M)

pub const vous = Vous("vous", "vous", M)

pub const ils = Ils("ils", "se", M)

pub const elles = Elles("elles", "se", F)

pub fn main() {
  let test1 =
    Context(
      pronoun: je,
      verblookup: "manger",
      verb: emptyverb,
      tense: Present,
      is_reflexive: False,
      is_negated: False,
    )
  let test2 =
    Context(
      pronoun: nous,
      verblookup: "aller",
      verb: emptyverb,
      tense: Present,
      is_reflexive: False,
      is_negated: False,
    )
  let test3 =
    Context(
      pronoun: je,
      verblookup: "manger",
      verb: emptyverb,
      tense: FuturProche,
      is_reflexive: False,
      is_negated: False,
    )

  let test4 =
    Context(
      pronoun: tu,
      verblookup: "aimer",
      verb: emptyverb,
      tense: PasseCompose,
      is_reflexive: False,
      is_negated: False,
    )

  echo conjugate(test1)
  echo conjugate(test2)
  echo conjugate(test3)
  echo conjugate(test4)
}

// [CONJUGATOR] ----------------------------------------------------------------

pub fn conjugate(context: Context) -> String {
  {
    use verbstruct <- result.try(get_verb(context.verblookup))
    use sentence_order <- result.try(get_sentence_structure(context))
    let context = Context(..context, verb: verbstruct)
    build_sentence(sentence_order, context)
  }
  |> result_to_string()
}

fn result_to_string(input: Result(String, ConjugationError)) -> String {
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

fn get_verb(input: String) -> Result(Verb, ConjugationError) {
  let assert Ok(records) = simplifile.read("./data/verbs.json")
  let assert Ok(verbdict) = json.parse(records, verb_list_decoder())

  dict.get(verbdict, input)
  |> result.replace_error(VerbNotFound)
}

fn get_sentence_structure(
  context: Context,
) -> Result(SentenceOrder, ConjugationError) {
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
  sentence: SentenceOrder,
  context: Context,
) -> Result(String, ConjugationError) {
  let processed_list =
    list.map(sentence.grammar_units, fn(x) {
      case x {
        Pronoun -> Ok(context.pronoun.string)
        ReflexivePronoun -> Ok(context.pronoun.reflexive)
        MainVerb(Conjugated) -> process_verb(context)
        MainVerb(Infinitive) -> Ok(context.verb.infinitive)
        MainVerb(Participle) -> Ok(process_participle(context))
        AuxiliaryVerb -> {
          use aux_verb <- result.try(select_aux(context))
          let context = Context(..context, tense: Present, verb: aux_verb)
          process_verb(context)
        }
        Ne -> Ok("ne")
        Pas -> Ok("pas")
        Object -> Ok("object")
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

fn vowel_check(letter: String) -> Bool {
  case letter {
    "a" | "e" | "i" | "o" | "u" -> True
    _ -> False
  }
}

fn process_verb(context: Context) -> Result(String, ConjugationError) {
  use suffixlist <- result.try(select_suffix_list(context))
  select_verb_ending(suffixlist, context)
}

fn process_participle(context: Context) -> String {
  let root = string.drop_end(context.verb.infinitive, 2)
  case context.verb.ending {
    Er -> root <> "é"
    Ir -> root <> "i"
    Re -> root <> "u"
    Irregular -> "TODO: irregular participle"
  }
}

fn select_aux(context: Context) -> Result(Verb, ConjugationError) {
  case context.tense {
    FuturProche -> get_verb("aller")
    PasseCompose -> {
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
  context: Context,
) -> Result(ConjugationPattern, ConjugationError) {
  let patternlist = patterns_from_json()
  case context.verb.ending {
    Irregular ->
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
  suffixlist: ConjugationPattern,
  context: Context,
) -> Result(String, ConjugationError) {
  use match <- result.map(
    list.key_find(suffixlist.suffixes, context.pronoun)
    |> result.replace_error(VerbEndingNotFound),
  )

  case context.verb.ending {
    Irregular -> match
    _ -> string.drop_end(context.verb.infinitive, 2) <> match
  }
}

//[[JSON]]------------------------------------------------------------------------------------//

fn get_passe_compose_etre_list() {
  let assert Ok(file) = simplifile.read("./data/passe_compose_etre_verbs.json")
  let assert Ok(verblist) = json.parse(file, decode.list(decode.string))
  verblist
}

fn patterns_from_json() -> List(ConjugationPattern) {
  let assert Ok(file) = simplifile.read("./data/conjugations.json")
  let assert Ok(patternlist) = json.parse(file, conjugation_list_decoder())
  list.map(patternlist, hydrate_pattern)
}

fn verb_list_decoder() -> decode.Decoder(dict.Dict(String, Verb)) {
  decode.dict(decode.string, verb_decoder())
}

fn conjugation_list_decoder() -> decode.Decoder(List(RawConjugationPattern)) {
  decode.list(raw_conjugation_pattern_decoder())
}

fn hydrate_pattern(pattern: RawConjugationPattern) -> ConjugationPattern {
  ConjugationPattern(
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

fn sentence_order_decoder() -> decode.Decoder(SentenceOrder) {
  use tense <- decode.field("tense", tense_decoder())
  use is_reflexive <- decode.field("is_reflexive", decode.bool)
  use is_negated <- decode.field("is_negated", decode.bool)
  use grammar_units <- decode.field(
    "grammar_units",
    decode.list(grammar_unit_decoder()),
  )
  decode.success(SentenceOrder(
    tense:,
    is_reflexive:,
    is_negated:,
    grammar_units:,
  ))
}

fn grammar_unit_decoder() -> decode.Decoder(GrammarUnit) {
  use variant <- decode.then(decode.string)
  case variant {
    "Pronoun" -> decode.success(Pronoun)
    "ReflexivePronoun" -> decode.success(ReflexivePronoun)
    "AuxiliaryVerb" -> decode.success(AuxiliaryVerb)
    // NOTE: we're handling all the main verb subtypes in this decoder for now. probably not futureproof
    "MainVerbInfinitive" <> _ -> decode.success(MainVerb(Infinitive))
    "MainVerbConjugated" <> _ -> decode.success(MainVerb(Conjugated))
    "MainVerbParticiple" <> _ -> decode.success(MainVerb(Participle))
    "Ne" -> decode.success(Ne)
    "Pas" -> decode.success(Pas)
    "Object" -> decode.success(Object)
    _ -> panic as "unknown grammar unit"
  }
}

fn verb_decoder() -> decode.Decoder(Verb) {
  use infinitive <- decode.field("infinitive", decode.string)
  use ending <- decode.field("ending", ending_decoder())
  decode.success(Verb(infinitive:, ending:))
}

fn raw_conjugation_pattern_decoder() -> decode.Decoder(RawConjugationPattern) {
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
  decode.success(RawConjugationPattern(ending:, tense:, suffixes:))
}

fn ending_decoder() -> decode.Decoder(Ending) {
  use variant <- decode.then(decode.string)
  case variant {
    "Er" -> decode.success(Er)
    "Ir" -> decode.success(Ir)
    "Re" -> decode.success(Re)
    "Irregular" -> decode.success(Irregular)
    _ -> panic as "unknown ending!!"
  }
}

fn tense_decoder() -> decode.Decoder(Tense) {
  use variant <- decode.then(decode.string)
  case variant {
    "Present" -> decode.success(Present)
    "PasseCompose" -> decode.success(PasseCompose)
    "FuturProche" -> decode.success(FuturProche)
    _ -> panic as "unknown tense!"
  }
}
// fn gender_decoder() -> decode.Decoder(Gender) {
//   use variant <- decode.then(decode.string)
//   case variant {
//     "M" -> decode.success(M)
//     "F" -> decode.success(F)
//     _ -> panic as "unknown gender!"
//   }
// }
