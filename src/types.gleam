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
