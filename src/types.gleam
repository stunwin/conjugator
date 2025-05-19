pub type ConjugationPattern {
  ConjugationPattern(tense: Tense, suffixes: List(#(Pronoun, String)))
}

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
