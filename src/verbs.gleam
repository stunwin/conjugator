import types as t

pub const conjugations = [
  t.ConjugationPattern(
    ending: t.Er,
    tense: t.Present,
    suffixes: [
      #(t.Je(t.M), "e"),
      #(t.Tu(t.M), "es"),
      #(t.Il, "est"),
      #(t.Nous(t.M), "ons"),
      #(t.Vous(t.M), "ez"),
      #(t.Ils, "ent"),
    ],
  ),
  t.ConjugationPattern(
    ending: t.Ir,
    tense: t.Present,
    suffixes: [
      #(t.Je(t.M), "is"),
      #(t.Tu(t.M), "is"),
      #(t.Il, "it"),
      #(t.Nous(t.M), "issons"),
      #(t.Vous(t.M), "issez"),
      #(t.Ils, "issent"),
    ],
  ),
  t.ConjugationPattern(
    ending: t.Re,
    tense: t.Present,
    suffixes: [
      #(t.Je(t.M), "s"),
      #(t.Tu(t.M), "s"),
      #(t.Il, ""),
      #(t.Nous(t.M), "ons"),
      #(t.Vous(t.M), "ez"),
      #(t.Ils, "ent"),
    ],
  ),
]
