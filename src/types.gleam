pub type ConjugationPattern {
  ConjugationPattern(
    tense: Tense,
    ending: Ending,
    suffixes: List(#(Pronoun, String)),
  )
}

pub type Verb {
  Verb(infinitive: String, reflexive: Bool, ending: Ending)
}

pub type Ending {
  Er
  Ir
  Re
  Irregular
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
