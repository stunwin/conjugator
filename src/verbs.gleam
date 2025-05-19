import types as t

pub const er_present = t.ConjugationPattern(
  tense: t.Present,
  suffixes: [
    #(t.Je(t.M), "e"),
    #(t.Tu(t.M), "es"),
    #(t.Il, "est"),
    #(t.Nous(t.M), "ons"),
    #(t.Vous(t.M), "ez"),
    #(t.Ils, "ent"),
  ],
)

pub const ir_present = t.ConjugationPattern(
  tense: t.Present,
  suffixes: [
    #(t.Je(t.M), "is"),
    #(t.Tu(t.M), "is"),
    #(t.Il, "it"),
    #(t.Nous(t.M), "issons"),
    #(t.Vous(t.M), "issez"),
    #(t.Ils, "issent"),
  ],
)

pub const re_present = t.ConjugationPattern(
  tense: t.Present,
  suffixes: [
    #(t.Je(t.M), "s"),
    #(t.Tu(t.M), "s"),
    #(t.Il, ""),
    #(t.Nous(t.M), "ons"),
    #(t.Vous(t.M), "ez"),
    #(t.Ils, "ent"),
  ],
)
