import gleam/dynamic/decode

pub type Context {
  Context(
    pronoun: Pronoun,
    tense: Tense,
    verb: Verb,
    is_reflexive: Bool,
    is_negated: Bool,
  )
}

pub type ConjugationPattern {
  ConjugationPattern(
    tense: Tense,
    ending: Ending,
    suffixes: List(#(Pronoun, String)),
  )
}

pub type SentenceOrder {
  SentenceOrder(
    tense: Tense,
    is_reflexive: Bool,
    is_negated: Bool,
    grammar_units: List(GrammarUnit),
  )
}

pub type GrammarUnit {
  Pronoun
  ReflexivePronoun
  MainVerb(VerbForm)
  AuxiliaryVerb
  Ne
  Pas
  Object
}

pub type VerbForm {
  Infinitive
  Conjugated
  Participle
}

pub type Verb {
  Verb(infinitive: String, ending: Ending)
}

pub type VerbEntry =
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
